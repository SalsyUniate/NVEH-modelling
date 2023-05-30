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
alpha = 1
beta = 1
delta = 1



function f(X, t)
    x, dotx = X
    dotX = zeros(2)
    dotX[1] = dotx
    # dotX[2] = -omega0/Q * dotx - omega0^2/2 * (x^3/xpit^2 - x) + Ad*sin(omegad*t)
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


function Duffing()
    sol = RK4(f, X0, t)
    x = sol[:,1]
    dotx = sol[:,2]
    # xp = x[::NF]
    # dotxp = dotx[::NF]  
    return (x, dotx)
end 


# PLOT STATIC FIGURE


fig = Figure(backgroundcolor = :white)
ax = Axis(fig[1, 1],
    title = "Duffing oscillator", 
    xlabel = "Speed",
    ylabel = "Acceleration"
    )

xaxis = Duffing()[1]
yaxis = Duffing()[2]

slide = Slider(fig[2, 1], range = 0:0.01:4.99, startvalue = 3)
lines!(ax, xaxis, yaxis)
# plot(xaxis, yaxis)

display(fig)







### L'ANIMATION AVEC JUSTE UN TRAIT BIZARRE 
# @userplot CirclePlot
# @recipe function f(cp::CirclePlot)
#     x, y, i = cp.args
#     n = length(x)
#     inds = circshift(1:n, 1 - i)
#     linewidth --> range(0, 10, length = n)
#     seriesalpha --> range(0, 1, length = n)
#     aspect_ratio --> 1
#     label --> false
#     x[inds], y[inds]
# end

# n = 150
# x = Duffing()[1]
# y = Duffing()[2]

# anim = @animate for i ∈ 1:n
#     circleplot(x, y, i)
# end
# gif(anim, "anim_fps15.gif", fps = 15)




# default(legend = false)
# x = Duffing()[1]
# y = Duffing()[2]
# # x = y = range(-5, 5, length = 40)
# zs = zeros(0, 40)
# n = 100

# @gif for i in range(0, stop = 2π, length = n)
#     # f(x, y) = sin(x + 10sin(i)) + cos(y)
    

#     # create a plot with 3 subplots and a custom layout
#     l = @layout [a{0.7w} b; c{0.2h}]
#     p = plot(x, y, f, st = [:surface, :contourf], layout = l)

#     # induce a slight oscillating camera angle sweep, in degrees (azimuth, altitude)
#     plot!(p[1], camera = (10 * (1 + cos(i)), 40))

#     # add a tracking line
#     fixed_x = zeros(40)
#     z = map(f, fixed_x, y)
#     plot!(p[1], fixed_x, y, z, line = (:black, 5, 0.2))
#     vline!(p[2], [0], line = (:black, 5))

#     # add to and show the tracked values over time
#     global zs = vcat(zs, z')
#     plot!(p[3], zs, alpha = 0.2, palette = cgrad(:blues).colors)
# end