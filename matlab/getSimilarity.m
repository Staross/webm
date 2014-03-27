function [sites similarity] = getSimilarity(url,Npages)

url1 = ['http://www.moreofit.com/similar-to/' url];

h = urlread(url1);

%  get websites
ex = '<span style="color: green;">(.*?)<\/span>';

a = regexp(h, ex,'tokens');

sites = cell(1,length(a));
ind=1;

for i=1:length(a)
    
    tmp = strtrim(a{i}{1});    
    tmp = regexp(tmp,'http://(w{0,3}\.?.*?)/.*?','tokens');

    if(~isempty(tmp))       
        sites{ind} = char(tmp{1});
        ind = ind+1;
    end
    
end

    
sites = sites(2:ind-1);%first one is the query


% get similarity


ex = '<div style="float: left;" title="Similarity: (\d*)%"">';

a = regexp(h, ex,'tokens');

similarity = zeros(1,length(a));

for i=1:length(a)
    
    tmp = strtrim(a{i}{1});    
    similarity(i) = str2double(tmp);
    
end

%% get other pages

for page=1:Npages-1

    url2 = ['http://www.moreofit.com/similar-to/' url '/Top_10_Sites_Like_' url '/?&page=' num2str(page+1)];

    h = urlread(url2);


    %  get websites
    ex = '<span style="color: green;">(.*?)<\/span>';

    a = regexp(h, ex,'tokens');

    sites2 = cell(1,length(a));
    ind=1;

    for i=1:length(a)

        tmp = strtrim(a{i}{1});    
        tmp = regexp(tmp,'http://(w{0,3}\.?.*?)/.*?','tokens');

        if(~isempty(tmp))       
            sites2{ind} = char(tmp{1});
            ind = ind+1;
        end

    end


    sites2 = sites2(2:ind-1);%first one is the query


    % get similarity

    ex = '<div style="float: left;" title="Similarity: (\d*)%"">';

    a = regexp(h, ex,'tokens');

    similarity2 = zeros(1,length(a));

    for i=1:length(a)

        tmp = strtrim(a{i}{1});    
        similarity2(i) = str2double(tmp);

    end

    % combine pages

    sites =[sites sites2];
    similarity = [similarity similarity2];

end
