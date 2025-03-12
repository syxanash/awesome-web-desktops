# this script is a WIP...

require 'selenium-webdriver'
require 'selenium/devtools'
require 'json'
require 'rest-client'
require 'fileutils'
require 'uri'

# Load website list
websites_object = JSON.parse(RestClient.get('https://raw.githubusercontent.com/syxanash/syxanash.github.io/development/src/resources/remote-desktops.json'))

# Setup Selenium with Chrome DevTools Protocol (CDP)
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
options.add_argument('--ignore-certificate-errors')

driver = Selenium::WebDriver.for :chrome, options: options

# Function to check if a URL returns a valid response (not 404)
def valid_url?(url)
  return false if url.nil? || url.strip.empty?
  
  begin
    response = RestClient.head(url)
    return response.code == 200
  rescue RestClient::NotFound, RestClient::Exception
    return false
  end
end

# Function to get favicon using Chrome's internal processing
def get_favicon_from_cdp(driver, url)
  driver.get(url)
  sleep(3)

  # Use Chrome DevTools Protocol (CDP) to get favicon URL
  cdp_session = driver.send(:devtools)
  response = cdp_session.send_cmd('Page.getNavigationHistory')

  entries = response['entries']
  last_entry = entries.last if entries
  favicon_url = last_entry&.dig('faviconUrl')

  # Ensure it's a full URL
  favicon_url = URI.join(url, favicon_url).to_s if favicon_url
  favicon_url
end

# Function to get favicon and apple-touch-icon URL
def get_favicons(driver, url)
  parsed_icon = get_favicon_from_cdp(driver, url)

  if parsed_icon.nil?
    begin
      # Look for <link rel="icon"> and <link rel="shortcut icon">
      favicon = driver.find_element(:css, "link[rel~='icon'], link[rel='shortcut icon']")
      parsed_icon = favicon.attribute('href')
    rescue Selenium::WebDriver::Error::NoSuchElementError
      parsed_icon = nil
    end
  end

  if parsed_icon.nil?
    begin
      # Look for <link rel="apple-touch-icon">
      apple_icon = driver.find_element(:css, "link[rel='apple-touch-icon']")
      parsed_icon = apple_icon.attribute('href')
    rescue Selenium::WebDriver::Error::NoSuchElementError
      parsed_icon = nil
    end
  end

  # Try fetching from manifest.json
  parsed_icon ||= get_manifest_icon(driver, url)

  # Fallback to /favicon.ico, but check if it exists
  uri = URI.parse(url)
  fallback_favicon = "#{uri.scheme}://#{uri.host}/favicon.ico"
  parsed_icon ||= fallback_favicon if valid_url?(fallback_favicon)

  puts "[#{parsed_icon ? '+' : '-'}] #{url} -> Favicon: #{parsed_icon || 'None'}"
  parsed_icon
end

# Function to get favicon from manifest.json
def get_manifest_icon(driver, url)
  begin
    manifest_el = driver.find_element(:css, "link[rel='manifest']")
    manifest_url = manifest_el.attribute('href')

    manifest_uri = URI.join(url, manifest_url).to_s
    manifest_data = JSON.parse(RestClient.get(manifest_uri))

    if manifest_data['icons'] && !manifest_data['icons'].empty?
      icon_url = URI.join(manifest_uri, manifest_data['icons'][0]['src']).to_s
      return icon_url if valid_url?(icon_url)
    end
  rescue Selenium::WebDriver::Error::NoSuchElementError, StandardError
    return nil
  end
  nil
end

# Extract favicons
not_found_favicons = []

websites_object.each do |website|
  begin
    parsed_icon = get_favicons(driver, website['url'])
  rescue StandardError => error
    puts "[!] Can't connect to: #{website['url']}"
    puts error
    parsed_icon = nil
  end

  if parsed_icon.nil?
    not_found_favicons << website['url']
    website['favicon'] = ''
  else
    website['favicon'] = parsed_icon
  end
end

driver.quit

# Save results
File.write('remote-desktops.json.json', JSON.pretty_generate(websites_object))
File.write('not_found_favicons.json', JSON.pretty_generate(not_found_favicons))

puts "\nFavicons saved to favicons.json"
