using GLMakie
using Observables 
using CairoMakie
using Plots


xpit = 0.5e-3 
omega0 = 121.0
Q = 87.0  
Ad = 2.5  
NT = 1000  
NF = 100  
fd = 25.0  
omegad = 2.0 * pi * fd
Td = 1/fd 
dt = Td / NF  
t = (1:(NT*NF+1))*dt

global delta = 1
global alpha = 1
global beta = 1
global coefTrig = 0
global X01 = [-4.0 * xpit, 3.0 * xpit * omega0]
global X02 = [-7 * xpit, 20.0 * omega0 * xpit]


function f(X, t)
    x, dotx = X
    dotX = zeros(2)
    dotX[1] = dotx
    dotX[2] = - delta * dotx - alpha * x - beta * x^3 + t
    return dotX
end 


function RK4(f, y0, t)
    n = length(t)
    y = zeros((n, length(y0)))
    y[1,:] = y0
    for i in 1:n-1
        h = t[i+1] - t[i]
        k1 = f(y[i,:], t[i])
        k2 = f(y[i,:] + k1 * h/2, t[i] + h/2)
        k3 = f(y[i,:] + k2 * h/2, t[i] + h/2)
        k4 = f(y[i,:] + k3 * h, t[i] + h)
        y[i+1,:] = y[i,:] + (h/6) * (k1 + 2*k2 + 2*k3 + k4)
    end
    return y
end 


function Duffing(X0)
    sol = RK4(f, X0, t)
    x = sol[:,1]
    dotx = sol[:,2]
    return (x, dotx)
end 