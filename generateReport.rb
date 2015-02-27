require 'date'
require 'axlsx'


def generateReport(tenant)
    
    todayDate = (Date.today).strftime('%Y-%m-%d')
    
    categoryIDsDir = File.dirname(__FILE__)  + '/CategoryIDs/Categories/'
    subCategoryIDsDir = File.dirname(__FILE__)  + '/CategoryIDs/SubCategories/'
    productIDsDir  = File.dirname(__FILE__)  + '/ProductIDs/'
    emptyCatsDir  = File.dirname(__FILE__)  + '/EmptyCategories/'
    
    discrepanciesCatDir = File.dirname(__FILE__)  + '/Discrepancies/CategoryDiscrepancies/Categories/'
    discrepanciesSubCatDir = File.dirname(__FILE__)  + '/Discrepancies/CategoryDiscrepancies/SubCategories/'
    discrepanciesProdDir = File.dirname(__FILE__)  + '/Discrepancies/ProductDiscrepancies/'
    
    
    newCatPath        = discrepanciesCatDir + tenant + "_category_new_" + todayDate + ".txt"
    removedCatPath    = discrepanciesCatDir + tenant + "_category_removed_" + todayDate + ".txt"
    sameCatPath       = discrepanciesCatDir + tenant + "_category_same_" + todayDate + ".txt"
    
    newSubCatPath     = discrepanciesSubCatDir + tenant + "_subCategory_new_" + todayDate + ".txt"
    removedSubCatPath = discrepanciesSubCatDir + tenant + "_subCategory_removed_" + todayDate + ".txt"
    sameSubCatPath    = discrepanciesSubCatDir + tenant + "_subCategory_same_" + todayDate + ".txt"
    
    newProdPath       = discrepanciesProdDir + tenant + "_product_new_" + todayDate + ".txt"
    removedProdPath   = discrepanciesProdDir + tenant + "_product_removed_" + todayDate + ".txt"
    sameProdPath      = discrepanciesProdDir + tenant + "_product_same_" + todayDate + ".txt"
    
    categoriesPath    = categoryIDsDir + tenant + "_categoryIDs_" + todayDate + ".txt"
    subcategoriesPath = subCategoryIDsDir + tenant + "_subCategoryIDs_" + todayDate + ".txt"
    emptyCatsPath     = emptyCatsDir  + tenant + "_emptyCategories_" + todayDate + ".txt"
    productsPath      = productIDsDir + tenant + "_productIDs_" + todayDate + ".txt"

    
    productSpreadsheetTitle = 'productData'
    productSpreadsheet = Axlsx::Package.new
    productSpreadsheet.use_shared_strings = true
    
    categoriesSpreadsheetTitle = 'categoriesData'
    categoriesSpreadsheet = Axlsx::Package.new
    categoriesSpreadsheet.use_shared_strings = true

   
   def addSheetProduct(spreadSheet, sheetTitle, filePath)
       spreadSheet.workbook do |wb|
           styles = wb.styles
           title   = styles.add_style :sz => 15, :b => true, :u => true
           default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER
           header  = styles.add_style :bg_color => '00', :fg_color => 'FF', :b => true
        
           
           wb.add_worksheet(:name => sheetTitle) do  |ws|
               ws.add_row ['Product Status', 'Product GUID', 'Product SKU', 'Product Path', 'Product Name', 'Product Type', 'ISO image', 'zIndex', 'Number of variants', 'Variants/Parent', 'Variants SKUs'], :style => header
               
               f = File.open(filePath, "r")
               f.each_line do |line|
      
                   ws.add_row [line.split("\t")[0], line.split("\t")[1], line.split("\t")[2], line.split("\t")[3], line.split("\t")[4], line.split("\t")[5], line.split("\t")[6], line.split("\t")[7], line.split("\t")[8], line.split("\t")[9], line.split("\t")[10]], :style => default
               end
           end
       end
   end
   
   def addSheetCategory(spreadSheet, sheetTitle, filePath)
       spreadSheet.workbook do |wb|
           styles = wb.styles
           title   = styles.add_style :sz => 15, :b => true, :u => true
           default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER
           header  = styles.add_style :bg_color => '00', :fg_color => 'FF', :b => true
           
           
           wb.add_worksheet(:name => sheetTitle) do  |ws|
               ws.add_row ['Category GUID', 'Category Path'], :style => header
               
               f = File.open(filePath, "r")
               f.each_line do |line|
              
                   ws.add_row [line.split("\t")[0], line.split("\t")[1]], :style => default
               end
           end
       end
   end

    
    
    addSheetProduct(productSpreadsheet, 'Product', productsPath)
    addSheetProduct(productSpreadsheet, 'Product_same', sameProdPath)
    addSheetProduct(productSpreadsheet, 'Product_new', newProdPath)
    addSheetProduct(productSpreadsheet, 'Product_removed', removedProdPath)

    addSheetCategory(categoriesSpreadsheet, 'Categories', categoriesPath)
    addSheetCategory(categoriesSpreadsheet, 'Subcategories', subcategoriesPath)
    addSheetCategory(categoriesSpreadsheet, 'Empty_cateogires', emptyCatsPath)
    addSheetCategory(categoriesSpreadsheet, 'Categories_same', sameCatPath)
    addSheetCategory(categoriesSpreadsheet, 'Categories_new', newCatPath)
    addSheetCategory(categoriesSpreadsheet, 'Categories_removed', removedCatPath)
    addSheetCategory(categoriesSpreadsheet, 'Subcategories_same', sameSubCatPath)
    addSheetCategory(categoriesSpreadsheet, 'Subcategories_new', newSubCatPath)
    addSheetCategory(categoriesSpreadsheet, 'Subcategories_removed', removedSubCatPath)



productSpreadsheet.serialize File.dirname(__FILE__) + '/Reports/' + tenant + "_" + productSpreadsheetTitle + "_" + todayDate + '.xlsx'

categoriesSpreadsheet.serialize File.dirname(__FILE__) + '/Reports/' + tenant + "_" + categoriesSpreadsheetTitle + "_" + todayDate + '.xlsx'

end



