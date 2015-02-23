using HTTPClient.HTTPC
using URIParser
using Gumbo
using Distributions

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
                        request_timeout=8.0,
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

    return lowercase(postContent)
end

function getData(titles,baseUrl,postUrls)

  data = zeros(0,3)
  sleep(0.1)

  for i=1:length(titles)

      m = match(r"([0-9]+)[/]([f|m])",titles[i])

      if m != nothing

          age = m.captures[1]
          sex = m.captures[2]

          sucess, postPage = getPage(baseUrl * postUrls[i])
          postContent = parsePost(postPage)

          if postContent != ""

              m = match(r"video game|video games|games|gaming",postContent)
              m == nothing ? likeGames = 0 : likeGames = 1

              data = [data;transpose([age, sex == "m" ? 0 : 1, likeGames])]

          end
      end
  end
  return data
end

#cd("D:/Julia/webm")
data = zeros(0,3)

url = "http://www.reddit.com/r/penpals/"
baseUrl = "http://www.reddit.com"

for i=1:0

  println(i)
  sucess, page = getPage(url)

  postUrls, titles, nextUrl = parsePage(page)

  d = getData(titles,baseUrl,postUrls)

  data = [data; d]

  url = nextUrl

end

if false
  writecsv("penpalDataAge.csv",data[:,1]')
  writecsv("penpalDataSex.csv",data[:,2]')
  writecsv("penpalDataLikeGames.csv",float(data[:,3]'))

  age   = float(data[:,1])
  sex   = float(data[:,2])
  gamer = float(data[:,3])
end


age   = float(readcsv("penpalDataAge.csv"))
sex   = float(readcsv("penpalDataSex.csv"))
gamer = float(readcsv("penpalDataLikeGames.csv"))

age   = [age float(readcsv("data1/penpalDataAge.csv"))];
sex   = [sex float(readcsv("data1/penpalDataSex.csv"))];
gamer = [gamer float(readcsv("data1/penpalDataLikeGames.csv"))];



N = length(sex)
Nmen = sum(sex.==0)
Nwom = sum(sex.==1)

sum(gamer[sex.==0]) / Nmen
sum(gamer[sex.==1]) / Nwom

mean(age)
std(age)
minimum(age)
maximum(age)

#old men
sel = (sex .== 0) & (age .> mean(age))
sum(gamer[sel])/sum(sel)
int(sum(gamer[sel]))//sum(sel)

#young men
sel = (sex .== 0) & (age .< mean(age))
sum(gamer[sel])/sum(sel)
int(sum(gamer[sel]))//sum(sel)

#old woman
sel = (sex .== 1) & (age .> mean(age))
sum(gamer[sel])/sum(sel)
int(sum(gamer[sel]))//sum(sel)

#young woman
sel = (sex .== 1) & (age .< mean(age))
sum(gamer[sel])/sum(sel)
int(sum(gamer[sel]))//sum(sel)


Nx = sum(gamer[sex.==1]);

x = linspace(0,1,100);
P(p) = pdf(Binomial(Nwom,p),Nx)
y = float([P(x[i]) for i=1:length(x)])
y = y / sum(y);
scatterplot(x[:],y[:])

mu = sum( x .* y)
sigma = sqrt( sum( (x -mu).^2  .* y ) )

Nx = sum(gamer[sex.==0]);

x = linspace(0,1,100);
P(p) = pdf(Binomial(Nmen,p),Nx)
y = float([P(x[i]) for i=1:length(x)])
y = y / sum(y);
scatterplot(x[:],y[:])

mu = sum( x .* y)
sigma = sqrt( sum( (x -mu).^2  .* y ) )


println("Sucess")




