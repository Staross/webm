using HTTPClient.HTTPC
using URIParser



function getPage(url::String)

    r=HTTPC.get(url);
    if( r.http_code != 200 )
        warn("couldn't read url : $url, HTTP code : $r.http_code")
        return (false,lowercase(bytestring(r.body)))
    end

    return (true,lowercase(bytestring(r.body)) )
end

function getHost(url::String)

    u=URI(url)
    return u.host
end

function getLinks(page::String,host::String)

    m = eachmatch(r"href\s*=\s*\"\s*([^\"]+)\s*\""is,page)

    intL = Array(String,0)
    extL = Array(String,0)
    s = []
    i=[]
    for i in m
        s =  i.captures[1] ;

        if length(s)>3 && s[1:4] == "http"

            u = URI( ascii(s) )

            if u.host == host

                push!(intL, utf8(s) )
            else
                push!(extL, utf8(s) )
            end

        end
    end

    return (intL,extL)
end

url = "http://stackoverflow.com/questions/2356694/how-to-check-file-encoding-in-linux-handling-multilingual-scripts";

host = getHost(url)
(sucess,page) = getPage(url);

(intL,extL) = getLinks(page,host)

#ostream=open("tmp.txt", "w+")
#r=HTTPC.get("http://docs.julialang.org/en/release-0.2/manual/parallel-computing/?highlight=remotecall",RequestOptions(ostream=ostream))
#@assert r.http_code == 200
#close(ostream)

#xdoc = LightXML.parse_htmlFile("tmp.txt",encoding="utf-8")

#xroot = root(xdoc)
#body =  get_elements_by_tagname(xroot, "body")[1];

#as =  get_elements_by_tagname(body, "a");

#function getTag(root,tag)

#    out = get_elements_by_tagname(root, tag)

#    for el in child_nodes(root)

#        if is_elementnode(el)
#            out = [out getTag(XMLElement(el),tag)]
#        end

#    end


#    return out
#end

#function waitnexec (id)
#    tname = "async" * string(id)
#    global trigger
#    while (trigger != :go)
#        sleep(0.001)
#    end
#    r=HTTPC.get("http://www.google.com/")
#    @assert r.http_code == 200
#    println(id)
#end

## Run 100 requests in parallel asynchronously
#trigger = :wait
#rrefs = [remotecall(1, waitnexec, i) for i in 1:100]

#trigger = :go
## wait for all of them to finish
#for ref in rrefs
#    wait(ref)
#end
