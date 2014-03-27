function url = removeHttp(url)

    if(length(url) > 7 )
        if(strcmp(url(1:7),'http://'))
            url = url(8:end);
        end
    end