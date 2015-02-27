require 'date'
require 'net/http'
require 'json'


def getCatData(env, tenant, status)
    
    # add as input
    $TodayDate = (Date.today).strftime('%Y-%m-%d')
    
    categoryIDsDir = File.dirname(__FILE__) + '/CategoryIDs/Categories/' + tenant + "_categoryIDs_" + $TodayDate + ".txt"
    subCategoryIDsDir = File.dirname(__FILE__) + '/CategoryIDs/SubCategories/' + tenant + "_subCategoryIDs_" + $TodayDate + ".txt"
    
    puts "Fetching category and subcategories data"
    
    #needs to change to prodß // add base url + api// example link
    if(tenant=="ezhome")
	if(env=="prod")
		base_URL="http://juran-3d-prod-catalog-elb-pub-1-582422658.cn-north-1.elb.amazonaws.com.cn:8080/"
		api = "v2.0/category?lang=en_US&t=ezhome&status="+status
 	else
		puts "EZHome staging is not supprted for now!"
	end
   elsif(env != "prod") then
        base_URL = "http://fp-hsm-mw." + env + ".homestyler.com:80/"
   else
        base_URL = "http://fp-hsm-mw.homestyler.com:80/"
	api = "api/rest/v2.0/category?t="+ tenant +"&l=en_US&status=" + status

    end
    
    
    url = base_URL + api
    
    puts "url: " + url
    if(tenant=="ezhome")
	temptimestamp = Time.now.to_i
    	timestamp = temptimestamp.to_s+"000"
    	sha256 = Digest::SHA256.new
    	secret_str=timestamp+"adsk-ezhome"
    	digest =sha256.hexdigest(secret_str)
	puts timestamp
	puts digest
	uri= URI.parse(url)
    	http = Net::HTTP.new(uri.host,uri.port)
    	request=Net::HTTP::Get.new(uri.request_uri,{'hs_ts' => timestamp, 'hs_secret' => digest})
    	resp= http.request(request)
	puts resp.body
    else
    	resp = Net::HTTP.get_response(URI.parse(url))
    end
    
    #puts resp
    
    hash  =  JSON.parse(resp.body)
    
    catIDs      = Array.new
    catNames    = Array.new
    
    subCatIDs   = Array.new
    subCatNames = Array.new
    
    catData     = Array.new
    subCatData  = Array.new
    
    
    def getCatsIDs(json, arr)
        if json == nil then return end
        json.each{|i| arr.push(i["id"]) }
        json.each{|i| getCatsIDs(i["categories"], arr) }
    end
    
    
    def getCatsName(json, path, arr)
        if json == nil then return end
        json.each{|i| arr.push(path + ">>" + i["name"]) }
        json.each{|i| getCatsName(i["categories"], path + ">>" + i["name"], arr) }
    end
    
    #for cats
    if(tenant!="ezhome")
    	level_str="items"
        subCat_str="categories"
    else
    	level_str="categories"
         subCat_str="subCategories"
    end
    hash[level_str].each{|i| catIDs.push(i["id"])}
    hash[level_str].each{|i| catNames.push(i["name"])}
    
    #for subcats
    hash[level_str].each{|i| getCatsIDs(i[subCat_str], subCatIDs) }
    hash[level_str].each{|i| getCatsName(i[subCat_str], i["name"] ,subCatNames) }
    
    catData = catIDs.zip(catNames)
    subCatData = subCatIDs.zip(subCatNames)
    
    catData = catData.uniq
    subCatData = subCatData.uniq
    
    #getCatsIDs(hash["items"], ids)
    
    open(categoryIDsDir, 'w') do |f|
        catData.each { |x|
            puts "outputting category data = " + x.inspect
            #f << x[0].dump + "\t" + x[1].dump +  "\n" }
            f << x[0].gsub(/\t/, '') + "\t" + x[1].gsub(/\t/, '') +  "\n" }
    end
    
    open(subCategoryIDsDir, 'w') do |f|
        subCatData.each { |x|
            puts "outputting subcategory data = " + x.inspect
            #f << x[0].dump + "\t" + x[1].dump + "\n" }
            f << x[0].gsub(/\t/, '') + "\t" + x[1].gsub(/\t/, '') + "\n" }
    end
    
    puts "Done fetching category and subcategories data"
    
end
