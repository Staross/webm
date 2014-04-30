reload("htmlEntities")

using HTTPClient.HTTPC
using URIParser
using Mustache
using Winston

include("typeDef.jl")

#callback for HTTPC.get, allow to use libCURL options
function customize_curl(curl)
  cc = LibCURL.curl_easy_setopt(curl, LibCURL.CURLOPT_USERAGENT, "Mozilla/5.0 (Windows NT 6.1; rv:28.0) Gecko/20100101 Firefox/28.0")
  if cc != LibCURL.CURLE_OK
    error ("CURLOPT_USERAGENT failed: " * LibCURL.bytestring(curl_easy_strerror(cc)))
  end  
end

function getPage(url::String;debug=false)

    #println("Getting url: $url")

    try

        r = HTTPC.get(url,RequestOptions(
                        request_timeout=5.0,
                        callback=customize_curl    
                    ))

        if r.http_code != 200
            code = r.http_code
            if debug
                warn("couldn't read url : $url, HTTP code : $code")
            end
            return (false,"")
        end

        heads = ["Content-Type","Content-type","content-type","content-Type"]
        for h in heads
            if haskey(r.headers,h) 
                if match(r"text/htm",lowercase(r.headers[h])) == nothing  
                    return (false,"")
                end
            end
        end

        page = bytestring(r.body)
        page = removeHTMLEntities(page)

        return (true, page)

    catch err
        if debug
            println(err)
        end
        return (false,"")
    end   
end


function getHost(url::String)

    try
        u = URI(ascii(url))
        host = lowercase(u.host)
        if false && length(host)>3 #you can't do that, some servers don't like it
           if host[1:4] != "www."
                host = string("www.",host)
           end 
        end
        return host, lowercase(u.schema)

    catch
        warn("getHost failed to parse: $url")
        return (String[],String[])
    end
end

function getLinks(page::String,url::String)

    host,schema = getHost(url)

    #m = eachmatch(r"href\s*=\s*[\"|'|'']\s*([^\"']+)\s*[\"|'|'']"is,page) #don't care about a tag

    matches = eachmatch(r"<a[^>]*href\s*=\s*[\"|'|'']\s*([^\"']+)\s*[\"|'|''][^>]*[>|/>]"is,page)

    intL = Array(String,0)
    extL = Array(String,0)

    for m in matches
        s =  utf8(m.captures[1])

        #remove whitespaces
        s = replace(s,r"\s+"is,"")

        if(length(s) < 2)
            continue
        end

        #Full links
        if length(s)>3 && lowercase(s[1:4]) == "http"

            shost, sc = getHost(s)

            if host == shost
                push!(intL, s )
            else
                push!(extL, s )
            end
            continue
        end

        # // links
        if length(s)>2 && s[1:2] == "//"

            s = string(schema,"://",utf8(s[3:end]))
            shost, sc = getHost(s)

            if shost == host
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
            continue
        end

        #nothing links
        if match(r"[a-z0-9]"is,string(s[1])) != nothing  #already tested the other possibilities above, just check if alphanumeric

            if(s[end] == '/')
                push!(intL, string(url,utf8(s)) )
            else
                surl = split(url,'/')
                surl = surl[1:end-1]
                link = string(["$part/" for part in surl]...)
                push!(intL,string(link,utf8(s)))
            end
            continue
        end

    end

    intL = cleanLinks(intL)
    extL = cleanLinks(extL)

    intL = unique(intL)
    extL = unique(extL)

    return (intL,extL)
end

function cleanLinks(links)

    ext = ["png","jpg","gif","css","js","pdf"]
    isValid = ones(length(links))

    for i = 1:length(links)
        l = lowercase(links[i])

        #look for email links
        if( match(r"mailto:[\w-]+@[\w-]+.\w+"is,l) != nothing)
            isValid[i] = 0
            continue
        end

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
        m = match(r"#[^/]*"is,l)

        if m != nothing
            l = l[1:m.offset-1]
            links[i] = l
        end

    end

    return links
