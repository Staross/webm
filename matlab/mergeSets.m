function [newS newC] = mergeSets(s1,c1,s2,c2)

% s1 = {'a','aa','bb','cc','dd','e'};
% c1 = [ 1 , 2 ,  3 ,  6,   1,   4];
% 
% s2 = {'a','agg','bb','ccc','dd','asd','gffasd'};
% c2 = [ 10 , 1 ,  5 ,  1,    1,   4,    7];

[inter indi idi]= intersect(s1,s2);
[setx indx idx] = setxor(s1,s2);

newS = [s1(indx) ;s2(idx)];
newC = [c1(indx) ;c2(idx)];

%intersection

newS = [newS ;s1(indi) ];
newC = [newC ;c1(indi)+c2(idi)];

end