using Gtk
using LaTeXStrings

include("animations/bistable_harvester.jl")
include("animations/duffing_oscillator.jl")
include("animations/linear_harvester.jl")
include("animations/harmonic_oscillator.jl")
include("animations/dimensionless_generator.jl")

const io = PipeBuffer()

win = GtkWindow("NVEH modelling", 900, 800) |> (vbox = GtkBox(:v))

grid = GtkGrid()

l_bistable = GtkLabel("Trajectoire en temps réel d'un récupérateur bistable :")
b_bistable = GtkButton("Récupérateur bistable")

l_linear = GtkLabel("Trajectoire en temps réel d'un récupérateur linéaire :")
b_linear = GtkButton("Récupérateur linéaire")

l_duffing = GtkLabel("Trajectoire en temps réel d'un oscillateur de Duffing :")
b_duffing = GtkButton("Oscillateur de Duffing")

l_harmonic = GtkLabel("Trajectoire en temps réel d'un oscillateur harmonique :")
b_harmonic = GtkButton("Oscillateur harmonique")

l_dimless = GtkLabel("Trajectoire en temps réel d'un générateur sans dimension :")
b_dimless = GtkButton("Générateur sans dimension")

pic = GtkImage("joli.png")

signal_connect(b_bistable, "clicked") do widget, others...
    bistable_trajectory()
end

signal_connect(b_duffing, "clicked") do widget, others...
    duffing_trajectory()
end

signal_connect(b_linear, "clicked") do widget, others...
    linear_trajectory()
end

signal_connect(b_harmonic, "clicked") do widget, others...
    harmonic_trajectory()
end

signal_connect(b_dimless, "clicked") do widget, others...
    dimensionless_trajectory()
end



grid[1,1] = l_bistable
grid[2,1] = b_bistable

grid[1,2] = l_linear
grid[2,2] = b_linear

grid[1,3] = l_duffing
grid[2,3] = b_duffing

grid[1,4] = l_harmonic
grid[2,4] = b_harmonic

grid[1,5] = l_dimless
grid[2,5] = b_dimless

grid[1:2,6] = pic


push!(vbox, grid)
set_gtk_property!(vbox, :expand, true)
set_gtk_property!(grid, :column_homogeneous, true)
set_gtk_property!(grid, :column_spacing, 15) 


showall(win)