end

function writeInFile(var::Array{String,1},file::String)

    f=open(file,"w")
    for i=1:length(var) println(f,var[i]) end
    close(f)
end

function removeHttp(url)

    if length(url) > 7 
        if  lowercase(url[1:7]) == "http://"
            url = url[8:end]
        end
    end
    return url
end

function getHash(url::String)

    url = convert(Int64,hash(url))
    url = string(url)

    return url
end

function Base.write(url::String,d::Dict{UTF8String, Int64})

    url = getHash(url)
    c = collect(values(d)) 
    w = collect(keys(d)) 

    f=open( "data/$(url)_w" ,"w")
    writecsv(f,w)
    close(f)

    f=open( "data/$(url)_c" ,"w")
    write(f,c)
    close(f)

end

function Base.read(url::String)
println(url)
    url = getHash(url)


    f=open( "data/$(url)_w","r")
    if !eof(f)
        w = readcsv(f,UTF8String)
    else
        w = []
    end
    close(f)
    println(length(w))

    c = Array(Int64,length(w))
    f=open( "data/$(url)_c","r")
    for i=1:length(w)
        c[i] = read(f,Int64)        
    end
    close(f)

    d = Dict{UTF8String, Int64}()

    for i = 1:length(w)

        d[w[i]] = c[i]
    end

    return d
end

function writeInFile(d::Dict{UTF8String, Int64},file::String)

    f=open(file,"w")

    c = collect(values(d)) 
    k = collect(keys(d)) 

    idx = sortperm(c)

    for i = 1:length(idx)
        w = k[idx[i]]
        n = c[idx[i]]
        println(f,"$n : $w")
    end 
    close(f)
end


function getWords1(page)

    #remove javascript, css, ..
    ex = r"<\s*script[^<]*?>.*?</\s*script\s*>"is;
    page = replace(page,ex,"")

    ex = r"<\s*style[^<]*?>.*?</\s*style\s*>"is;
    page = replace(page,ex,"")
    page = replace(page,r"<!--.*?-->"is,"")

    # remove tags
    ex = r"<[^>]*>"is;
    page = replace(page, ex, "");

    #remove some html tags
    page = replace(page, "&nbsp;", " ");
    page = replace(page, "&quot;", "");
    page = replace(page, "&#8217;", "'");
    

    page = replace(page, r"[^\w\n\s\t-]"is, " "); #remove non-text

    page = replace(page, r"\s+"," ");

    println(page)

end

function cleanPage(s::String)

    s = lowercase(s)

    #remove javascript, css, ..
    ex = r"<\s*script[^<]*?>.*?</\s*script\s*>"is;
    s = replace(s,ex,"")

    ex = r"<\s*style[^<]*?>.*?</\s*style\s*>"is;
    s = replace(s,ex,"")
    s = replace(s,r"<!--.*?-->"is,"")

    s = replace(s,r"\n"," ")
    s = replace(s,r"\t"," ")
    s = replace(s,r"â€”"," ")#long dash

    #remove some html tags
    s = replace(s, "&nbsp;", " ");
    s = replace(s, "&quot;", "");
    s = replace(s, "&gt;", ">");
    s = replace(s, "&lt;", "<");
    s = replace(s, "&raquo;", "'");
    s = replace(s, "&laquo;", "'");
    
    for i=16:22
        s = replace(s, Regex("&#82$i;","is"), "'");
    end

    #remove some common tags
    tags = ["a","i","b","p","span","li","ul","h1","h2","h3","tt","cite","td","tr","table","div"]
    for t in tags
        s = replace(s, Regex("<\s*$t[^>]*>","is"), " ")
        s = replace(s, Regex("<\s*/\s*$t\s*>","is")," ")
    end

    s = replace(s, r"\"","'")

    #remove punctuation
    s = replace(s, r","," ")
    s = replace(s, r"\."," ")
    s = replace(s, r"\?"," ")
    s = replace(s, r"\s+"," ")

    return s
