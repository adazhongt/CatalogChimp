require 'date'
require_relative 'compareFiles'
require_relative 'writeArrToFile'

def getDiscrepancies(tenant)
    
    categoryIDsDir = File.dirname(__FILE__) + '/CategoryIDs/Categories/'
    subCategoryIDsDir = File.dirname(__FILE__)  + '/CategoryIDs/SubCategories/'
    productIDsDir  = File.dirname(__FILE__)  + '/ProductIDs/'
    discrepanciesDir = File.dirname(__FILE__) + '/Discrepancies/'
    
    $TodayDate = (Date.today).strftime('%Y-%m-%d')
    $YesterdayDate = (Date.today-1).strftime('%Y-%m-%d')
    
    def getDiscrepancies(cmpDir, cmpFrom, cmpTo, writeTo, type)
        
        same    = Array.new
        removed = Array.new
        new     = Array.new
        
        # bad interface design for "same" causes duplicates
        compareFiles(cmpDir + cmpFrom, cmpDir + cmpTo, removed, same, -1)
        compareFiles(cmpDir + cmpTo, cmpDir + cmpFrom, new, same, -1)
        
        writeArrToFile(writeTo, type+"_same_"    + $TodayDate + ".txt", same.uniq)
        writeArrToFile(writeTo, type+"_new_"     + $TodayDate + ".txt", new.uniq)
        writeArrToFile(writeTo, type+"_removed_" + $TodayDate + ".txt", removed.uniq)
        
    end
    
    
    puts "Comparing today's categories with yesterday's"
    
    getDiscrepancies(categoryIDsDir, tenant + "_categoryIDs_" + $YesterdayDate + ".txt", tenant + "_categoryIDs_" + $TodayDate + ".txt", discrepanciesDir + "CategoryDiscrepancies/Categories/", tenant + "_category")
    
    puts "Done comparing category IDs."
    
    
    
    puts "Comparing today's sub categories with yesterday's"
    
    getDiscrepancies(subCategoryIDsDir, tenant + "_subCategoryIDs_" + $YesterdayDate + ".txt", tenant + "_subCategoryIDs_" + $TodayDate + ".txt", discrepanciesDir + "CategoryDiscrepancies/SubCategories/", tenant + "_subCategory")
    
    puts "Done comparing category IDs."
    
    
    
    puts "Comparing today's products with yesterday's"
    
    getDiscrepancies(productIDsDir, tenant + "_productIDs_" + $YesterdayDate + ".txt", tenant + "_productIDs_" + $TodayDate + ".txt", discrepanciesDir + "ProductDiscrepancies/", tenant + "_product")
    
    puts "Done comparing product IDs."
    
end




