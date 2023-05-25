import numpy as np
from math import pi, sin
from numba import jit

xpit = 0.5e-3  # meters
omega0 = 121.0  # radians per second
Q = 87.0  # dimensionless
fd = 50.0  # Hertz
Ad = 2.5  # meters per second squared
NT = 1000  # NUMBER OF EXCITATION PERIODS
NF = 100  # FRAMES PER EXCITATION PERIODS
fd = 25.0  # Hertz
omegad = 2.0 * pi * fd
Td = fd**-1  # EXCITATION FREQUENCY
dt = Td / NF  # TIME STEP
t = np.arange(NT*NF+1)*dt
X0 = np.array([-4.0 * xpit, 3.0 * xpit * omega0])

@jit(nopython=True)
def f(X, t):
    x, dotx = X
    dotX = np.zeros(2)
    dotX[0] = dotx
    dotX[1] = -omega0/Q * dotx - omega0**2/2 * (x**3/xpit**2 - x) + Ad*sin(omegad*t)
    return dotX

@jit(nopython=True)
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

@jit(nopython=True)
def fonction():
    sol = RK4(f, X0, t)
    x = sol[:,0]
    dotx = sol[:,1]
    xp = x[::NF]
    dotxp = dotx[::NF]  
    return(xp, dotxp)