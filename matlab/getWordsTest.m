%function [words tags] = getWords(url)

url = 'http://www.nytimes.com';
h = urlread(url);

h= lower(h);

%%

feature('DefaultCharacterSet','ISO8859-1')
setenv LANG fr_FR.ISO8859-1

%%
system('/sw/bin/wget wget -O tmp.html http://www.lemonde.fr');

h = fileread('tmp.html');
h= lower(h);

%%  get description and keywords

ex = '<meta\s+name="description"\s+content="(.*?)"\s*[>|/>]';

desc = regexp(h, ex,'tokens');
desc{1}{1}


ex = '<meta\s+name="keywords"\s+content="(.*?)"\s*[>|/>]';

keywords = regexp(h, ex,'tokens');
keywords{1}{1}

%% get links

ex = '<a[^>]*href="(.*?)"[^>]*[>|/>]';

links = regexp(h, ex,'tokens');
links{8}



%% remove javascript, css, ..

ex = '<script[^<]*?>.*?</\s*script\s*>';

text = regexprep(h, ex,'');

ex = '<style[^<]*?>.*?</\s*style\s*>';

text = regexprep(text, ex,'');

text = regexprep(text,'<!--.*?-->','');


% ex = '<script\s+type="text/javascript"\s*>.*?</\s*script\s*>';
% 
% text = regexprep(text, ex,'');
% 
% ex = '<script\s*>.*?</\s*script\s*>';
% 
% text = regexprep(text, ex,'');

text

%% remove tags

%h ='<a href="/contenu.php?id=4925"> Ayrault et la "boule puante"&nbsp;: une affaire de 1997 refait surface   		</a>';

ex = '<[^>]*>';
text = regexprep(text, ex, '');

text

%%

words = regexprep(text, '[^\w\n\s\t-]', ''); %remove non-words

words = regexp(words, '\s*\t*', 'split');

words = words(~strcmp(words,'')); %remove some stupid things
words = words(~strcmp(words,'-'));
words = words(~strcmp(words,'--'));

words

%%

fid = fopen('tmp.html','w');
fprintf(fid, '%s', text)
fclose(fid)

!open tmp.html

%% test javascript

ex = '<script src="[^"]*" type="text/javascript"></script>';
ex = '<script\s*>.*?</\s*script\s*>';

%<script src="http://assets2.lefigaro.fr/assets-js/lib/modernizr-custom.js"></script>
%<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>


text = regexp(h, ex,'match')

text{2}

%%
sites = cell(1,length(a));
ind=1;

for i=1:length(a)
    
    tmp1 = char(strtrim(a{i}));    
    tmp = regexp(tmp1,'(.*?)/','tokens');

    if(~isempty(tmp))
        
        sites{ind} = char(tmp{1});
        ind = ind+1;
    end
    
end


%<meta name="description" content="le monde.fr - 1er site d'information. les articles du journal et toute l'actualit&eacute; en continu : international, france, soci&eacute;t&eacute;, economie, culture, environnement, blogs ...">
%%%%

