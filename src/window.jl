using Gtk
using Cairo

include("plottings.jl")

const io = PipeBuffer()

win = GtkWindow("NVEH modelling", 900, 800) |> (vbox = GtkBox(:v))

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

# b_interactive_evolution = GtkButton("Interactive evolution")
# b_poincare_scan = GtkButton("Poincare scan")

cb = GtkComboBoxText()
choice1 = [-4.0 * xpit, 5.0 * xpit * omega0]
choice2 = [-3.0 * xpit, 4.0 * xpit * omega0]
choice3 = [-3.0 * xpit, 5.0 * xpit * omega0]
choice4 = [-7 * xpit, 20.0 * omega0 * xpit]
choices = ["[-4.0 * xpit, 5.0 * xpit * omega0]", "[-3.0 * xpit, 4.0 * xpit * omega0]",  "[-3.0 * xpit, 5.0 * xpit * omega0]", "[-7 * xpit, 20.0 * omega0 * xpit]"]
for choice in choices
    push!(cb,choice)
end
set_gtk_property!(cb,:active,0)

signal_connect(cb, "changed") do widget, others...
    idx = get_gtk_property(cb, "active", Int)
    if idx == 0 
        global X02 = choice1
    elseif idx == 1
        global X02 = choice2
    elseif idx == 2 
        global X02 = choice3
    elseif idx == 3 
        global X02 = choice4 
    end 
    refresh_gif(dan, X02)
    draw(can)
    showall(win)
end

@guarded draw(can) do widget
    ctx = getgc(can)
    sleep(0.1)
    show_static_plot()
    img = read_from_png(io)
    set_source_surface(ctx, img, 0, 0)
    paint(ctx)
end

function refresh_gif(dan, X02)
    empty!(dan)
    dynamic_plotting(X01, X02)
    dan = GtkImage("dan.gif")
    grid[3:4,4] = dan
    showall(win)
end

signal_connect(sliderA, "value-changed") do widget, others...
    global alpha = GAccessor.value(sliderA)
    draw(can)
    refresh_gif(dan, X02)
end
signal_connect(sliderB, "value-changed") do widget, others...
    global beta = GAccessor.value(sliderB)
    draw(can)
    refresh_gif(dan, X02)
end
signal_connect(sliderD, "value-changed") do widget, others...
    global delta = GAccessor.value(sliderD)
    draw(can)
    refresh_gif(dan, X02)
end

# function launch_poincare_scan()
#     include("src/animations/poincare_scan.jl")
# end

# signal_connect(b_poincare_scan, "clicked") do widget, others...
#     println("got clicked")
#     launch_poincare_scan()
# end

# signal_connect(b_interactive_evolution, "clicked") do widget, others...
#     println("got clicked")
#     include("src/animations/bistable_interactive.jl")
# end

    
grid[4,1:3] = cb
grid[2:3,1] = sliderA   # Cartesian coordinates, g[x,y]
grid[2:3,2] = sliderB
grid[2:3,3] = sliderD

grid[1,1] = labelA   # Cartesian coordinates, g[x,y]
grid[1,2] = labelB
grid[1,3] = labelD

grid[1:2,4] = can
grid[3:4,4] = dan

# grid[1,5] = b_interactive_evolution
# grid[2,5] = b_poincare_scan

push!(vbox, grid)
set_gtk_property!(vbox, :expand, true)
set_gtk_property!(grid, :column_homogeneous, true)
set_gtk_property!(grid, :column_spacing, 15) 


showall(win)
show(can)