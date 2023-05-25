using GLMakie
using PyCall
using Observables 

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



## TO MAKE THE WINDOW AND AXIS YOURSELF
# f = Figure(backgroundcolor = :black)
# ax = Axis(f[1, 1],
#     title = "Duffing oscillator", 
#     xlabel = "Speed",
#     ylabel = "Acceleration"
#     )

#     xaxis = py"""fonction"""()[1]
#     yaxis = py"""fonction"""()[2]
#     lines!(ax, xaxis, yaxis)
# f


### TO HAVE THE WINDOW AND AXIS UTOMATICALLY CREATED
# x = range(0, 10, length=100)
# y = sin.(x)

# lines(x, y;
#     figure = (; resolution = (400, 400), backgroundcolor = :tomato),
#     axis = (; title = "Great Window", xlabel = "Sleeping axis", ylabel = "Up axis")
#     )
## OR : 
# figure, axis, lineplot = lines(x, y)
# figure



time = Observable{Real}(0.0)
xs = py"""fonction"""()[1]
ys = py"""fonction"""()[2]

fig = lines(xs, ys, color = :tomato, linewidth = 4,
    axis = (title = @lift("t = $(round($time, digits = 1))"),))

framerate = 30
timestamps = range(0, 2, step=1/framerate)

record(fig, "time_animation.mp4", timestamps;
        framerate = framerate) do t 
    time[] = t
end
