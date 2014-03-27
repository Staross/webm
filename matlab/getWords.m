function [words tags] = getWords(url,baseUrl,nPages)

words = {};
tags = {};

try

h = urlread(url);

catch ME
   ME.message
   disp(['error reading this url: ' url]); 
   return;
end

try

h= lower(h);


%%  get description and keywords

ex = '<meta\s+name="description"\s+content="(.*?)"\s*[>|/>]';

desc = regexp(h, ex,'tokens');

tags = '';

if( ~isempty(desc) )

    tags = desc{1}{1};

end


ex = '<meta\s+name="keywords"\s+content="(.*?)"\s*[>|/>]';

keywords = regexp(h, ex,'tokens');
%keywords{1}{1}

if( ~isempty(keywords) )

    tags = [tags ' ' keywords{1}{1}];

end

tags = regexprep(tags,'[^a-z0-9-\s]',' ');

%%


tags = regexp(tags, '[\s*\t*'']', 'split');

tags = tags(~strcmp(tags,'')); %remove some stupid things
tags = tags(~strcmp(tags,'-'));
tags = tags(~strcmp(tags,'--'));


%% get links
ex = '<a[^>]*href="(.*?)"[^>]*[>|/>]';

links = regexp(h, ex,'tokens');

links = simplifyCell(links);
links = unique(links);


%% remove javascript, css, ..

ex = '<script[^<]*?>.*?</\s*script\s*>';

text = regexprep(h, ex,'');

ex = '<style[^<]*?>.*?</\s*style\s*>';

text = regexprep(text, ex,'');

text = regexprep(text,'<!--.*?-->','');



%% remove tags

%h ='<a href="/contenu.php?id=4925"> Ayrault et la "boule puante"&nbsp;: une affaire de 1997 refait surface   		</a>';

ex = '<[^>]*>';
text = regexprep(text, ex, '');

%%

%remove some html tags
words = regexprep(text, '&nbsp;', ' ');
words = regexprep(words, '&quot;', '');
%words = regexprep(words, '[.><]', ' ');

words = regexprep(words, '[^\w\n\s\t-]', ' '); %remove non-words

words = regexp(words, '[\s*\t*'']', 'split');


words = words(~strcmp(words,'')); %remove some stupid things
words = words(~strcmp(words,'-'));
words = words(~strcmp(words,'--'));

%% follow links

if(nPages>1 && ~isempty(links))


   intL = getInternalLinks(links,baseUrl);

   ind = randperm(length(intL));

   for i=1:min(nPages,length(ind));

       L = intL{ind(i)};


           
       [wl tl] = getWords(L,baseUrl,nPages-1);

       words = [words wl];
       tags = [tags tl];

   end

end

catch ME

    ME.message

end



