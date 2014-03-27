function unrolled = printPath(path,depth)

if(depth==0)
    fprintf(['\n\n']);
end

t = '';

for i=1:depth
   t = [t '\t']; 
end

fprintf([t path{1} '\n']);

unrolled{1} = path{1};

for i=2:length(path)
    unrolled = [unrolled printPath(path{i},depth+1)];
end