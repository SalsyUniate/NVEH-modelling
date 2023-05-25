using PyCall
using Plots
# np = pyimport("numpy")
# sp = pyimport("scipy.integrate")
# math = pyimport("math")


py"""
import numpy as np
from scipy.integrate import odeint
from math import pi, sin

xpit = 0.5e-3  # meters
omega0 = 121.0  # radians per second
Q = 87.0  # dimensionless
fd = 50.0  # Hertz
omegad = 2.0 * pi * fd
Ad = 2.5  # meters per second squared


NT = 1000 
NF = 360  
Td = 1/fd 
dt = Td / NF 

def f(X, t):
    x, dotx = X
    dotX = np.zeros(2)
    dotX[0] = dotx
    dotX[1] = -omega0/Q * dotx - omega0**2/2 * (x**3/xpit**2 - x) + Ad*sin(omegad*t)
    return dotX


def fonction():
    t = np.arange(NT*NF+1)*dt
    X0 = np.array([-7 * xpit, 20.0 * omega0 * xpit])
    sol = odeint(f, X0, t)
    x = sol[:,0]
    dotx = sol[:,1]
    return(x, dotx)
"""

abs = py"fonction"()[1]
ord = py"fonction"()[2]

plot(abs, ord)

fig, ax, l = lines(points, color = colors,
    colormap = :inferno, transparency = true,
    axis = (; type = Axis3, protrusions = (0, 0, 0, 0),
        viewmode = :fit, limits = (-30, 30, -30, 30, 0, 50)))

record(fig, "lorenz.mp4", 1:120) do frame
    for i in 1:50
        push!(points[], step!(attractor))
        push!(colors[], frame)
    end
    ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame / 120)
    notify.((points, colors))
    l.colorrange = (0, frame)
end