import ConfigLoader
import threading/Thread
import net/[berkeley,ServerSocket,StreamSocket]


HttpServer : class
{
    config : ConfigLoader
    socket := ServerSocket new()
    
    init : func (=config)
    
    launch : func -> Int
    {
        if(config verbose?)
        {
            "Slights server starting up..." println()
        }
        
        socket bind(config port)
        socket listen(5)
    
        if(config verbose?)
        {
            "Slights started up at port %d" format(config port) println()
        }
        
        while(true)
        {
            client := socket accept()
            //thread := Thread new(handleClient)
            //thread start()
            client close()
        }
        
        0
    }
    
    handleClient := func
    {
        "Handling client" println()
    }
}