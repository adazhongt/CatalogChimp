require 'date'
require_relative 'isLeaf'

$TodayDate = (Date.today).strftime('%Y-%m-%d')

#make sure the category is a leaf

def getEmptyCats(env, tenant)
    
    #chage productsPerCatDir name for the rest of the files
    productsPerCatDir   = File.dirname(__FILE__)  + '/ProductIDsPerCat/'
    emptyCategoryDir = File.dirname(__FILE__)  + '/EmptyCategories/' + tenant + "_emptyCategories_" + $TodayDate + ".txt"

    
    emptyCategoryCounter = 0;
    
    puts "Looking for empty categories"
    
    Dir[productsPerCatDir + tenant + '_productIDs_' + '*_' + $TodayDate + '.txt'].each {|productsPerCatFile|
        File.open(productsPerCatFile) {|cat|
            if(cat.read.count("\n") == 0) then
                 
                emptyCatID = productsPerCatFile.scan(/productIDs_(.*?)__/)[0][0]
                if (isLeaf(tenant, emptyCatID) == true) then
                    
                    emptyCategoryCounter = emptyCategoryCounter + 1
                    
                    open(emptyCategoryDir , 'a') do |emptyCategoryDirFile|
                        emptyCategoryDirFile << emptyCatID +  "\n"
                    end
                end
            else
            open(emptyCategoryDir , 'a') 

            end
        }
    
    }

puts "Done. " + emptyCategoryCounter.to_s + " empty categories found."
   
end


