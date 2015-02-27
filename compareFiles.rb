def compareFiles(cmpFrom, cmpTo, diffArr, sameArr, pos)
    f1 = File.open(cmpFrom)
    f2 = File.open(cmpTo)
    
    file1lines = f1.readlines
    file2lines = f2.readlines
    
    
    file1lines.map! {|item| item.chomp}
    file2lines.map! {|item| item.chomp}
    

#puts pos

    if(pos > -1) then
        
        tempCmpFrom = file1lines.map {|item| item.split("\t")[pos]}
        tempCmpTo = file2lines.map {|item| item.split("\t")[pos]}
        
        #puts tempCmpFrom.length
        #puts tempCmpTo.length
        
        else
        
        tempCmpFrom = file1lines
        tempCmpTo = file2lines
        
        
    end
    
    #add continue for Nir 
    
    tempCmpFrom.each_with_index do |e, index|
        
        if(!tempCmpTo.include?(e)) then
            diffArr.push(file1lines[index])
            else
            sameArr.push(file1lines[index])
        end
    end
end