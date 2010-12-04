import structs/[ArrayList,MultiMap]
import text/StringTokenizer
import io/File

ConfigLoader : class
{
    verbose? := false
    port := 80
    
    defaultHostFolder := ""
    hosts := MultiMap<String,String> new()
    
    init : func(args : ArrayList<String>)
    {
        for(arg in args)
        {
            // Process command line arguments
            if(arg == "-v" || arg == "--verbose")
            {
                verbose? = true
            }
        }
    
        // Process config file
        configFile := File new("slights.cfg")
        if(configFile file?())
        {
            // Process ... 
            data := configFile read() // read data
            lines := data split('\n') // split into lines
            
            for(line in lines) // loop through lines
            {
                if(line startsWith?("Host:")) // Parse a line like Host: some.host.com, someFolder/
                {
                    line = line substring(5) 
                    line replaceAll(" ","") // Remove spaces (illegal in paths anyway ;o)
                    if(line findAll(",") size == 1) // If we found a comma
                    {
                        comma := line findAll(",") get(0)
                        host := line substring(0,comma)
                        folder := line substring(comma+1)
            
                        hosts[host] = folder // Write the new host
                        // e.g hosts[some.host.com] = someFolder/
                    }
                    else
                    {
                        hosts[line] = defaultHostFolder
                    }
                }
                else if(line startsWith?("Port:"))
                {
                    line = line substring(5)
                    line replaceAll(" ","")
                    port = line toInt()
                }
            }
        
        }
    }
}