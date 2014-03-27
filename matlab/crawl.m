function links = crawl(depth,maxPages,url)

links = {url};

if( depth > 0 )
    
    try
        page =  urlread(url) ;
    catch err
    
    %rethrow(err);
   
        disp(['Error on  ' url]);
        page = curlUrl(url);
    end
    
    [ilinks elinks] = getLinksPage(page,url);
    
    elinks = filterLinks(elinks); 
      
    if( isempty(elinks) )
       return; 
    end
      
    p = randperm(length(elinks));
    p = p(1:min(maxPages,length(elinks)));
    
    for i=1:length(p)

        links = [links {crawl(depth-1,maxPages,elinks{p(i)})} ];
              
    end

end

