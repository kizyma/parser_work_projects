#Encoding: UTF-8

require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'colorize'
require 'date'

#arg3, arg0 - userID and PHPSESSID for login; arg1 - start range of tickets; arg2 - end range of tickets
arg3, arg0, arg1, arg2 = ARGV

#a function that sets the header and user id for HTTParty's request, sets the range for scraping (taken from the arguments for the script), and validates the range.
def prepare(user_id, session, t_from, t_to)
  @header = {"cookie" => "PHPSESSID=" + session.to_s + "; user_id=" + user_id.to_s}
  @t_from = t_from
  @t_to = t_to
  #validating that the login was successful
  if Nokogiri::HTML(HTTParty.get("https://crm.macphun.us", :headers => @header)).inner_html.include? "Log out"
    #if the login was successful, validating the range
    if @t_from.to_i > @t_to.to_i
      abort ("Can't go from #{@t_from} to #{@t_to}, enter a valid range.").colorize(:background=>:red, :color=>:white)
    else
      puts ("Start.").colorize(:background=>:blue, :color=>:white)
    end
  else
    abort ("Unable to log in with userID #{user_id} and PHPSESSID #{session}").colorize(:background=>:red, :color=>:white)
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
    begin
      email = (doc.at_css("#tid"+ticket_id.to_s).inner_html[/(?<=<i\ class="fa\ fa-envelope"\ style="margin-right:\ 10px"><\/i>)(.*)+?(?=<\/div>)/]).gsub(/\s*/, '')
    rescue
      puts ("Can't get user email from ticket, skipping.").colorize(:background=>:yellow, :color=>:white)
    end
    #scan the HTML for links to files that have a .txt extension
    doc.inner_html.scan(/attachments\/.*\/\d*\/.*\.txt/){|link|
      #call the download function for the discovered links
      download("https://crm.macphun.us/" + link.to_s, email)
    }
  end
end

#a function that downloads files that match the description of a msinfo32 report
def download(link, email)
  marker = HTTParty.get(link).to_s.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).downcase.gsub(/[^a-z0-9]/, '')
  #validating that the file is an msinfo32 report by converting the text in it to downcase, stripping all characters except letters and numbers, and comparing the resulting string to "systeminformationreportwrittenat" which appears in the beginning of all the msinfo32 reports; works only for msinfo32 reports in English
  if marker.include? "systeminformationreportwrittenat" or marker.include? "rapportdinformationssystmecritlemplacement" or marker.include? "systeminformationsberichterstelltam" or marker.include? "elinformedelsistemaseescribien"
    #if one of the conditions above is true, creating a new file with a timestamp and a customer's email in the name
    File.open("output/" + (DateTime.now.strftime("%d-%m-%Y-%H-%M-%S")).to_s + "-" + email.to_s + ".txt", 'a'){|file|
    #writing the contents of the response into the file
      file.write(HTTParty.get(link))
      puts ("TXT FOUND, SAVED AS " + ((DateTime.now.strftime("%d-%m-%Y-%H-%M-%S")).to_s + "-" + email.to_s + ".txt")).colorize(:background=>:green, :color=>:white)
      #time out for one second between writing files in order to be able to write more than one file for one customer
      sleep(1)
    }
  else
  end
end

#executing
prepare(arg3, arg0, arg1, arg2)
walk(@t_from, @t_to, @header)
puts ("End.").colorize(:background=>:blue, :color=>:white)