require 'selenium-webdriver'
require 'json'
require 'rest-client'
require 'colorize'
require 'fuzzystringmatch'
require 'fileutils'

SIMILARITY_THRESHOLD = 70

# https://stackoverflow.com/a/10823131
def sanitize_filename(filename)
  # Split the name when finding a period which is preceded by some
  # character, and is followed by some character other than a period,
  # if there is no following period that is followed by something
  # other than a period (yeah, confusing, I know)
  fn = filename.split(/(?<=.)\.(?=[^.])(?!.*\.[^.])/m)

  # We now have one or two parts (depending on whether we could find
  # a suitable period). For each of these parts, replace any unwanted
  # sequence of characters with an underscore
  fn.map! { |s| s.gsub(/[^a-z0-9-]+/i, '_') }

  # Finally, join the parts with a period and return the result
  fn.join '.'
end

def create_report(links, ignored)
  date_time = Time.new
  html_report = File.new('report.html', 'w+')

  html_report.write <<~HTML_REPORT
    <html>
      <head>
        <title>Web Desktops Watcher Report</title>
      </head>
      <body>
        <div>
          <h1>Report #{date_time.strftime('%Y-%m-%d %H:%M')}</h1>
          <p>Manually check the following links:</p>
    #{links.map { |link| "<a href='#{link}' target='_blank'>#{link}</a>" }.join('<br>')}
          <br>
          <p>Ignored links:</p>
    #{ignored.map { |link| "<a href='#{link}' target='_blank'>#{link}</a>" }.join('<br>')}
        </div>
        <br>
        <button onClick='openAll()'>Open all</button>
        <script>
          function openAll() {
            var links = document.links;
            for (var i = 0; i < links.length; i++) {
                window.open(links[i], '_blank')
            }
          }
        </script>
      </body>
    </html>
  HTML_REPORT

  html_report.close
end

websites_object = JSON.parse(RestClient.get('https://raw.githubusercontent.com/syxanash/syxanash.github.io/development/src/resources/remote-desktops.json'))
ignored_links = JSON.parse(File.read('ignore_list.json'))
links_to_inspect = []
jarow = FuzzyStringMatch::JaroWinkler.create(:native)
archive_directory = File.expand_path('~/.cache/wd-archive')

active_websites = websites_object.select { |website| website['archive'].empty? }

active_websites.each_with_index do |website_obj, index|
  directory_name = "#{archive_directory}/#{sanitize_filename(website_obj['name'])}"

  first_scan = false

  FileUtils.mkdir_p(directory_name) unless Dir.exist? directory_name

  if ignored_links.include?(website_obj['url'])
    puts "[?] Ignoring: #{website_obj['url']}"

    next
  end

  begin
    print "[#{index + 1}/#{active_websites.size}]".yellow
    print " Scanning #{website_obj['name']}...".blue

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--ignore-certificate-errors')

    # options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])

    driver = Selenium::WebDriver.for :chrome, options: options
    driver.manage.window.resize_to(1792, 1120)

    driver.get website_obj['url']

    sleep(8)

    begin
      # Try to accept/dismiss any alert that appears
      if driver.switch_to.alert
        begin
          driver.switch_to.alert.accept
        rescue StandardError
          nil
        end
      end
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      # No alert, continue as normal
    end

    source = driver.page_source
    driver.quit

    if File.exist? "#{directory_name}/recent.html"
      FileUtils.cp("#{directory_name}/recent.html", "#{directory_name}/previous.html")
    else
      first_scan = true
      print 'Initialized.'.yellow
    end

    File.write("#{directory_name}/recent.html", source)

    unless first_scan
      print 'Comparing...'.light_blue
      first_file = File.read("#{directory_name}/recent.html")
      second_file = File.read("#{directory_name}/previous.html")

      if jarow.getDistance(first_file, second_file).to_f * 100 < SIMILARITY_THRESHOLD
        puts ''
        puts '[?] Found differences in:'.yellow
        puts website_obj['url']

        links_to_inspect.push(website_obj['url'])
      end
    end
    puts 'Done.'
  rescue StandardError => e
    puts ''
    puts "[!] Can't connect to: #{website_obj['url']}".red
    puts e.to_s.red

    links_to_inspect.push(website_obj['url'])
  end
end

Dir.chdir(archive_directory) do
  website_folders = Dir.glob('*')

  if website_folders.size > active_websites.size
    object_directory_names = active_websites.map { |item| sanitize_filename(item['name']) }

    different_folders = website_folders - object_directory_names

    different_folders.each do |folder_to_remove|
      puts "[X] Removed #{folder_to_remove}".cyan
      FileUtils.rm_rf(folder_to_remove)
    end
  end
end

puts '[?] Creating a report...'.yellow
create_report(links_to_inspect, ignored_links)

puts 'All Done.'
