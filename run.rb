require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'colorize'

header = {
	"cookie" => "PHPSESSID=q9frd93b1t9u8stvvmbhfrci5q; user_id=27"
}

output = CSV.open('output.csv', 'w', :write_headers=> true, :headers => ["UserProfile", "UserEmail", "TXTLink"])

url = "https://crm.macphun.us/customer/105558/?&ticket="

t_from = 308000
t_to = 312000

#t_from = 374560
#t_to = 374574
#test if works

puts "START".colorize(:color => :white, :background => :blue)
puts

(t_from..t_to).each do |ticket_id|
  
  response = HTTParty.get(url.to_s+ticket_id.to_s, :headers => header)
  doc = Nokogiri::HTML(response)
  puts url.to_s+ticket_id.to_s
  doc.inner_html.scan(/attachments\/skylum\/(.*)\.txt/) do |attachment|
    email = (doc.at_css("#tid"+ticket_id.to_s).inner_html[/(?<=<i\ class="fa\ fa-envelope"\ style="margin-right:\ 10px"><\/i>)(.*)+?(?=<\/div>)/]).gsub(/\s*/, '')
    txt_link = (doc.inner_html[/attachments\/skylum\/(.*)\.txt/])
    puts ("Found a txt " + email.to_s).colorize(:background => :green) 
    puts (("https://crm.macphun.us/" + txt_link.to_s).colorize(:background => :green))
   output << [url.to_s+ticket_id.to_s, email, "https://crm.macphun.us/" + txt_link.to_s]
  end
  
end

puts
puts "DONE".colorize(:color => :white, :background => :blue)