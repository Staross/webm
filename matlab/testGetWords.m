cd  C:\matlab\webMap

url = 'http://thesocietypages.org/socimages/';

tic
page =  urlread(url) ;
toc

tic
page =  curlUrl(url);
toc

words = getWordsPage(page);

[w c] = countWords(words);

w(1:10)

plot(log(c))
%%

[ilinks elinks] = getLinksPage(page,url);
elinks = filterLinks(elinks);

%intL = getInternalLinks(links,url)

for i=1:length(elinks)
    fprintf('%s\n',ilinks{i});
end

%getInternalLinks(url)

%% recursivly search a site

url = 'http://thesocietypages.org/socimages/';
page =  urlread(url) ;

depth = 0;
maxPages = 3;%number of page per level

words = exploreSite(depth,maxPages,url);

[w c] = countWords(words);

w(1:100)
plot(log(c))

%%

url = 'http://www.huffingtonpost.com/';
page =  curlUrl(url) ;

[ilinks elinks] = getLinksPage(page,url);

elinks = filterLinks(elinks)

%% explore website and get links

url = 'http://thesocietypages.org/socimages/';

depth = 5;
maxPages = 2;

[words elinks] = exploreSite(depth,maxPages,url);

%% crawl to other websites

url = 'http://www.huffingtonpost.com/';

depth = 5;
maxPages = 3;%number of page per level
maxPages^depth

path = crawl(depth,maxPages,url);
printPath(path,0);


%%

javaaddpath('C:\matlab\webMap')
dl = java.Downloader;
page = dl.getData('https://msp.f-secure.com/web-test/common/test.html');
str = char(page)



