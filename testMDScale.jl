reload("cmaes.jl")
using ASCIIPlots

N = 20
nd = 3
x = zeros(nd,2*N)

if(false)
    for i=1:N
        x[:,i] = -1*ones(nd) + 0.1*randn(nd)
    end
    for i=N+1:2*N
        x[:,i] = 1*ones(nd) + 0.1*randn(nd)
    end
end

t = linspace(0,2,2*N)
x[1,:] = cos(t)
x[2,:] = sin(t)
x[3,:] = t

N = 2*N

D = zeros(N,N)

distFun(x1,x2) = sqrt( sum( (x1 - x2).^2 ))

for i=1:N
    for j=1:N
        D[i,j] = distFun(x[:,i],x[:,j])
    end
end

## try to reconstruct positions

ndf = 2

function model(p,N,ndf,D)

    p = reshape(p,ndf,N)

    for i=1:N
        for j=1:N
            D[i,j] = distFun(p[:,i],p[:,j])
        end
    end
    return D
end

data = D

pinit = 2*randn(ndf*N)

Dm = zeros(N,N)
errFun(p) = sum( (D-model(p,N,ndf,Dm)).^2 )

pmin = cmaes(errFun,pinit,ones(length(pinit)),lambda=16,stopeval=8000)

rx =  reshape(pmin,ndf,N)

Winston.plot(rx[1,:],rx[1,:])
