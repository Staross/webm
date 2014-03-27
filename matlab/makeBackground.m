wBkg = zeros(0);
cBkg = zeros(0);

jList = dir('words');
jList = struct2cell(jList);
jList = jList(1,:);
jList = jList(4:end);

for i=1:length(jList)
    jList{i} = regexprep(jList{i}, '_w.mat', '');
    jList{i} = regexprep(jList{i}, '_c.mat', '');
end

jList = unique(jList);

%%

for i=1:length(jList)

    100*i/length(jList)
    
    url = jList{i};
    
    name = ['words/' url '_w.mat'];
    load(name);
    
    name = ['words/' url '_c.mat'];
    load(name);

    c = c / sum(c);          
    [wBkg cBkg] = mergeSets(wBkg,cBkg,w,c);

end

[cBkg ind] = sort(cBkg,'descend');
wBkg = wBkg(ind);
      
save cBkg.mat cBkg
save wBkg.mat wBkg