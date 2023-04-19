require 'mechanize'

url = ARGV[0]
selector = ARGV[1]
file = ARGV[2]

mechanize = Mechanize.new

page = mechanize.get(url)

content = "#{url}\n\n"

page.search(selector).each do |post|
  content += post.text
end

File.open(File.dirname(__FILE__) + "/#{file}", "a+") { |f| f.puts(content + "\n\n") }
