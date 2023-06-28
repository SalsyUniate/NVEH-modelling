include("modelisation.jl")

function static_plotting()
    fig = Figure(resolution = (600,400), backgroundcolor = :white)
    ax = Axis(fig[1, 1],
        title = "Duffing oscillator", 
        xlabel = "Speed",
        ylabel = "Acceleration"
        )

    xaxis = Duffing(X01)[1]
    yaxis = Duffing(X01)[2]
    lines!(xaxis, yaxis)
    fig
end
show_static_plot() = show(io, MIME("image/png"), static_plotting())

function dynamic_plotting(X01, X02)
    abs1 = Duffing(X01)[1]/xpit
    graph1 = Duffing(X01)[2]/xpit
    abs2 = Duffing(X02)[1]/xpit
    graph2 = Duffing(X02)[2]/xpit
    p = Plots.plot([sin, cos], zeros(0), leg = false, title = "Duffing osillator", xlabel = "Time", ylabel = "Speed")
    anim = Animation()
    for i in 1:7*NF:length(graph1)
        push!(p, [abs1[i], abs2[i]], [graph1[i], graph2[i]])
        frame(anim)
    end
    image = gif(anim, "dan.gif")
end  

dynamic_plotting(X01, X02)