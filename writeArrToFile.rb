def writeArrToFile(writeDir, fileName, discrepanciesArr)
    
    open(writeDir + fileName, 'w') do |f|
            discrepanciesArr.each     { |x|
                f << x.to_s.chomp + "\r\n"}
    end
end
    
#add puts that says writing to 