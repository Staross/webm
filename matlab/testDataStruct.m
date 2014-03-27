N=1000;

w = cell(1,N);
c = zeros(1,N);

for i=1:N
   
    
     s = ['a':'z' 'A':'Z' '0':'9'];
     MAX_ST_LENGTH = 50;
     stLength = randi(MAX_ST_LENGTH);
     nums = randi(numel(s),[1 stLength]);
     st = s (nums);
     
     w{i} = st;
     
     c(i) = randi(100,1);
    
end

%% test 1 : 1.8 s

tic 
for i=1:length(w)
    
    [v ind] = ismember(w{i},w);    
end
toc

%% test 2 : 0.7s

tic

for i=1:1000
    
    
    [v ind] = unique(w);
    
end

toc

%%

N=5000;

w1 = cell(1,N);
w2 = cell(1,N);

s = ['a':'z'];
MAX_ST_LENGTH = 5;
for i=1:N
     
     stLength = randi(MAX_ST_LENGTH);
     nums = randi(numel(s),[1 stLength]);
     st = s (nums);
     
     w1{i} = st;
     c1(i) = randi(100,1);    
     
          
     stLength = randi(MAX_ST_LENGTH);
     nums = randi(numel(s),[1 stLength]);
     st = s (nums);
     
     w2{i} = st;
     c2(i) = randi(100,1);   
end


%%

tic
    [v ind1 ind2] = intersect(w1,w2); 

    v1 = c1(ind1);
    v2 = c2(ind2);
toc


plot(v1,v2,'.')

%%%%%%%%%%%%%%%%%%%%%%%
%% Same with maps

N=1000;

w = containers.Map();
c = zeros(1,N);

for i=1:N
   
    
     s = ['a':'z' 'A':'Z' '0':'9'];
     MAX_ST_LENGTH = 55;
     stLength = randi(MAX_ST_LENGTH);
     nums = randi(numel(s),[1 stLength]);
     st = s (nums);
     
     w(st) = randi(100,1);
         
end

%% test 1 : 1.8 s

tic 

k = w.keys;

for i=1:length(k)
    
       
    ind = w.isKey(k{i});
    
end

toc

%% test with maps

w1 = containers.Map('KeyType', 'char', 'ValueType', 'uint8');

w2 = containers.Map('KeyType', 'char', 'ValueType', 'uint8');

s = ['a':'z'];
MAX_ST_LENGTH = 5;
for i=1:5000
     
     stLength = randi(MAX_ST_LENGTH);
     nums = randi(numel(s),[1 stLength]);
     st = s (nums);
     
     w1(st) = randi(100,1);
     
          
     stLength = randi(MAX_ST_LENGTH);
     nums = randi(numel(s),[1 stLength]);
     st = s (nums);
     
     w2(st) = randi(100,1);    
end

%%

tic

v1 = w1.values;
v2 = w2.values;

ind2 = w1.isKey(w2.keys);
ind1 = w2.isKey(w1.keys);

vv1 = cat(1,v1{ind1});
vv2 = cat(1,v2{ind2});

toc

plot(vv1,vv2,'.')


