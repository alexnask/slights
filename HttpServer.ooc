import [ConfigLoader,HttpResponder]
import threading/Thread
import net/[berkeley,ServerSocket,StreamSocket]

extend StreamSocketReader {
    readUntil : func(str : String) -> String {
        data := "" as String
        while(!data endsWith?(str)) {
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
                
                responder := HttpResponder new(client in readUntil("\r\n\r\n"),config,client) .respond() // Setup a responder, give it the info we have gathered so far and tell it to respond to client
                
                // Close connection
                client close() })
            thread start()
        }
        
        0
    }
    
}
