using GLMakie
using Observables 
using CairoMakie
# using Gadfly
# using RecipesBase

using Plots

# np = pyimport("numpy")

xpit = 0.5e-3  # meters
omega0 = 121.0  # radians per second
Q = 87.0  # dimensionless
fd = 50.0  # Hertz
Ad = 2.5  # meters per second squared
NT = 1000  # NUMBER OF EXCITATION PERIODS
NF = 100  # FRAMES PER EXCITATION PERIODS
fd = 25.0  # Hertz
omegad = 2.0 * pi * fd
Td = 1/fd  # EXCITATION FREQUENCY
dt = Td / NF  # TIME STEP
t = (1:(NT*NF+1))*dt
X0 = [-4.0*xpit, 3.0*xpit*omega0]



function f(X, t)
    x, dotx = X
    dotX = zeros(2)
    dotX[1] = dotx
    dotX[2] = -omega0/Q * dotx - omega0^2/2 * (x^3/xpit^2 - x) + Ad*sin(omegad*t)
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


function Duffing()
    sol = RK4(f, X0, t)
    x = sol[:,1]
    dotx = sol[:,2]
    # xp = x[::NF]
    # dotxp = dotx[::NF]  
    return (x, dotx)
end 


# PLOT STATIC FIGURE
# fig = Figure(backgroundcolor = :black)
# ax = Axis(fig[1, 1],
#     title = "Duffing oscillator", 
#     xlabel = "Speed",
#     ylabel = "Acceleration"
#     )

#     xaxis = Duffing()[1]
#     yaxis = Duffing()[2]
#     lines!(ax, xaxis, yaxis)
# fig


@userplot CirclePlot
@recipe function f(cp::CirclePlot)
    x, y, i = cp.args
    n = length(x)
    inds = circshift(1:n, 1 - i)
    linewidth --> range(0, 10, length = n)
    seriesalpha --> range(0, 1, length = n)
    aspect_ratio --> 1
    label --> false
    x[inds], y[inds]
end

n = 150
x = Duffing()[1]
y = Duffing()[2]

anim = @animate for i ∈ 1:n
    circleplot(x, y, i)
end
gif(anim, "anim_fps15.gif", fps = 15)