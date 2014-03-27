function [words elinks] = exploreSite(depth,maxPages,url,alreadySeenLinks)

disp(url)

if(nargin < 4)
    alreadySeenLinks = {};
end

try
    page =  urlread(url) ;
catch err

    disp(['Error on url ' url ' , curling it']);
    page = curlUrl(url);
end

words = getWordsPage(page);
elinks = {};

if( depth > 0 )

    [ilinks elinks] = getLinksPage(page,url);
    
    ilinks = ilinks( (cellfun('length',ilinks)) > 0 );
    ilinks = filterLinks(ilinks);
    
    ilinks = setdiff(ilinks,alreadySeenLinks);
    
    if( isempty(ilinks) )
       return; 
    end
    
    p = randperm(length(ilinks));
    p = p(1:min(maxPages,length(ilinks)));
    
    alreadySeenLinks = [alreadySeenLinks; ilinks(p)];
    
    for i=1:length(p)

        [tmpW tmpL] = exploreSite(depth-1,maxPages,ilinks{p(i)},alreadySeenLinks);
        
        words = [words tmpW];
        elinks = [elinks; tmpL];
        
    end

end
