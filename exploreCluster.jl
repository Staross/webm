reload("webmap.jl")

function loadData(urls)

	ds = Array(Dict{UTF8String, Int64},length(urls))
	for i = 1:length(urls)
	    ds[i] = read(urls[i])
	end
	return ds
end

function printScore(d,url)

    c = collect(values(d)) 
    k = collect(keys(d)) 

    idx = sortperm(c)

    println("--------- $url ---------")

    for i = 1:min(length(idx),8)
        w = k[idx[i]]
        n = c[idx[i]]
        println("$n : $w")
    end 

    for i = max(length(idx)-8,1):length(idx)
        w = k[idx[i]]
        n = c[idx[i]]
        println("$n : $w")
    end 

    println("------------------")

end


function printScoreHTML(d,url)

    c = collect(values(d)) 
    k = collect(keys(d)) 
    idx = sortperm(c)

	tpl = "
	<html>
	<head>
	<title>{{Title}}</title>
	</head>
	<body>
		<p>{{Title}}</p>
		<table>
			<tr><th>name</th><th>Score (Log10)</th></tr>
			{{#d}}
			<tr><td>{{w}}</td><td>{{n}}</td></tr>
			{{/d}}
		</table>
	</body>
	</html>
	"

	d = Array{Dict{Any,Any}}

	 for i = 1:min(length(idx),15)
	    w = k[idx[i]]
	    n = c[idx[i]]
	    d = [d;{"w" => w, "n" => n}]
	end 

	for i = max(length(idx)-15,1):length(idx)
	    w = k[idx[i]]
	    n = c[idx[i]]
	    d = [d;{"w" => w, "n" => n}]
	end 

	out = render(tpl, {"Title" => url, "d" => d})
	url  = getHash(url)
	f = open("tmp/$(url).htm","w")
	print(f,out)
	close(f)

	#open file in browser
	root = pwd()
	cmd = `cmd /C $(root)\\tmp\\$(url).htm`
	println(cmd)
	run(cmd)
end


function makeBackground(ds)

	bkg = Dict{UTF8String, Int64}()

	for i = 1:length(ds)		 
	    c = collect(values(ds[i])) 
    	w = collect(keys(ds[i])) 

		for j=1:length(w)
			k = w[j]

	        if haskey(bkg,k)             
            	bkg[k] = bkg[k]+c[j]
	        else
	            bkg[k] = c[j]
	        end    
		end
	end

	return bkg
end

function getScore(d,bkg)

	score = Dict{UTF8String, Float64}()
	N1 = sum(values(d))
	N2 = sum(values(bkg))
	for k in keys(d)
		score[k] = log10( N2/N1 * d[k] / bkg[k] )
	end
	return score
end

function getDistance(s1,s2)

	m = minimum( [collect(values(s1)); collect(values(s2))] )
	d = 0.0
	for k in keys(s1)

		if haskey(s2,k)
			d = d + abs(s1[k]-s2[k])
		else
			d = d + abs(s1[k]-m)
		end
	end 
	d = 100 * d / length(s1) / length(s2)
	return d
end

function getLikelihood(s1,s2)

        N2 = sum( collect(values(s2)) )
        d = 0.0
        N1 = 0
        for k in keys(s1)

                if haskey(s2,k)
                        d = d + s1[k]*log(s2[k]/N2)
                else
                        d = d + s1[k]*log(1/N2)
                end
                N1 = N1 + s1[k]
        end
        d = d / N1
        return d
end

urls = ["http://julia.readthedocs.org/en/latest/manual/introduction/",
        "http://www.reddit.com/r/games",
         "http://www.fuq.com",
         "http://www.philpapers.org","http://www.techradar.com/"]

 urls = ["http://www.techradar.com/","http://www.engadget.com/","http://www.cnet.com/",
"http://philpapers.org/","http://plato.stanford.edu/","http://www.iep.utm.edu/","http://web.mit.edu/",
"http://yale.edu/","http://www.rockpapershotgun.com/","http://www.indiedb.com/",
"http://www.lushstories.com/","http://www.fuq.com","http://www.youjizz.com/",
"http://julia.readthedocs.org/en/latest/manual/introduction/",
"http://www.nytimes.com/","http://www.usatoday.com/"]

urls = ["http://philpapers.org/","http://plato.stanford.edu/",
		"http://www.nytimes.com/","http://www.usatoday.com/",
		"http://www.r-project.org/","http://julia.readthedocs.org/en/latest/manual/"]

Nu = length(urls)

doUpdate = true

depth = 3
maxPages = 3#number of page per level
println(maxPages^depth)

if doUpdate

	rrefs = []
	for i=1:Nu
	    rrefs = [rrefs; remotecall(1,exploreSite, depth,maxPages,urls[i],String[])]
	end   

	for r in rrefs
	   wait(r)
	end

	ds = Array(Dict{UTF8String, Int64},Nu)
	for i = 1:Nu
	    words, extL  = fetch(rrefs[i])
	    ds[i] = countWords(words)
	end

	for i = 1:length(ds)
		url = urls[i]
	    N = length(ds[i])
	    println("$url : $N")

	    write(url,ds[i])
	end

else

	ds = loadData(urls)

 	for i = 1:length(ds)
		url = urls[i]
	    N = length(ds[i])
	    println("$url : $N")

	end
end

bkg = makeBackground(ds)

score = Array(Dict{UTF8String, Float64},Nu)
for i=1:Nu
	score[i] = getScore(ds[i],bkg)
end

idx = 4
#printScoreHTML(score[idx],urls[idx])

D = zeros(Nu,Nu)
for i=1:Nu
	for j=1:Nu
		#D[i,j] = getDistance(score[i],score[j])
		D[i,j] = -getLikelihood(ds[i],ds[j])
	end
end

dia = diag(D)
for i=1:Nu
	for j=1:Nu
		D[i,j] = D[i,j]-dia[i]/2  -dia[j]/2
	end
end

D = (D+D')/2

println("done")
