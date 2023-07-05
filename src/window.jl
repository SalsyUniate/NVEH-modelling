using Gtk
using Cairo

include("animations/bistable_harvester.jl")
include("animations/duffing_oscillator.jl")
include("animations/linear_harvester.jl")


const io = PipeBuffer()

win = GtkWindow("NVEH modelling", 900, 800) |> (vbox = GtkBox(:v))

grid = GtkGrid()

b_bistable = GtkButton("Bistable harvester :/")
b_linear = GtkButton("Linear harvester :/")
b_duffing = GtkButton("Duffing oscillator :)")


signal_connect(b_bistable, "clicked") do widget, others...
    bistable_trajectory()
end

signal_connect(b_duffing, "clicked") do widget, others...
    duffing_trajectory()
end

signal_connect(b_linear, "clicked") do widget, others...
    linear_trajectory()
end


grid[1,1] = b_bistable
grid[1,2] = b_linear
grid[1,3] = b_duffing


push!(vbox, grid)
set_gtk_property!(vbox, :expand, true)
set_gtk_property!(grid, :column_homogeneous, true)
set_gtk_property!(grid, :column_spacing, 15) 


showall(win)