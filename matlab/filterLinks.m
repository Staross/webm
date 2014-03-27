function links = filterLinks(links)

crap = {'google.com','twitter.com','facebook.com','youtube.com',...
        'atwola.com','doubleclick.net'};

for i=1:length(links)
   
    L = links{i};
    for j=1:length(crap)
        if( ~isempty(findstr(L,crap{j})))
            links{i} = '';
            break;
        end
    end
    
end

links = links( cellfun('length',links)>0 );