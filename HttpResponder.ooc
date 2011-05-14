import [ConfigLoader,HttpParser,HttpResponse]
import net/[berkeley,StreamSocket,ServerSocket] // ServerSocket for ReaderWriterPair
import structs/[HashMap,List] // HashMap for access to []/[]= operators
import io/File
import os/[Process,Pipe]

HttpResponder : class {
    config : ConfigLoader
    parser : HttpParser
    client : ReaderWriterPair
    
    contentType := "text/html; charset=UTF-8"
    
    init : func(data : String,=config,=client) {
        parser = HttpParser new(data) .parse()
    }
    
    respond : func {
        body : String = ""
        code := 200
        requestPath := config hosts[parser headers["Host"]] + parser path // Get the relative dir dto requested document
        requestDoc := File new(requestPath)
        if(requestDoc file?()) {
            // Do stuff for a file...
            body = getFile(requestPath)
        } else if(requestDoc dir?()) {
            if(! File new(requestPath + ".listlock") exists?() && ! File new(requestPath + "/.listlock") exists?()) {
                body = getDir(requestDoc)
            } else {
                code = 403
            }
        } else {
            // If it is not a file nor a directory, what is it? :o 
            // Well it doesnt exist smartass xO
            code = 404
        }
        
        if(config errorDocs[code] != null) {
            // The first guy that sets an errorDoc for 200 and complains, I shoot him in the head
            body = getFile(config errorDocs[code])
        }
        // Do stuff with parsed data, construct body inside the "body" var
        response := HttpResponse new(body) // Content length is calculated automatically
        response code = code // Set response code
        response headers["Content-type"] = contentType // Set content type
        response build() .send(client out)
    }
    
    getFile : func ~str(path : String) -> String {
        file := File new(path)
        getFile(file)
    }
    
    getFile : func ~file(file : File) -> String {
        if(file file?()) {
            dots := file name() findAll(".")
            if(dots getSize() > 0) {
                ext := file name() substring(dots get(dots getSize() - 1) + 1) // get file extention :D
                if(config mimeTypes[ext] != null) {
                    contentType = config mimeTypes[ext]
                }
                if(config cgiLinks[ext] != null) { // Hey lets start a cgi app =D
                    // Start cgi app here :P
                    // return what it returns here
                    
                    env := HashMap<String,String> new()
                    env["QUERY_STRING"] = parser queryString
                    
                    proc := Process new([config cgiLinks[ext],file getPath()],env) .setStdout(Pipe new()) .setStdin(Pipe new())
                    
                    data : String = ""
                    proc communicate(null,data&,null) // Replace first null with post data
                    
                    return data
                }
            }
            // TODO: add contentType changing based on extention (some external file with all mime types maybe? :/)
            return file read() // Else, well, just read the god-damn file :P 
        }
        ""
    }
    
    getDir : func~str(path : String) -> String {
        dir := File new(path)
        getDir(dir)
    }
    
    getDir : func~dir(dir : File) -> String {
        if(dir dir?()) {
            // Directory listing (actually check for index first)
            ret : String = "<!DOCTYPE html>
                                <html><head><title>Directory listing - " + parser path + "</title></head>
                                    <body><h1>Listing directory " + parser path + "</h1><br/><br/>"
            children := dir getChildrenNames()
            for(child in children) {
                if(child startsWith?("index.")) {
                    return getFile(dir getPath() + child)
                } else {
                    ret += "<a href=\"" + parser path substring(1) + "/" + child + "\">" + child + "</a><br/>"
                }
            }
            ret += "</body></html>"
            return ret
        }
        ""
    }
}
