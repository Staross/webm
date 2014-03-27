%%

for i=1:length(urls)

    w = ws{i};
    c = cs{i};

    c = c / sum(c);          
    [wBkg cBkg] = mergeSets(wBkg,cBkg,w,c);

end

[cBkg ind] = sort(cBkg,'descend');
wBkg = wBkg(ind);
      
plot(log(cBkg))

save cBkg.mat cBkg
save wBkg.mat wBkg