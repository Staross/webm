%%try some stuff

D = D+0.1*rand(size(D));

D = 0.5*(D+D');

dia = eye(size(D));

D(dia==1) =0;

 imagesc(D+D')
%%

X = mdscale(D,2);

x = X(:,1);
y = X(:,2);

plot(x,y,'.')
voronoi(x,y)

%% simi related


url = 'https://startpage.com/do/search?q=related:lemonde.fr';
h = urlread(url);
%%


%%

%%  get websites
ex = '<span class=''url''>(.*?)</span>';


a = regexp(h, ex,'tokens')

sites = cell(1,length(a));
ind=1;

for i=1:length(a)
    
    tmp1 = char(strtrim(a{i}));    
    tmp = regexp(tmp1,'(.*?)/','tokens');

    if(~isempty(tmp))
        
        sites{ind} = char(tmp{1});
        ind = ind+1;
    end
    
end

    
sites{:}
%% fuck google

seed = 'www.gutsofdarkness.com';

[sites similarity] = getSimilarityG(seed,3)


%% http://www.moreofit.com

%http://jonathanstray.com/we-have-no-maps-of-the-web

url = 'http://www.moreofit.com/similar-to/www.lemonde.fr/Top_10_Sites_Like_www.lemonde.fr/';
h = urlread(url);

%%  get websites
ex = '<span style="color: green;">(.*?)<\/span>';

a = regexp(h, ex,'tokens');

sites = cell(1,length(a));
ind=1;

for i=1:length(a)
    
    tmp = strtrim(a{i}{1});    
    tmp = regexp(tmp,'http://(w{0,3}\.?.*?)/.*?','tokens');

    if(~isempty(tmp))
        tmp
        sites{ind} = char(tmp{1});
        ind = ind+1;
    end
    
end

    
sites = sites(2:ind-1);%first one is the query

sites{:}

%% get similarity


ex = '<div style="float: left;" title="Similarity: (\d*)%"">';

a = regexp(h, ex,'tokens');

similarity = zeros(1,length(a));

for i=1:length(a)
    
    tmp = strtrim(a{i}{1});    
    similarity(i) = str2double(tmp);
    
end

%% for parfor
matlabpool close

matlabpool(4)

%%

Npages = 1;

seed = 'www.lemonde.fr';

%seeding
[w s] = getSimilarityG(seed,Npages);
%
w{end+1} = seed;
s(end+1) = 0;

N=length(s);

D = zeros(N,N);

D(end,:) = (s);
D(:,end) = (s);

%
% 
% for i=1:N-1;
%     disp(100*i/(N-1))
%     
%     [sites similarity] = getSimilarity(w{i},Npages);
%     
%     ind = ismember(sites,w);
%     w = [w sites(ind==0)]; %%add new sites to the list
%     
% 
%     for j=1:length(sites)
%      ind = find( ismember(w,sites{j}) );
%      
%      D(i,ind) = similarity(j);
%      D(ind,i) = similarity(j);
% 
%     end
%          
% end

sit=cell(200,1);
sim=cell(200,1);


parfor i=1:N-1;
    %disp(100*i/(N-1))
    
    [sites similarity] = getSimilarityG(w{i},Npages);
    
    sit{i}=sites;
    sim{i}=similarity;
         
end

%

for i=1:N-1;
    disp(100*i/(N-1))
    
    sites  = sit{i};
    similarity = sim{i};
    
    ind = ismember(sites,w);
    w = [w sites(ind==0)]; %%add new sites to the list
    

    for j=1:length(sites)
     ind = find( ismember(w,sites{j}) );
     
     D(i,ind) = similarity(j);
     D(ind,i) = similarity(j);

    end
         
end


 clf;
 imagesc(D)

%% fill up the rest of the matrix

Npages = 3;

parfor i=1:length(w);
    %disp(100*i/(N-1))
    
    [sites similarity] = getSimilarityG(w{i},Npages);
    
    sit{i}=sites;
    sim{i}=similarity;
         
end

for i=1:length(w);
    disp(100*i/length(w))
    
    sites  = sit{i};
    similarity = sim{i};
    
    for j=1:length(sites)
     ind = find( ismember(w,sites{j}) );
     
     D(i,ind) = similarity(j);
     D(ind,i) = similarity(j);

    end
         
end


% for i=N+1:length(w);
%     disp(100*i/length(w))
% 
%    [sites similarity] = getSimilarity(w{i},Npages);
%     
%     %ind = ismember(sites,w);
%     %w = [w sites(ind==0)]; %%add new sites to the list
%     
% 
%     for j=1:length(sites)
%      ind = find( ismember(w,sites{j}) );
%      
%      D(i,ind) = similarity(j);
%      D(ind,i) = similarity(j);
% 
%     end
%          
% end
% % 
 imagesc(D)
     
%% try some stuff with mdscale

DS = 0.5*(D+D');
DnonS = 0.5*(D-D');


imagesc(DS)
%

dia = eye(size(DS));

%DS = DS/100;

DS(dia==1)=0;
%DS=1-DS;

%  DS = imnorm(DS);
%  DS = DS+0.001;
%  DS = DS./1.1;
%  DS(dia==1)=0;

%X = mdscale(DS,2);
opt  = statset('Display','iter','MaxIter',40);
X = mdscale(DS,2,'Criterion','metricstress','Start','random','Replicates',2,'Options',opt);

%%
clf;

x = sign(X(:,1)).*abs(X(:,1)).^1;
y = sign(X(:,2)).*abs(X(:,2)).^1;

plot(x,y,'.')
voronoi(x,y,'r')

for i=1:length(w)
    
   text(x(i),y(i),w{i}) 
    
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

for i=1:length(w)
   name = regexp(w{i},'w{0,3}\.?(.*)','tokens');
   leftOrRight = round(1+rand);
   text(x(i)+0.006*sign(leftOrRight-1.5),y(i),name{1},'FontSize',2.0,'HorizontalAlignment',al{leftOrRight}) 
end   


plot(x,y,'r.')

axis(1.15*[min(x) max(x) min(y) max(y) ])
set(gca,'visible','off')