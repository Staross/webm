using HTTPClient.HTTPC
using URIParser

function getPage(url::String)

    println("Getting url: $url")

    r = HTTPC.get(url,RequestOptions(request_timeout=5.0));
    if r.http_code != 200
        warn("couldn't read url : $url, HTTP code : $r.http_code")
        return (false,"")
    end

    if r.headers["Content-Type"] != "text/htm"
        (false,"")
    end

    return (true,lowercase(bytestring(r.body)) )
end


function getHost(url::String)

    u=URI(url)
    return u.host, u.schema
end

function getLinks(page::String,url::String)

    host,schema = getHost(url)

    #m = eachmatch(r"href\s*=\s*[\"|'|'']\s*([^\"']+)\s*[\"|'|'']"is,page) #don't care about a tag

    m = eachmatch(r"<a[^>]*href\s*=\s*[\"|'|'']\s*([^\"']+)\s*[\"|'|''][^>]*[>|/>]"is,page)

    intL = Array(String,0)
    extL = Array(String,0)

    for i in m
        s =  utf8(i.captures[1]);

        if(length(s) < 2)
            continue
        end

        #Full links
        if length(s)>3 && s[1:4] == "http"

            u = URI( ascii(s) )

            if u.host == host
                push!(intL, s )
            else
                push!(extL, s )
            end
            continue
        end

        # // links
        if length(s)>2 && s[1:2] == "//"

            s = string(schema,"://",utf8(s[3:end]))
            u = URI( ascii(s) )

            if u.host == host
                push!(intL, s )
            else
                push!(extL, s )
            end
            continue
        end

        # / links
        if s[1] == '/'

            push!(intL, string(schema,"://",host,"/",utf8(s[2:end])) )
            continue
        end

        # .. links
        if length(s)>2 && s[1:3] == "../"
            #this is where troubles begin
#            s="../"
            s = split(s,"../")
            u = URI( ascii(url) )

            surl = split(u.path,'/')
            surl = surl[1:end-(length(s))] #remove as many element corresponding to "../"

            #rebuild path
            link = ""
            for i=1:length(surl)
                link = string(link, surl[i],'/')
            end
            #finally add the part from the link
            link = string(link, s[end])
            link = string(schema,"://",host,link)

            push!(intL, link)
        end

    end

    intL = cleanLinks(intL)
    extL = cleanLinks(extL)

    intL = unique(intL)
    extL = unique(extL)

    return (intL,extL)
end

function cleanLinks(links)

    ext = ["png","jpg","gif","css","js"]
    isValid = ones(length(links))

    for i = 1:length(links)
        l = links[i]
        for ex in ext
            if length(l) >= length(ex)

                if l[end-length(ex):end] == ".$ex"
                    isValid[i] = 0
                end
            end
        end
    end

    links = links[find(isValid)]

    #remove anchors
    isValid = ones(length(links))
    for i = 1:length(links)
        l = links[i]
        m = match(r"#[^/]*",l)

        if m != nothing
            l = l[1:m.offset-1]
            links[i] = l
        end

    end

    return links
end


url = "http://www.reddit.com/r/adviceanimals/comments/21lrul/i_feel_bad_so_i_have_to_make_up_for_it/"

host,schema = getHost(url)
sucess,page = getPage(url);

intL,extL = getLinks(page,url)

#println(intL)

if(true)

for i in 1:min(30,length(intL))
    rrefs = remotecall(1, getPage, intL[i])
    sleep(0.01)
end

end

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
