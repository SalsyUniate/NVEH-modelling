# using GLMakie
# using PyCall
# using Observables 

# using PyCall



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



# time = Observable{Real}(0.0)
# xs = @lift(py"""function"""()[1].- $time)
# ys = @lift(py"""function"""()[2].- $time)

# fig = lines(xs, ys, color = :tomato, linewidth = 4,
#     axis = (title = @lift("t = $(round($time, digits = 1))"),))

# framerate = 30
# timestamps = range(0, 5, step=1/framerate)

# record(fig, "time_animation.mp4", timestamps;
#         framerate = framerate) do t 
#     time[] = t
# end

using Plots

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
t = range(0, 2π, length = n)
x = sin.(t)
y = cos.(t)

anim = @animate for i ∈ 1:n
    circleplot(x, y, i)
end
gif(anim, "anim_fps15.gif", fps = 15)