function x = norma(x)

x = x -min(x(:));
x = x /max(x(:));