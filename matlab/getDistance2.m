function dist = getDistance2(w1,s1,w2,s2)

    [inter ia ib] = intersect(w1,w2);

    x = ( s1(ia) ); 
    y = ( s2(ib) );

    dif = abs(x-y);
    same = min(abs(x),abs(y)).*(sign(x) == sign(y));

    %under-represented count less
    same(sign(x) < 0) = same(sign(x) < 0) /5 ;

    score = same-dif/2;

    dist = sum(score);
