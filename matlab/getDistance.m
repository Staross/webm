function dist = getDistance(w1,c1,w2,c2)

[inter ia ib] = intersect(w1,w2);

if(~isempty(inter))
    dist = 2*length(inter) / (length(w1) + length(w2)) * (1+corr(c1(ia),c2(ib)));
else
    dist = 0;
end
