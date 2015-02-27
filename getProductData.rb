require 'date'
require 'net/http'
require 'json'

$TodayDate = (Date.today).strftime('%Y-%m-%d')


def fetchProductData(url, tenant, prodData, fileName, catPath)
    
    puts "url: " + url
    if(tenant=="ezhome")
        temptimestamp = Time.now.to_i
        timestamp = temptimestamp.to_s+"000"
        sha256 = Digest::SHA256.new
        secret_str=timestamp+"adsk-ezhome"
        digest =sha256.hexdigest(secret_str)
        uri= URI.parse(url)
        http = Net::HTTP.new(uri.host,uri.port)
        request=Net::HTTP::Get.new(uri.request_uri,{'hs_ts' => timestamp, 'hs_secret' => digest})
        resp= http.request(request)
    else
	resp = Net::HTTP.get_response(URI.parse(url))
    end
    
    hash  =  JSON.parse(resp.body)
    
    prodStatus         = Array.new
    prodIds            = Array.new
    prodSKU            = Array.new
    prodNames          = Array.new
    prodImage          = Array.new
    prodNumVariations  = Array.new
    prodVariationsIDs  = Array.new
    prodVariationsSKUs = Array.new
    prodType           = Array.new
    prodZIndex         = Array.new
   
     hash = hash["items"]
    
    if (hash == nil || hash.length == 0) then
        
        open($productDataDir1 + fileName + catPath + "__" +  $TodayDate + ".txt", 'a') {}
        open($productDataDir2 + fileName + $TodayDate + ".txt", 'a') {}
        
        else
        
        
        hash.each{|i|
            
            case i["status"].to_s
                when "0"
                prodStatus.push('Deleted')
                when "1"
                prodStatus.push('Active')
                when "2"
                prodStatus.push('Inactive')
                when "3"
                prodStatus.push('Private')
            end
            
            
        }
        
        
        
        hash.each{|i| prodIds.push(i["id"])}
        hash.each{|i| prodNames.push(i["name"])}
        hash.each{|i| prodImage.push(i["images"])}
        hash.each{|i| prodType.push(i["productType"])}
        hash.each{|i| prodZIndex.push(i["zIndex"])}
        
        hash.each{|i|
            if(i["ticket"].length != 0 && i["ticket"]["sku"] != nil) then
                prodSKU.push(i["ticket"]["sku"].to_s)
                else
                
                prodSKU.push(nil)
                
            end
        }
        
        
        
        hash.each{|i|
            if(i["variations"].length != 0) then
                
                tempArr = Array.new
                tempArr2 = Array.new
                
                i["variations"]["color"].each{|i2|
                    tempArr.push(i2["id"])
                    tempArr2.push(i2["sku"])}
                prodNumVariations.push(tempArr.length)
                prodVariationsIDs.push(tempArr.dup)
                prodVariationsSKUs.push(tempArr2.dup)
                
                
                else
                prodNumVariations.push(1)
                prodVariationsIDs.push(nil)
                prodVariationsSKUs.push(nil)
                
                
            end
        }
        
        
    end
    
    #why store in arrays. Refactor later
    prodData.concat(prodStatus.zip(prodIds, prodSKU, prodNames, prodType, prodImage, prodZIndex, prodNumVariations, prodVariationsIDs, prodVariationsSKUs))
    puts "Item data: " + prodData.inspect
    
    
    #for in for two loops
    prodVariationsIDs.each_with_index{|varIDs, index|
        
        if(varIDs != nil) then
            
            varIDs.each{|id|
                fetchVariantData("http://fp-hsm-mw.homestyler.com:80/api/rest/v2.0/product/" + prodIds[index]+ "/variation/" + id + "?t=" + tenant + "&l=en_US", prodIds[index], id, tenant, prodData, fileName, catPath, true)
                
            }
            
        end
        
        
    }
    
    
    
    if(prodIds.length == 0) then
        return true
        
        else
        
        return false
        
    end
    
    
end


def fetchVariantData(url, parentID, varID, tenant, prodData, fileName, catPath, isVariant)
    
    if(parentID == varID) then return end
    
    puts "url: " + url
    
    resp = Net::HTTP.get_response(URI.parse(url))
    
    hash  =  JSON.parse(resp.body)
    
    prodStatus         = Array.new
    prodIds            = Array.new
    prodSKU            = Array.new
    prodNames          = Array.new
    prodImage          = Array.new
    prodNumVariations  = Array.new
    prodVariationsIDs  = Array.new
    prodVariationsSKUs = Array.new
    prodType           = Array.new
    prodZIndex         = Array.new
    
    
    hash = hash["item"]
    
    
    if (hash == nil || hash.length == 0) then
        
        open($productDataDir1 + fileName + catPath + "__" +  $TodayDate + ".txt", 'a') {}
        open($productDataDir2 + fileName + $TodayDate + ".txt", 'a') {}
        
        else
        
        
        
        
        case hash["status"].to_s
            when "0"
            prodStatus.push('Deleted')
            when "1"
            prodStatus.push('Active')
            when "2"
            prodStatus.push('Inactive')
            when "3"
            prodStatus.push('Private')
        end
        
        
        
        prodIds.push(varID)
        prodNames.push(hash["name"])
        prodImage.push(hash["images"])
        prodType.push(hash["productType"])
        prodZIndex.push(hash["zIndex"])
        
        
        if(hash["ticket"].length != 0 && hash["ticket"]["sku"] != nil) then
            
            prodSKU.push(hash["ticket"]["sku"].to_s)
            else
            prodSKU.push(nil)
        end
        
        
        prodNumVariations.push("-")
        prodVariationsIDs.push(parentID)
        prodVariationsSKUs.push("-")
        
        
        
        prodData.concat(prodStatus.zip(prodIds, prodSKU, prodNames, prodType, prodImage, prodZIndex, prodNumVariations, prodVariationsIDs, prodVariationsSKUs))
        puts "Var data: " + prodData.inspect
        
        
    end
