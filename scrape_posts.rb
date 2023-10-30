require 'mechanize'
require 'pry'
require 'reverse_markdown'

LOGIN_URL = ""
USERNAME = ""
PASSWORD = ""
PAGE_ROOT_URL = ""

agent = Mechanize.new
page = agent.get(LOGIN_URL)

puts 'logging in...'

form = page.forms.first
form.email = USERNAME
form.password = PASSWORD
page = agent.submit(form, form.buttons.first)

# get all the pages of content

# pages = (1..21)
# links = []

# pages.each { |page| 
#   page_url = "#{PAGE_ROOT_URL}?page=#{page}"
#   puts "getting page #{page_url}"
#   author_page = agent.get(page_url)
#   content_pages = author_page.links

#   content_pages.each { |link| 
#     links.push(link.href) if link.href.match(/content\//)
#   }

# }

# unique_links = links.uniq

# puts unique_links.count.to_s + " posts found"

# File.open(File.dirname(__FILE__) + "/post_links.txt", "a+") { |f| 
#   f.puts(unique_links) 
# }

# if the above all worked correctly we have the links in a text file and don't have to do that bit again

# hit each pages and pull the content out

post_links = File.readlines(File.dirname(__FILE__) + '/post_links.txt')

post_links.each { |link|

  puts "processing #{link}"

  page = agent.get(link)

  title = page.search("/html/body/main/header/main/h1/span").text.strip

  puts title

  category = page.search("/html/body/main/header/div/a[1]").text.strip

  date = page.search("/html/body/main/main/footer/a[1]/local-time").text.strip

  post_content = page.search(".trix-output")[0].children
  post_content_string = ""
  post_content.each { |element|
    post_content_string << element.to_html.strip
  }
  post_content_string = ReverseMarkdown.convert(post_content_string)
  post_content_string = post_content_string.gsub(/\s{3,}/, "\n\n")

  File.open(File.dirname(__FILE__) + "/posts/#{date.split(" ")[0].strip}-#{title.gsub(/[^0-9A-Za-z.\-]/, '_')}.md","a+") { |f| 
    # example YAML frontmatter for these markdown files:
    # ---
    # layout: post
    # title: "What happened to web design?"
    # excerpt: 
    # date: 2023-10-17 14:07:49 -0500
    # categories: 
    #  - web
    #  - design
    # ---
    f.puts("---" + "\n")
    f.puts("layout: post" + "\n")
    f.puts("title: " + title + "\n")
    f.puts("date: " + date + "\n")
    f.puts("categories:" + "\n")
    f.puts(" - " + category + "\n") unless category.empty?
    f.puts("---" + "\n\n")
    f.puts(post_content_string)
  }

}
