function [sites similarity] = getSimilarityG(url,Npages)


    try
% google related

%url1 = ['http://www.google.ch/search?q=related:' url]

url1 = ['https://s1-eu3.startpage.com/do/search?q=related:' url];


%url = 'https://www.google.ch/search?q=related:nytimes.com';

h = urlread(url1);

%%  get websites

%ex = '<div><cite>(.*?)</cite>';

ex = '<span class=''url''>(.*?)</span>';


a = regexp(h, ex,'tokens');

sites = cell(1,length(a));
ind=1;

for i=1:length(a)
    
    tmp = (strtrim(a{i}));    
    
    %tmp1 = char(strtrim(a{i}));    
    %tmp = regexp(tmp1,'(.*?)/','tokens');

    
    
    if(~isempty(tmp))
        
        sites{ind} = char(tmp{1});
        ind = ind+1;
    end
    
end

    
%sites{:}

similarity = 1:length(sites);


%get QUID


ex = 'name="qid" value="(.*?)" />';


b = regexp(h, ex,'tokens');



qid = b{1}{1};


    %% get other pages

    for page=1:Npages-1

        h= urlread('https://s5-eu3.startpage.com/do/search','post',...
        {'cmd','process_search', ...
         'language','english', ...
         'qid',qid, ...
         'query',['related:' url], ...
         'startat',num2str(10*page),...
        });


        %url2 =
        %['http://www.jaruzel.com/projects/anonymous-google/default.asp?q=related:' url '&start=' num2str(10*page)];
        %h = urlread(url2);


        %  get websites
        %ex = '<div><cite>(.*?)</cite>';
        %ex = '<span class="c">(.*?)</span>';

        ex = '<span class=''url''>(.*?)</span>';

        a = regexp(h, ex,'tokens');


        sites2 = cell(1,length(a));
        ind=1;

        for i=1:length(a)

            tmp = (strtrim(a{i}));    

    %         tmp1 = char(strtrim(a{i}));    
    %         tmp = regexp(tmp1,'(.*?)/','tokens');

            if(~isempty(tmp))

                sites2{ind} = char(tmp{1});
                ind = ind+1;
            end

        end




        % get similarity

        similarity2 =  (1:length(sites2)) + similarity(end);

        % combine pages

        sites =[sites sites2];
        similarity = [similarity similarity2];

    end
end