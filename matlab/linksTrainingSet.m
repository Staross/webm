pageNum = 1;

url{pageNum}    = 'http://blogs.opera.com/desktop/2013/11/opera-developer-update-day-19-0-1326-0/';

out{pageNum}    = {'http://dev.opera.com/extension-docs/stash.html', ...
                   'http://www.opera.com/computer?utm_medium=banner&utm_source=opera_desktop_blog&utm_campaign=desktop_social&utm_content=ad_text_new_photo_240x350', ...
                   'http://coastbyopera.com/',...
                   'http://www.operasoftware.com/company/investors',...
                   'https://plus.google.com/+opera',...
                   'http://blogs.opera.com/news/'
                   };
                    
% % %

pageNum = 2;
url{pageNum}    = 'http://stackoverflow.com/questions/18314531/git-push-doesnt-working';

out{pageNum}    = {'http://stackoverflow.com/users/2310209/user2310209',...
                   'http://stackoverflow.com/questions/67699/how-do-i-clone-all-remote-branches-with-git',...
                   'http://wordpress.stackexchange.com',...
                   'http://stackexchange.com/legal/privacy-policy',...
                   'http://stackexchange.com/legal/terms-of-service',...                   
                   };
               
           
% % %

pageNum = 3;
url{pageNum}    = 'http://www.nytimes.com/';

out{pageNum}    = {'http://www.nytimes.com/2013/12/09/opinion/mr-de-blasios-fiscal-challenge.html?hp&rref=opinion',...
                   'http://dealbook.nytimes.com',...
                   'http://www.nytimes.com/gst/regi.html',...
                   'http://www.nytimes.whsites.net/mediakit/',...
                   'http://www.nytimes.com/2013/12/09/us/politics/eastern-states-press-midwest-to-improve-air.html?hp&target=comments#commentsContainer',...
                  };


%%
i=1

page = fileread(['p' num2str(i) '.htm']);

[intL, extL] = getLinksPage(page,url{i});

L = [intL; extL];

Lt = out{i};
found = zeros(length(Lt),1);
for j=1:length(Lt)
   
    if(ismember(Lt{j},L))
       found(j) = 1; 
    end
    
end

clc
disp( ['found ' num2str(sum(found)) ' out of ' num2str(length(found)) ])

for j=1:length(Lt)
    disp(Lt{j})
end
fprintf('\nFound:\n')
for j=1:length(L)
    disp(L{j})
end


%%





