%% get a few websites from two seeds seed
cd  C:\matlab\webMap

depth = 3;
maxPages = 4;%number of page per level
maxPages^depth

url = 'http://www.makeupandbeautyblog.com/';

path = crawl(depth,maxPages,url);
urls = printPath(path,0);

url = 'http://techradar.com/';

path = crawl(depth,maxPages,url);
urls = [urls printPath(path,0)];

urls = unique(urls);
%
url = 'http://philpapers.org/';

path = crawl(depth,maxPages,url);
urls = [urls printPath(path,0)];

for i=1:length(urls)
    urls{i} = stripUrl(urls{i});
end

urls = unique(urls);

clc
for i=1:length(urls)
   
    disp(urls{i})
    
end

%% urls 

urls = {'http://www.techradar.com/','http://www.engadget.com/','http://www.cnet.com/',...
    'http://philpapers.org/','http://www.iep.utm.edu/','http://plato.stanford.edu/',...
    'http://yale.edu/','http://www.rockpapershotgun.com/','http://www.indiedb.com/',...
    'http://web.mit.edu/','https://www.lushstories.com/'};


%%

matlabpool open 8

%% get words

doUpdate = 1;

depth = 3;
maxPages = 5;%number of page per level
maxPages^depth

ws = cell(length(urls),1);
cs = cell(length(urls),1);

parfor i=1:length(urls)
    
    if(doUpdate || ~exist( ['data/' stripUrl(urls{i}) '_w.mat'],'file'))
        
      
        words = exploreSite(depth,maxPages,urls{i});
        [w c] = countWords(words);

        ws{i} = w;
        cs{i} = c;        
    end
end

%load from files
for i=1:length(urls)
    
    if(doUpdate || ~exist( ['data/' stripUrl(urls{i}) '_w.mat'],'file'))
    
    else
        load(['data/' stripUrl(urls{i}) '_w.mat'],'w')
        load(['data/' stripUrl(urls{i}) '_c.mat'],'c')
        
        ws{i} = w;
        cs{i} = c;   
    end
        
end

ind = cellfun('length',ws) > 500;

ws = ws(ind);
cs = cs(ind);
urls = urls(ind);

ws
disp('done')
beep

%%

for i=1:length(urls)
    fprintf('%s\n',urls{i});
end

%% save everything

for i=1:length(urls)
    
    w = ws{i};
    c = cs{i};
    save(['data/' stripUrl(urls{i}) '_w.mat'],'w')
    save(['data/' stripUrl(urls{i}) '_c.mat'],'c')
    
end
%% load ?
for i=1:length(urls)
    

    load(['data/' stripUrl(urls{i}) '_w.mat'],'w')
    load(['data/' stripUrl(urls{i}) '_c.mat'],'c')
    
    ws{i} = w;
    cs{i} = c;
    
end

%% compute score for one

load wbkg.mat
load cbkg.mat


%%
i = 1;

w = ws{i};
c = cs{i};

c = c/max(c);

[I ia ib] = intersect(w,wBkg);
score = log10(c(ia)./cBkg(ib));

[score ind] = sort(score);

w = w(ind);
c = c(ind);
urls{i}
for i=1:10
    for j=1:10
        
        fprintf('%s \t\t\t', w{end-i+1-(j-1)*10}) 
        
    end
    fprintf('\n') 
end

%% compute score for all

scores = cell(size(urls));
wscores = cell(size(urls));

for i=1:length(urls)

    w = ws{i};
    c = cs{i};

    c = c/max(c);

    [I ia ib] = intersect(w,wBkg);
    score = log(c(ia)./cBkg(ib));

    scores{i} = score;
    
    wscores{i} = w(ia);

end



%% compute distance matrix
N = length(urls);
D = zeros(N);

dist = 1;

for i=1:N
    for j=1:N
       
        switch dist
            case 1
                D(i,j) = getDistance(wscores{i},scores{i},wscores{j},scores{j});
            case 2
                D(i,j) = getDistance2(wscores{i},scores{i},wscores{j},scores{j});
        end
    end 
end
clf

switch dist
    case 1
        
        D = 2-D;
        
        dia = eye(size(D));
        D(dia==1)=mean(D(:));
    
    case 2
        D = D-min(D(:));

        minScore =  min(D(D>0))/2;
        D = D + minScore;

        dia = eye(size(D));
        D(dia==1)=1;
        D = 1./D;
        D(dia==1)=0;
        D(isinf(D)) = 1.1*max(D(~isinf(D)));

end
imagesc(D)
colorbar

%% compute distances

DS = 0.5*(D+D');
DnonS = 0.5*(D-D');

dia = eye(size(DS));

DS(dia==1)=0;

opt  = statset('Display','iter','MaxIter',100);

%stress
%sstress
%metricstress
%metricsstress
%sammon
%strain
X = mdscale(DS,2,'Criterion','strain','Start','random','Replicates',4,'Options',opt);

% simple plot

clf;

x = sign(X(:,1)).*abs(X(:,1)).^1;
y = sign(X(:,2)).*abs(X(:,2)).^1;

plot(x,y,'.')
voronoi(x,y,'r')

for i=1:length(urls)
   text(x(i),y(i),urls{i}) 
end

axis(1.5*[min(x) max(x) min(y) max(y) ])

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

for i=1:length(urls)
  % name = regexp(urls{i},'w{0,3}\.?(.*)','tokens');
   name = removeHttp(urls{i});
     
   leftOrRight = round(1+rand);
   text(x(i)+0.006*sign(leftOrRight-1.5),y(i),name,...
       'FontSize',12.0,'HorizontalAlignment',al{leftOrRight}) 
end   


plot(x,y,'r.')

axis(2.0*[min(x) max(x) min(y) max(y) ])
set(gca,'visible','off')





