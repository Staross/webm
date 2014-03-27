feature('DefaultCharacterSet','ISO8859-1')
setenv LANG fr_FR.ISO8859-1

%%

doUpdate = 1;

[words tags] = getWords('http://forums.asp.net/',8,doUpdate);

words = [words tags];

length(words)

%%

[w c] = countWords(words);

w(1:80)

%% asd

url = 'http://www.latribune.fr/';

doUpdate = 1;

[w c] = getWordCount(url,3,doUpdate);

length(w)

hist(c,400)
w(1:40)
%%
matlabpool close

matlabpool(8)

%% get words for a website list

seeds = {'www.lemonde.fr'};
sites = {};
for i=1:length(seeds)

    [sitestmp similarity] = getSimilarity(seeds{i},2);
    sitestmp
    sites=[sites sitestmp];
    sites{end+1} = seeds{i};

end

sites = unique(sites);
sites = filterSites(sites)
length(unique(sites))


%%
%add in urlread urlConnection.setRequestProperty('User-Agent','Mozilla 5.0');

doUpdate = 1;
parfor i=1:length(sites)
    
    url = ['http://' sites{i} '/'];
    getWordCount(url,4,doUpdate);
end

disp('done');
beep

%% build distance matrix

D = zeros(length(sites));

ws = cell(1,length(D));
cs = cell(1,length(D));

stats = zeros(1,length(D));
for i=1:length(D)
    
    name = ['words/' stripUrl(sites{i}) '_w.mat'];
    if(exist(name,'file'))
    load(name);
    ws{i} = w;
    else
       ws{i} = {''}; 
    end
    name = ['words/' stripUrl(sites{i}) '_c.mat'];
    if(exist(name,'file'))
    load(name);
    cs{i} = c;
    else
        cs{i} = 1;
    end
    
    stats(i) = length(ws{i});
end

for i=1:length(D)
    
    disp(100*i/length(D))
    for j=1:length(D)
    
        D(i,j) = getDistance(ws{i},cs{i},ws{j},cs{j});
    end
end

clf
plot(stats)

%%

DS = 1-D;
D = norma(D);
%DS = DS.^4;
DS = histeq(DS);

DS = 0.5*(DS+DS');

dia = eye(size(DS));
DS(dia==1)=0;

clf
imagesc(DS)
colorbar

%%
opt  = statset('Display','iter','MaxIter',1200);
%X = mdscale(DS,2,'Criterion','strain','Start','random','Replicates',5,'Options',opt);

X = mdscale(DS,2,'Criterion','stress','Start','cmdscale','Replicates',1,'Options',opt);


%%
clf;

x = sign(X(:,1)).*abs(X(:,1)).^1;
y = sign(X(:,2)).*abs(X(:,2)).^1;

plot(x,y,'.')
voronoi(x,y,'r')

for i=1:length(sites)
    
   text(x(i),y(i),sites{i}) 
    
end


%% generate a nice image

clf;
hold on
patch([-5 5 5 -5],[-5 -5 5 5],[0.8 0.8 0.9],'edgeColor','none')

al{1} = 'right';
al{2} = 'left'; 
%
[v,c]=voronoin([x y]); 
for i = 1:length(c) 
    if all(c{i}~=1)   
     patch(v(c{i},1),v(c{i},2),0.7+0.2*rand*[1 1 1]+0.1*rand(1,3),'edgeColor','none'); % use color i.
    end
end

% for i=1:length(w)    
%    [v ind] = sort(D(i,:),'descend');
%    
%    X = linspace(x(i),x(ind(1)),2);
%    Y = linspace(y(i),y(ind(1)),2);
%    plot(X,Y,'color',[0.85 0.8 0.8])
%    
%    X = linspace(x(i),x(ind(2)),2);
%    Y = linspace(y(i),y(ind(2)),2);
%    plot(X,Y,'color',[0.85 0.8 0.8])
%           
% end

for i=1:length(sites)
   name = regexp(sites{i},'w{0,3}\.?(.*)','tokens');
   leftOrRight = round(1+rand);
   text(x(i)+0.006*sign(leftOrRight-1.5),y(i),name{1},'FontSize',2.0,'HorizontalAlignment',al{leftOrRight}) 
end   


plot(x,y,'r.')

axis(1.15*[min(x) max(x) min(y) max(y) ])
set(gca,'visible','off')


