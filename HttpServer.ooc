import [ConfigLoader,HttpParser]
import threading/Thread
import net/[berkeley,ServerSocket,StreamSocket]

extend StreamSocketReader {
    readUntil : func(str : String) -> String {
        data := "" as String
        while(! data endsWith?(str)) {
            data += read()
        }
        data
    }
}


HttpServer : class {

    config : ConfigLoader
    socket := ServerSocket new()
    
    init : func (=config)
    
    launch : func -> Int {
        if(config verbose?) {
            "Slights server starting up..." println()
        }
        
        socket bind(config port)
        socket listen(5)
    
        if(config verbose?) {
            "Slights started up at port %d" format(config port) println()
        }
        
        while(true) {
            client := socket accept()
            
            // This is kewl :D 
            // We start new thread that launches a closure
            // The closure captures the context and thus we can use the client we just accepted ;D 
            thread := Thread new(|| {
                if(config verbose?) {
                    ("Handling client" + client sock remote toString()) println()
                }
                
                parser := HttpParser new(client in readUntil("\r\n\r\n")) .parse() // An HTTP request ends with \r\n\r\n
                client close() })
            thread start()
        }
        
        0
    }
    
}
