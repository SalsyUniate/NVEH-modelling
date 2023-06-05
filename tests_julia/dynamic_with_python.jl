using PyCall
using Plots
# np = pyimport("numpy")
# sp = pyimport("scipy.integrate")
# math = pyimport("math")
# pyimport("numba")


py"""
import numpy as np
from math import pi, sin
from numba import jit

xpit = 0.5e-3  
omega0 = 121.0  
Q = 87.0 
fd = 50.0  
Ad = 2.5  
NT = 1000 
NF = 100  
omegad = 2.0 * pi * fd
Td = fd**-1  
dt = Td / NF  
t = np.arange(NT*NF+1)*dt
X0 = np.array([-4.0 * xpit, 3.0 * xpit * omega0])

@jit(nopython=True)
def f(X, t):
    x, dotx = X
    dotX = np.zeros(2)
    dotX[0] = dotx
    dotX[1] = -omega0/Q * dotx - omega0**2/2 * (x**3/xpit**2 - x) + Ad*sin(omegad*t)
    return dotX

# @jit(nopython=True)
def RK4(func, X0, t):
    dt = t[1] - t[0]
    nt = len(t)
    X = np.zeros([nt, len(X0)])
    X[0] = X0
    for i in range(nt - 1):
        k1 = func(X[i], t[i])
        k2 = func(X[i] + dt / 2.0 * k1, t[i] + dt / 2.0)
        k3 = func(X[i] + dt / 2.0 * k2, t[i] + dt / 2.0)
        k4 = func(X[i] + dt * k3, t[i] + dt)
        X[i + 1] = X[i] + dt / 6.0 * (k1 + 2.0 * k2 + 2.0 * k3 + k4)
    return X

# @jit(nopython=True)
def Duffing():
    sol = RK4(f, X0, t)
    x = sol[:,0]
    dotx = sol[:,1]
    xp = x[::NF]
    dotxp = dotx[::NF]  
    return(xp, dotxp)
"""

n = 150
xaxis = py"""Duffing"""()[1]
yaxis = py"""Duffing"""()[2]
# lines(x, y)

fig = Figure(resolution = (550, 400), backgroundcolor = :white)
ax = Axis(fig[1, 1],
    title = "Duffing oscillator", 
    xlabel = "Speed",
    ylabel = "Acceleration"
    )

    lines!(ax, xaxis, yaxis)
fig