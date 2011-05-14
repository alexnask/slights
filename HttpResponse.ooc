import structs/[HashMap,ArrayList]
import net/[berkeley,StreamSocket,ServerSocket] // ServerSocket for ReaderWriterPair

HttpResponse : class {
    response : String = ""
    code : Int = 200
    body : String
    
    headers := HashMap<String,String> new()
    
    init : func(=body) {
        headers["Content-length"] = body length() toString()
    }
    
    build : func {
        response += "HTTP/1.1 "
        if(code == 200) {
            response += "200 OK"
        } else if(code == 404) {
            response += "404 NOT FOUND"
        } else if(code == 401) {
            response += "401 UNAUTHORIZED"
        } else if(code == 403) {
            response += "403 FORBIDDEN"
        }
        // Others
        response += "\r\n"
        headers each(|key,value| { response += key + ": " + value + "\r\n" })
        response += "\r\n"
        response += body
    }
    
    send : func(out : StreamSocketWriter) {
        out dest send(response)
    }
}
