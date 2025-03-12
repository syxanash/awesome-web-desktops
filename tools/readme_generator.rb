# this script generates the main README.md file
# in Awesome Web Desktops repository by fetching the web desktops json

require 'json'
require 'rest-client'

def escape_markdown(text)
  text.gsub(/([\\\|])/, '\\\\\1').gsub("\n", '<br>')
end

websites_object = JSON.parse(RestClient.get('https://raw.githubusercontent.com/syxanash/syxanash.github.io/development/src/resources/remote-desktops.json'))
readme_content = RestClient.get('https://raw.githubusercontent.com/syxanash/awesome-web-desktops/refs/heads/main/README.md')

readme_header = readme_content.match(/^.*?\|---\|---\|---\|/m)[0]
readme_footer = readme_content.match(/## Archived\n*.*?$/m)[0]

links_table = ''

websites_object.each do |website|
  escaped_website_name = escape_markdown(website['name'])
  links_table += "[#{escaped_website_name}](#{website['url']}) |"

  if website['source'].empty?
    links_table += ' ![locked](assets/locked.png) private |'
  else
    links_table += " [![open](assets/open.png) available](#{website['source']}) |"
  end

  unless website['notes'].empty?
    links_table += " #{escape_markdown(website['notes'])} |"
  end

  links_table += "\n"
end

puts "#{readme_header}\n#{links_table}\n#{readme_footer}"
