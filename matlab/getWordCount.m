function [w c] = getWordCount(url,nPages,doUpdate)

name = ['words/' stripUrl(url) '_w.mat'];

if nargin < 3
    doUpdate = 0;
end

if(~exist(name,'file') || doUpdate)

    
    [words tags] = getWords(url,url,nPages);
            
    words = [words tags];
    
    %

    [w c] = countWords(words);
            

    name = ['words/' stripUrl(url) '_w.mat'];
    save(name,'w');
    
    name = ['words/' stripUrl(url) '_c.mat'];
    save(name,'c');
    
    
else
    
    name = ['words/' stripUrl(url) '_w.mat'];
    load(name);
    
    name = ['words/' stripUrl(url) '_c.mat'];
    load(name);
    
end