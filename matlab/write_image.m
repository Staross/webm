function [] = write_image(name,res,size)

if ( nargin < 3 )    
    size= 1;
end

if ( nargin < 2 )    
    res= 300;
end

A = print2array(gcf,res);

if (size ~= 1)
    A = imresize(A,size,'bicubic');
end

imwrite(A,name);