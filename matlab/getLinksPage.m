%[intL, extL] = getLinksPage(page,url)
function [intL, extL] = getLinksPage(page,url)

    ex = '<a[^>]*href=["|'']([^#].*?)["|''][^>]*[>|/>]';
    
    links = regexp(page, ex,'tokens');

    links = simplifyCell(links);
    links = unique(links);

    root = ['http://' stripUrl(url)];
    
    extL = cell(length(links),1);
    intL = cell(length(links),1);
    
    ind=1;
    indExt=1;
    for i=1:length(links)

        L = links{i};

        if(length(L) < 2)
            continue;
        end
        
        %remove images and stuff
        ext = {'.png','jpg','gif'};
        isImage = 0;
        if(length(L)>2)
            tmp = L(end-2:end);
            
            for j=1:length(ext)
               if( strcmp(tmp,ext{j}))
                  isImage = 1;
                  break; 
               end
            end
        end
        if(isImage)
            continue;
        end
        
        %some links don't put the http
        if(strcmp(L(1:2),'//'))
            L = ['http:' L]; 
        end

        if( isempty(strfind(L,'http://')) && ...
            isempty(strfind(L,'https://'))&& ...
            isempty(strfind(L,'HTTP://')) ...
            )%internal link
            
            if( strcmp(L(1),'/') ) %link relative to root
                
                  intL{ind} = [root L];
                  ind = ind+1;
            else  %link relative to current page
                
                  intL{ind} = [url L];
                  ind = ind+1;
            end
               
        else

            if( ~isempty(strfind(L,stripUrl(url))) ) %still an internal link

               intL{ind} = L;
               ind = ind+1;
               
            else
                
                extL{indExt} = L;
                indExt = indExt+1;

            end

        end

    end
    
    intL = intL( (cellfun('length',intL)) > 0 );
    extL = extL( (cellfun('length',extL)) > 0 );

    intL = unique(intL);
    extL = unique(extL);

