function s = filterSites(sites)

ind = 1;

for i=1:length(sites)

    if( isempty(findstr('wikipedia', sites{i})) )
        s{ind} = sites{i};
        ind = ind + 1;
    end
    
end