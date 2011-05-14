import HttpServer
import ConfigLoader
import structs/ArrayList

main : func (args : ArrayList<String> ) -> Int {
    config := ConfigLoader new(args)
    server := HttpServer new(config)
    
    if(config verbose?) {
        "Slights will launch in verbose mode" println()
    }
    
    server launch() // Returns an Int
}
