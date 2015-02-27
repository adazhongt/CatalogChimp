def compareFiles(cmpFrom, cmpTo, diffArr, sameArr)
    f1 = File.open(cmpFrom)
    f2 = File.open(cmpTo)
    
    file1lines = f1.readlines
    file2lines = f2.readlines
    
    file1lines.map! {|item| item.chomp}
    file2lines.map! {|item| item.chomp}
    
    file1lines.each do |e|
        
        if(!file2lines.include?(e)) then
            diffArr.push(e)
        else
            sameArr.push(e)
        end
    end
end