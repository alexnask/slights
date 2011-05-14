import structs/[ArrayList,HashMap]
import text/StringTokenizer
import io/File

ConfigLoader : class
{
    verbose? := false
    port := 80
    
    defaultHostFolder := "httpdocs"
    hosts := HashMap<String,String> new()
    cgiLinks := HashMap<String,String> new()
    errorDocs := HashMap<Int,String> new()
    mimeTypes := HashMap<String,String> new()
    
    init : func(args : ArrayList<String>)
    {
        for(arg in args) {
            // Process command line arguments
            if(arg == "-v" || arg == "--verbose") {
                verbose? = true
            }
        }
    
        // Process config file
        configFile := File new("slights.cfg")
        if(configFile file?()) {
            // Process ... 
            data := configFile read() // read data
            lines := data split('\n') // split into lines
            
            for(line in lines) // loop through lines
            {
                if(line startsWith?("Host:")) // Parse a line like Host: some.host.com, someFolder/
                {
                    line = line substring(5) 
                    line = line replaceAll(" ","") // Remove spaces (illegal in paths anyway ;o)
                    if(line findAll(",") size == 1) // If we found a comma
                    {
                        comma := line findAll(",") get(0)
                        host := line substring(0,comma)
                        folder := line substring(comma+1)
            
                        hosts[host] = folder // Write the new host
                        // e.g hosts[some.host.com] = someFolder
                    }
                    else
                    {
                        hosts[line] = defaultHostFolder
                    }
                }
                else if(line startsWith?("Port:")) {
                    line = line substring(5)
                    line = line replaceAll(" ","")
                    port = line toInt()
                } else if(line startsWith?("CGI-Link:")) {
                    line = line substring(9)
                    line = line replaceAll(" ","")
                    if(line findAll(",") size == 1) {
                        comma := line findAll(",") get(0)
                        extention := line substring(0,comma)
                        application := line substring(comma+1)
                        
                        cgiLinks[extention] = application
                    }
                } else if(line startsWith?("ErrorDoc:")) {
                    line = line substring(9)
                    line = line replaceAll(" ","")
                    if(line findAll(",") size == 1) {
                        comma := line findAll(",") get(0)
                        code := line substring(0,comma) toInt()
                        doc := line substring(comma+1)
                        
                        errorDocs[code] = doc
                    }
                }
            }
        
        }
        
        mimeFile := File new("mimetypes.cfg")
        if(mimeFile file?()) {
            data := mimeFile read()
            lines := data split('\n')
            for(line in lines) {
                if(line findAll(":") getSize() > 0) {
                    mimeTypes[line substring(0,line findAll(":")[0])] = line substring(line findAll(":")[0] + 1)
                }
            }
        }
    }
}
