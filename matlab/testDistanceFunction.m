%% load everything

urls = {'www.khronos.org','codeflow.org','www.nydailynews.com',...
    'globalvoicesonline.org','www.sfgate.com','www.huffingtonpost.com','philpapers.org'}

for i=1:length(urls)
    
    load(['data/' stripUrl(urls{i}) '_w.mat'],'w')
    load(['data/' stripUrl(urls{i}) '_c.mat'],'c')
    
     ws{i} = w;
     cs{i}=c;
    
end

%% compute score for one

load wbkg.mat
load cbkg.mat

cBkg = cBkg/max(cBkg);

i = 3;

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

for i=1:length(urls)

    w = ws{i};
    c = cs{i};

    c = c/max(c);

    [I ia ib] = intersect(w,wBkg);
    score = log(c(ia)./cBkg(ib));

    scores{i} = score;
    wsc{i} = w(ia);

end

%% just corellation ?

i = 4;
j = 5;

urls{i}
urls{j}

[inter ia ib] = intersect(wsc{i},wsc{j});

s1 = scores{i};
s2 = scores{j};

w1 = wsc{i};

[v ind] = sort(s1(ia));

s1(ia(ind(end)))
w1(ia(ind(end)))

plot(s1(ia),s2(ib),'.')

corr( s1(ia),s2(ib) )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% let's imaging we have some words counts

x = [-10 -10 0  10 10 20];
y = [10  -10 10 10 20 20];

x=(x);
y=(y);

clc
dif = abs(x-y)
same = min(abs(x),abs(y)).*(sign(x) == sign(y)) 

%under-represented count less
same(sign(x) < 0) = same(sign(x) < 0) /2 

score = same-dif/2

%% get distance 2

clc

i = 5;
j = 1;

[inter ia ib] = intersect(wsc{i},wsc{j});

s1 = scores{i};
s2 = scores{j};

x = ( s1(ia) ); 
y = ( s2(ib) );

dif = abs(x-y);
same = min(abs(x),abs(y)).*(sign(x) == sign(y));

%under-represented count less
same(sign(x) < 0) = same(sign(x) < 0) /5 ;

score = same-dif/10;

[v ind] = sort(score);
plot(s1(ia(ind)),'.')
 
ind=ind(end);
score(ind)

w = wsc{i};
disp( w(ia(ind)) )

w = wsc{j};
disp( w(ib(ind)) )

disp( s1(ia(ind)) )
disp( s2(ib(ind)) )

sum(score)


%% compute distance matrix
N = length(urls);
D = zeros(N); 

for i=1:N
    for j=1:N
       
        if(i~=j)
            D(i,j) = getDistance2(ws{i},scores{i},ws{j},scores{j});
        end
    end 
end

clf
imagesc(D)
colorbar

%%
