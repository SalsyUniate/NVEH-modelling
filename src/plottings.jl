include("modelisation.jl")

function static_plotting()
    fig = Figure(resolution = (600,450), backgroundcolor = :white)
    ax = Axis(fig[1, 1],
        title = "Duffing oscillator", 
        xlabel = "Speed",
        ylabel = "Acceleration"
        )

    xaxis = Duffing()[1]
    yaxis = Duffing()[2]
    lines!(xaxis, yaxis)
    fig
end
show_static_plot() = show(io, MIME("image/png"), static_plotting())

function dynamic_plotting()
    abs = Duffing()[1]
    ord = Duffing()[2]
    p = Plots.plot([sin, cos], zeros(0), leg = false, title = "Duffing osillator", xlabel = "Time", ylabel = "Speed")
    anim = Animation()
    for i in 1:50*NF:length(ord)
        push!(p, abs[i], ord[i])
        frame(anim)
    end
    gif(anim, "anim_gr_ref002.gif")
end  
dynamic_plotting()