end

function getWords(s;debug=false)

    s = cleanPage(s)

    #split
    ex = r"([A-Z0-9a-z\s.,!?'\"$&:;\-\(\)%\*\+]*)"is
    mat = matchall(ex,s)

    N = length(mat)

    phraseLength         = zeros(N);
    meanWordLength       = zeros(N);
    fractionOfNumbers    = zeros(N);
    fractionOfWeirdSigns = zeros(N);

    for i=1:N

        p = mat[i]

        if length(p) == 0
            continue
        end

        Ntot = length( replace(p,r"\s+","") )

        #compute fraction of numbers and of weird signs
        tmpNoNumbers = replace(p, r"[^a-z]"," ");#remove everything except A-Z

        p = replace(p, r"[^a-z0-9]", " ");#remove everything except A-Z and numbers

        N1 = length( replace(tmpNoNumbers,r"\s+","") )
        N2 = length( replace(p,r"\s+","") )

        if N2>0 
            fractionOfNumbers[i] = (N2-N1)/N2
        end

        if Ntot>0 
            fractionOfWeirdSigns[i] = (Ntot-N2)/Ntot
        end

        words = split(p,r"\s+")

        phraseLength[i] = length(words)

        if !isempty(words)
            for j=1:length(words)
                meanWordLength[i] = meanWordLength[i] + length(words[j])
            end

            meanWordLength[i] = meanWordLength[i]/length(words)
        end

    end

    phrases = find( 
             (phraseLength .> 10) & (meanWordLength .< 10) & 
             (meanWordLength .> 3) & (fractionOfNumbers .< 0.1) & 
             (fractionOfWeirdSigns .< 0.1 ) )

    phrases = unique(mat[phrases])

    out = String[]
    for p in phrases

        p = replace(p,r"[^a-z0-9-'']"," ")
        p = split(p, r"[\s*\t*]")

        for w in p
            if !isempty(w) && w != " " && w != "-"
                push!(out,utf8(w))
            end
        end

    end

    if debug
        writeInFile(out,"tmp.txt")
    end

    return out
end

function sortDict(d)#pretty much useless

    c = collect(values(d)) 
    k = collect(keys(d)) 

    idx = sortperm(c)

    d = Dict{UTF8String, Int64}()
    
    for i = 1:length(idx)
        d[k[idx[i]]] = c[idx[i]]
    end 

    return d
end

function countWords(words)

    d = Dict{UTF8String, Int64}()

    for w in words

        if haskey(d,w)             
            d[w] = d[w]+1
        else
            d[w] = 1
        end    
    end

    return d
end



function exploreSite(depth,maxPages,url,alreadySeenLinks,parentUrl;sleepTime = 0.2)

    sucess,page = getPage(url,debug = true)

    if !sucess
        return (String[], String[],webmap.sitePage(url,parentUrl,depth,sucess))
    end

    words = getWords(page)

    extL = String[]
    sitePages = webmap.sitePage[]
    push!(sitePages, webmap.sitePage(url,parentUrl,depth,sucess))

    if depth > 0 

        intL,extL = getLinks(page,url)
                
        intL = setdiff(intL,alreadySeenLinks)
        
        if isempty(intL) 
           return  (words, extL)
        end
        
        p = randperm(length(intL))
        p = p[1:min(maxPages,length(intL))]
        
        alreadySeenLinks = [alreadySeenLinks; intL[p]]
        
        rrefs = []
        for i=1:length(p)

            #tmpW, tmpL = exploreSite(depth-1,maxPages,intL[p[i]],alreadySeenLinks)
 
            rrefs = [rrefs; remotecall(1, exploreSite,depth-1,maxPages,intL[p[i]],alreadySeenLinks,url)]
            #wait(rrefs[i])
            sleep(sleepTime)
        end

        for r in rrefs
           wait(r)
        end

        for r in rrefs
            tmpW, tmpL, tmpPage = fetch(r)

            words = [words; tmpW]
            extL = [extL; tmpL]
            sitePages = [sitePages; tmpPage]
        end 
        
    end

    return  (words, extL,sitePages)
