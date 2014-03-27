function url = stripUrl(url)
    
    tmp = regexp(url,'(https?://)?(w{0,3}\.?.*?)/.*?','tokens');
    
    if(~isempty(tmp))        
        url = char(tmp{1}{2});        
    end
 