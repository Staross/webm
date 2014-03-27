function intL = getInternalLinks(links,url)

ind=1;

for i=1:length(links)

    L = links{i};
    
    %weird links don't put the http
    if(strcmp(L(1:2),'//'))
        L = ['http:' L]; 
    end
    
    if( isempty(findstr('http://', L)) )%internal link

        if(strcmp(url(end),'/') && ~strcmp(L(1),'/') )                        
            intL{ind} = [url L];
            ind = ind+1;                     
        end
        
        if(strcmp(url(end),'/') && strcmp(L(1),'/') )                        
            intL{ind} = [url L(2:end)];
            ind = ind+1;                     
        end
        
        if(~strcmp(url(end),'/') && strcmp(L(1),'/') )                        
            intL{ind} = [url L];
            ind = ind+1;                     
        end
        
        if(~strcmp(url(end),'/') && ~strcmp(L(1),'/') )                        
            intL{ind} = [url '/' L];
            ind = ind+1;                     
        end
        
    else
        
        if(~isempty(findstr(stripUrl(url), L)))
            
           intL{ind} = L;
           ind = ind+1;
            
        end
        
    end
    
end
