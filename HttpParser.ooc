import structs/[ArrayList,HashMap]

extend String {
    split : func(str : String) -> ArrayList<String> {
        ret := ArrayList<String> new()
        indexes := this findAll(str)
        prev : SizeT = 0
        if(indexes getSize() > 0) {
            for(index in indexes) {
                ret add(substring(prev,index))
                prev = index + str length()
            }
            ret add(substring(prev))
        } else {
            ret add(this)
        }
        ret
    }
}


HttpParser : class {
    headers := HashMap<String,String> new()
    getParams := HashMap<String,String> new()
    raw : String
    method : String
    path : String
    protocol : String
    
    init : func(=raw)
    
    parse : func {
        lines := raw split("\r\n")
        if(lines getSize() > 0) {
            // Ugly parsing, w/e I dont see how else I coudl implement that :P 
            indexes := lines[0] findAll(" ")
            if(indexes getSize() == 2) {
                method = lines[0] substring(0,indexes[0])
                path = lines[0] substring(indexes[0]+1,indexes[1])
                protocol = lines[0] substring(indexes[1]+1)
                
                if(path findAll("?") getSize() > 0) {
                    whole := path
                    path = whole substring(0,whole findAll("?")[0])
                    whole = whole substring(whole findAll("?")[0] + 1)
                    
                    parts := whole split("&")
                    for(part in parts) {
                        if(part findAll("=") getSize() > 0) {
                            getParams[part substring(0,part findAll("=")[0])] = part substring(part findAll("=")[0]+1)
                        } else {
                            getParams[part] = ""
                        }
                    }
                }
            }
            lines removeAt(0)
        }
        
        for(line in lines) {
            indexes := line findAll(":")
            if(indexes getSize() > 0) {
                headers[line substring(0,indexes[0])] = line substring(indexes[0]+2) // Also remove the space before the header value (+2 instead of +1 for just : ) -> This code is very strict and your request must be 100% HTTP/1.1 compliant so it can parse it correctly
            }
        }
    }
}