end





def getProductData(env, tenant, status)
    
    #move to another directory or rename directory
    $productDataDir1 = File.dirname(__FILE__)  + '/ProductIDsPerCat/'
    $productDataDir2 = File.dirname(__FILE__) + '/ProductIDs/'
    categoryIDsDir = File.dirname(__FILE__)  + '/CategoryIDs/Categories/' + tenant + '_categoryIDs_' + $TodayDate + ".txt"
    subCategoryIDsDir = File.dirname(__FILE__)  + '/CategoryIDs/SubCategories/' + tenant + '_subCategoryIDs_' + $TodayDate + ".txt"
    
    
    
    def getProductIds(path, fileName, env, tenant, status)
        
        sleepTimer = 3;
        # retries    = 0;
        
        f = File.open(path, "r")
        f.each_line do |line|
            
            catID   = line.split("\t")[0].to_s.chomp
            catPath = line.split("\t")[1].to_s.chomp
            catPath.gsub!("/", ' ')
            
            puts "fetching product IDs for category = " + catID + " path: " + catPath
            
            
            offset = 0
            limit  = 500
            
            puts "isLeaf: " + isLeaf(tenant, catPath).to_s
            if isLeaf(tenant, catPath) then
                
                
                while true do
                   
		    if(tenant=="ezhome")
        		if(env=="prod")
                		base_URL="http://3d.juran.cn/"
        			api = "api/rest/v2.0/category/"+catID+"/product?t="+tenant+"&f=c&offset="+offset.to_s+"&limit="+ limit.to_s + "&status=" + status

        		else
                		puts "EZHome staging is not supprted for now!"
        		end
   		   elsif(env != "prod") then
                        base_URL = "http://fp-hsm-mw." + env + ".homestyler.com:80/"
                   else
                        base_URL = "http://fp-hsm-mw.homestyler.com:80/"
			api = "api/rest/v2.0/category/" + catID +  "/product?t=" + tenant + "&l=en_US&offset=" + offset.to_s + "&limit=" + limit.to_s + "&status=" + status
                    end
                    url= base_URL + api
                    
                    prodData = Array.new
                    
                    if (fetchProductData(url, tenant, prodData, fileName, catPath)) then break end
                    
                    prodData.each { |x|
                        
                        open($productDataDir1 + fileName + catPath + "__" +  $TodayDate + ".txt", 'a') do |f|
                            f << x[1] + "\r\n"
                        end
                        
                        open($productDataDir2 + fileName + $TodayDate + ".txt", 'a') do |f|
                            puts "outputting product data = " + x.inspect
                            
                            # f << x[0].dump + "\t" + catPath.dump + "\t" + x[1].dump  + "\t" + x[2].dump + "\t" + x[3][0].to_s.dump + "\t" + x[4].to_s.dump  + "\t" + x[5].to_s.dump  + "\t" + x[6].to_s.dump + "\n"
                            f << x[0].gsub(/\t/, '') + "\t" +  x[1].gsub(/\t/, '') + "\t" + x[2].to_s.gsub(/\t/, '') + "\t" + catPath.gsub(/\t/, '') + "\t" + x[3].gsub(/\t/, '')  + "\t" + x[4].gsub(/\t/, '') + "\t" + x[5][0].to_s.gsub(/\t/, '') + "\t" + x[6].to_s.gsub(/\t/, '')  + "\t" + x[7].to_s.gsub(/\t/, '')  + "\t" + x[8].to_s.gsub(/\t/, '') + "\t" + x[9].to_s.gsub(/\t/, '') + "\n"
                            
                        end
                    }
                    
                    sleep(sleepTimer)
                    
                    offset = limit + offset
                end
                
                end
                
            end
            
            
            
            f.close
            
            
        end
        
        #  getProductIds(categoryIDsDir, tenant + "_productIDs_", env, tenant)
        #puts "DONE fetching product IDs for all categories"
        getProductIds(subCategoryIDsDir, tenant + "_productIDs_", env, tenant, status)
        puts "DONE fetching product IDs for all sub categories"
        
    end
    
    
    
    
    
    
    
    
    
