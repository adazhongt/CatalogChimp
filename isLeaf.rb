require 'date'

def isLeaf(tenant, catPath)
    
    subCategoryIDsDir = File.dirname(__FILE__)  + '/CategoryIDs/SubCategories/' + tenant + '_subCategoryIDs_' + (Date.today).strftime('%Y-%m-%d') + ".txt"
    
    f = File.open(subCategoryIDsDir, "r")
    subCatList = f.readlines
    
    
    subCatList.map! {|item| item.gsub("/", ' ')}

    
    subCatList.each do |e|
        
        if(e.chomp.include?(catPath + ">>")) then
            return false
        end
        
    end
    
    return true
    
end


