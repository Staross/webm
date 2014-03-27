function [w count] = countWords(w)

if( ~isempty(w) )
    t = tabulate(w);

    count = cell2mat( t(:,2) );
    w = t(:,1);

    [count ind] = sort(count,'descend');    
    w = w(ind);
else
    w{1}='';
    count(1) = 1;
end