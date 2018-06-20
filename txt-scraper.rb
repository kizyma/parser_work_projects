require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'colorize'
require 'date'

#making the script ask for the value of PHPSESSID as an argument for the script, so that I don't forget to enter a valid PHPSESSID each time I run the script.
arg0, arg1, arg2 = ARGV

#a function that sets the header and user id for HTTParty's request, sets the range for scraping (taken from the arguments for the script), and validates the range.
def prepare(session, t_from, t_to)
  @header = {"cookie" => "PHPSESSID=" + session.to_s + "; user_id=48"}
  @t_from = t_from
  @t_to = t_to
  if @t_from.to_i > @t_to.to_i
    puts ("Can't go from #{@t_from} to #{@t_to}, enter a valid range.").colorize(:background=>:red, :color=>:white)
  else
    puts ("Starting").colorize(:background=>:blue, :color=>:white)
  end
end

#a function that goes through the range of tickets, pulling all the links to attachments that have a .txt extension from tickets' HTML.
def walk(t_from, t_to, header)
  #start iterating over the range of argument-supplied ticket IDs.
  (t_from..t_to).each do |ticket_id|
    #dump the HTML of a customer's profile to a variable named doc.
    doc = Nokogiri::HTML(HTTParty.get("https://crm.macphun.us/customer/105558/?&ticket="+ticket_id.to_s, :headers => header))
    puts ("https://crm.macphun.us/customer/105558/?&ticket="+ticket_id.to_s)
    #get customer's email so that there's something to refer the info to down the line
    email = (doc.at_css("#tid"+ticket_id.to_s).inner_html[/(?<=<i\ class="fa\ fa-envelope"\ style="margin-right:\ 10px"><\/i>)(.*)+?(?=<\/div>)/]).gsub(/\s*/, '')
    #scan the HTML for links to files that have a .txt extension
    doc.inner_html.scan(/attachments\/.*\/\d*\/.*\.txt/){|link|
      #call the download function for the discovered links
      download("https://crm.macphun.us/" + link.to_s, email)
      #time out for one second between writing files in order to be able to write more than one file for one customer
      sleep(1)
    }
  end
end

def download(link, email)
  #open the file for writing, set the name to be current date and time + customer's email
  File.open("output/" + (DateTime.now.strftime("%d-%m-%Y-%H-%M-%S")).to_s + "-" + email.to_s + ".txt", 'a'){|file|
    #writing the contents of the response into the file
    file.write(HTTParty.get(link))
    puts ("TXT FOUND, SAVED AS " + ((DateTime.now.strftime("%d-%m-%Y-%H-%M-%S")).to_s + "-" + email.to_s + ".txt")).colorize(:background=>:green, :color=>:white)
  }
end

prepare(arg0, arg1, arg2)
walk(@t_from, @t_to, @header)