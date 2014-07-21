using HTTPClient.HTTPC
using URIParser
using Gumbo

#callback for HTTPC.get, allow to use libCURL options
function customize_curl(curl)
  cc = LibCURL.curl_easy_setopt(curl, LibCURL.CURLOPT_USERAGENT, "Mozilla/5.0 (Windows NT 6.1; rv:28.0) Gecko/20100101 Firefox/28.0")
  if cc != LibCURL.CURLE_OK
    error ("CURLOPT_USERAGENT failed: " * LibCURL.bytestring(curl_easy_strerror(cc)))
  end  
end

function getPage(url::String;debug=true)

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

        page = bytestring(r.body)

        return (true, page)

    catch err
        
        if debug
            println(err)
        end
        return (false,"")
    end   
end

function getBody(doc)
    
    body = HTMLElement(:body)
    for elem in preorder(doc.root)
        if typeof(elem) == HTMLElement{:body}
            body = elem
            break
        end
    end
    
    return body
    
end

function parsePage(page)

    doc = parsehtml(page)

    body = getBody(doc)

    #get links
    postUrls = String[]
    titles = String[]
    nextUrl = ""

    for elem in preorder(body)
        if typeof(elem) == HTMLElement{:a}

            try 

                as = attrs(elem)

                if haskey(as,"class") && as["class"] == "title may-blank "

                    push!(titles, lowercase(elem[1].text) )
                    push!(postUrls,  as["href"])              
                end

                if haskey(as,"rel") && as["rel"] == "nofollow next"

                    nextUrl = as["href"]
                end
            end

        end
    end
    
    return postUrls, titles, nextUrl

end

function parsePost(page)

    doc = parsehtml(page)

    body = getBody(doc)
    
    postContent = ""
    for elem in preorder(body)       
        #println(typeof(elem))
        if typeof(elem) == HTMLElement{:div}

                as = attrs(elem)
               
                if haskey(as,"class") && as["class"] == "expando"
                    
                    for e in preorder(elem)    
                        if typeof(e) == HTMLText
                            postContent = postContent * " " * e.text
                        end
                    end
                end
        end
    end

    return postContent
end

data = zeros(3,0)

url = "http://www.reddit.com/r/penpals/"
baseUrl = "http://www.reddit.com"
sucess, page = getPage(url)

postUrls, titles, nextUrl = parsePage(page)


for i = 4:4#length(postUrls)
    
    m = match(r"([0-9]+)[/]([f|m])",titles[i])
    println(m)

    if m != nothing
       
        age = m.captures[1]
        sex = m.captures[2]
        
        sucess, postPage = getPage(baseUrl * postUrls[i])

        postContent = parsePost(postPage)
        println(postContent)
        
    end
    
    
    
end


for m in eachmatch(r"href=\"/r/penpals/comments/([^\"]*)/\"",page) 
    
    #println((m.captures[1]))

end