end


function crawl(depth,maxPages,url)

    links = [url];

    if depth > 0 
        
        sucess,page = getPage(url,debug = false)

        if !sucess
            return links
        end
        
        intL,extL = getLinks(page,url)
        
        if isempty(extL) 
           return
        end
          
        p = randperm(length(extL));
        p = p[1:min(maxPages,length(extL))];

        rrefs = []
        for i=1:length(p)
            rrefs = [rrefs;
                     remotecall( 1,crawl,depth-1,maxPages,extL[p[i]] )
                    ]
        end
        for r in rrefs
           wait(r)
        end
        for r in rrefs
            tmpL = fetch(r)
            links = [links; tmpL]
        end 
    end

    return links
end

function plotExploreSite(sitePages,depth)

    h = FramedPlot( xrange=(0,1), yrange=(0,1))


    i=0;
    for p in sitePages
        col = 0x000000
        if !p.success
            col = 0xcc0000
        end

        th = 2*pi*rand()
        u = URI(  ascii(p.url) )

        add(h, PlotLabel(0.3  + 0.5*p.depth/depth,i/length(sitePages), u.path ,color=col,size=1))
        i += 1
    end

    display(h)

end

function printExploreSite(sitePages,depth,url)

        tpl = "
        <html>
        <head>
        <title>{{Title}}</title>
        </head>
        <body>
                <p>{{Title}}</p>
                <table>
                        <tr><th>name</th><th>depth</th></tr>
                        {{#pages}}
                        <tr><td><a href=\"{{parent}}\" style=\"color: {{color}}\"> {{url}} </a></td><td>{{depth}}</td></tr>
                        {{/pages}}
                </table>
        </body>
        </html>
        "

        pages = Array{Dict{Any,Any}}

        for p in sitePages

            pages = [pages;{"url" => p.url,
                            "depth" => p.depth,
                            "parent" => p.parentUrl,
                            "color" => p.success ? "rgb(0,0,0)" : "rgb(255,0,0)"
                            }]
        end

        out = render(tpl, {"Title" => url, "pages" => pages})
        url  = getHash(url)
        f = open("tmp/$(url).htm","w")
        print(f,out)
        close(f)

        #open file in browser
        root = pwd()
        @windows? (cmd = `cmd /C $(root)\\tmp\\$(url).htm`) : (nothing)
        @osx? (cmd = `open $(root)/tmp/$(url).htm`) : (nothing)
        println(cmd)
        run(cmd)
end

#test basic functions
function testBasicFunctions(url)
    host,schema = getHost(url)
    sucess,page = getPage(url)

    @time intL,extL = getLinks(page,url)
    @time words = getWords(page,debug=true)
    @time d = countWords(words)
    @time write(url,d)
    @time d = read(url)
    nothing

    println(length(words))
end

######################### let's have fun

urls = ["http://julia.readthedocs.org/en/latest/manual/introduction/",
        "http://www.reddit.com/r/games",
         "http://www.usatoday.com/",
         "http://www.philpapers.org",
         "http://www.cnet.com/",
         "http://www.r-project.org/"]

url = urls[4]

#test exploreSite
if true

depth = 3
maxPages = 3
@time words, extL,sitePages = exploreSite(depth,maxPages,url,String[],"")

d = countWords(words)

println(length(sitePages))
#writeInFile(d,"tmp.txt")

printExploreSite(sitePages,depth,url)

end

if(false)
depth = 3
maxPages = 8
links = crawl(depth,maxPages,url)

println(links)
end

if(false)

rrefs = []
for i in 1:min(30,length(extL))
    rrefs = [rrefs; remotecall(1, getPage, extL[i])]
    sleep(0.01)
end

for r in rrefs
   wait(r)
end

for r in rrefs
    sucess,page = fetch(r)
    println(sucess)
end


end

println("webmap.jl: done!")
