using Gtk
using Cairo

include("plottings.jl")

const io = PipeBuffer()

win = GtkWindow("Duffing oscillator", 900, 800) |> (vbox = GtkBox(:v))
grid = GtkGrid()
sliderA = GtkScale(false, -10:10)
sliderB = GtkScale(false, -10:10)
sliderD = GtkScale(false, -10:10)

Gtk.G_.value(sliderA, 1)
Gtk.G_.value(sliderB, 1)
Gtk.G_.value(sliderD, 1)

labelA = GtkLabel("alpha")
labelB = GtkLabel("beta")
labelD = GtkLabel("delta")

can = GtkCanvas()
dan = GtkImage("dan.gif")

@guarded draw(can) do widget
    ctx = getgc(can)
    sleep(0.1)
    show_static_plot()
    img = read_from_png(io)
    set_source_surface(ctx, img, 0, 0)
    paint(ctx)
end

function refresh_gif(dan)
    empty!(dan)
    dynamic_plotting()
    dan = GtkImage("dan.gif")
    grid[2,4] = dan
    showall(win)
end

signal_connect(sliderA, "value-changed") do widget, others...
    global alpha = GAccessor.value(sliderA)
    draw(can)
    refresh_gif(dan)
end
signal_connect(sliderB, "value-changed") do widget, others...
    global beta = GAccessor.value(sliderB)
    draw(can)
    refresh_gif(dan)
end
signal_connect(sliderD, "value-changed") do widget, others...
    global delta = GAccessor.value(sliderD)
    draw(can)
    refresh_gif(dan)
end

grid[1,1] = labelA
grid[1,2] = labelB
grid[1,3] = labelD
grid[2,1] = sliderA
grid[2,2] = sliderB
grid[2,3] = sliderD
grid[1,4] = can
grid[2,4] = dan

push!(vbox, grid)
set_gtk_property!(vbox, :expand, true)
set_gtk_property!(grid, :column_homogeneous, true)
set_gtk_property!(grid, :column_spacing, 15) 


showall(win)
show(can)