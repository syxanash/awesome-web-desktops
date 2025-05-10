# this script generates the main README.md file
# in Awesome Web Desktops repository by fetching the web desktops json

require 'json'
require 'rest-client'

def escape_markdown(text)
  text.gsub(/([\\|])/, '\\\\\1').gsub("\n", '<br>')
end

readme_file_name = '../README.md'
archived_file_name = '../archived.md'

websites_object = JSON.parse(RestClient.get('https://raw.githubusercontent.com/syxanash/syxanash.github.io/development/src/resources/remote-desktops.json'))
readme_content = File.read(readme_file_name)
archived_content = File.read(archived_file_name)

archived_header = archived_content.match(/^.*?\|---\|/m)[0]

readme_header = readme_content.match(/^.*?\|---\|---\|---\|/m)[0]
readme_footer = readme_content.match(/## Archived\n*.*?$/m)[0]

readme_links_table = ''
archived_links_table = ''

websites_object.select { |website| website['archive'].empty? }.each do |website|
  escaped_website_name = escape_markdown(website['name'])
  readme_links_table += "[#{escaped_website_name}](#{website['url']}) |"

  readme_links_table += if website['source'].empty?
                          ' ![locked](assets/locked.png) private |'
                        else
                          " [![open](assets/open.png) available](#{website['source']}) |"
                        end

  readme_links_table += " #{escape_markdown(website['notes'])} |" unless website['notes'].empty?

  readme_links_table += "\n"
end

readme_file_content = "#{readme_header}\n#{readme_links_table}\n#{readme_footer}\n"
File.write(readme_file_name, readme_file_content)

websites_object.reject { |website| website['archive'].empty? }.each do |website|
  escaped_website_name = escape_markdown(website['name'])
  archived_links_table += "[#{escaped_website_name}](#{website['archive']}) |\n"
end

archived_file_content = "#{archived_header}\n#{archived_links_table}"
File.write(archived_file_name, archived_file_content)
