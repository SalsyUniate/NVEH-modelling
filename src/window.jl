using Gtk
using Cairo

include("animations/bistable_interactive.jl")

const io = PipeBuffer()

win = GtkWindow("NVEH modelling", 900, 800) |> (vbox = GtkBox(:v))

grid = GtkGrid()

b_interactive_evolution = GtkButton("Interactive evolution")



signal_connect(b_interactive_evolution, "clicked") do widget, others...

    figure = interactive_evolution(
        ds, u0s; idxs, tail=1000, diffeq
    )
end



grid[1,1] = b_interactive_evolution


push!(vbox, grid)
set_gtk_property!(vbox, :expand, true)
set_gtk_property!(grid, :column_homogeneous, true)
set_gtk_property!(grid, :column_spacing, 15) 


showall(win)