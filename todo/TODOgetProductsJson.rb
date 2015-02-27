#need to divide it (json for each product under each category)

require 'net/http'
require 'json'

time = Time.new
todayDate = time.day.to_s + "-" + time.month.to_s + "-" + time.year.to_s

productDataDir = '/Users/admin/Copy qa@cmycasa.com/Ruby/programs/GetAllProducGUIDs/Version2/ProductJsons/'
categoryIDsDir = '/Users/admin/Copy qa@cmycasa.com/Ruby/programs/GetAllProducGUIDs/Version2/CategoryIDs/catIDs_' + todayDate + ".txt"



f = File.open(categoryIDsDir, "r")
f.each_line do |line|
    
    puts "fetching product Json for category: " + line
    
    #needs to changed to prod/increase limit to 1000
    url= "http://alpha.homestyler.com/api/rest/v2.0/category/" + line.to_s.chomp +  "/product?l=en&t=hsm&offset=0&limit=20"
    
    resp = Net::HTTP.get_response(URI.parse(url))
    
    hash  =  JSON.parse(resp.body)
    
    hash["items"].each {|x|
        
        puts "fetching json for product:" + x["id"]
        
        open(productDataDir + "product_" + x["id"] + "_" + line.to_s.chomp + "_" + todayDate + ".json", 'w') do |f|
             f << x.to_s.gsub(/=>/, ":")
         end
    
    }
    
    puts "DONE fetching product Jsons for category: " + line
    
    
    sleep(0.3)

    
    
end


f.close

puts "DONE fetching product Json"