require 'net/http'
require 'json'

def init(env, tenant, productGUID) #private func?
   
   base_URL = "http://catalog-be." + env + "." + tenant + ".com"
    api      = "/v1.0/products?lang=en_US&t=hsm&ids=" + productGUID
    
    url = base_URL + api
    
    resp = Net::HTTP.get_response(URI.parse(url))
    
    hash  =  JSON.parse(resp.body)
    
    return hash

end

def getProductName(env, tenant, productGUID)
    
    hash = init(env, tenant, productGUID)
    
    hash["products"].each{|i| return i["defaultName"]} #precondition = there's only 1 default name

end

def getProductPath(env, tenant, productGUID)
    
    hash = init(env, tenant, productGUID)
    
    catArr = Array.new
    
    productPath = ""
    
    hash["products"].each{|i| i["categories"].each{|i2| catArr.push(i2["name"])} }
    
    catArr.each_with_index do |i, index|
        if index == catArr.length - 1
            productPath += i
        else
            productPath += i + ">>"
        end
    end


    puts productPath + ">>" +  getProductName(env, tenant, productGUID)
    
end

def getProductImage(env, tenant, productGUID)
    
    hash = init(env, tenant, productGUID)
    
    hash["products"].each{|i| return i["files"][2]["url"] }

end


