using DynamicalSystems, Plots

ds = Systems.duffing(β = 1, ω = 2.2, f = 27.0, d = 0.2) # non-autonomous chaotic system

frames=120
a = trajectory(ds, 10000.0, dt = 2π/frames, Ttr=20π) # every period T = 2π/ω

orbit_length = div(size(a)[1], frames)
a = Matrix(a)

@gif for i in 1:frames
    orbit_points = i:frames:(orbit_length*frames)
    scatter(a[i:frames:(orbit_length*frames), 1], a[i:frames:(orbit_length*frames), 2], markersize=1, html_output_format=:png, 
        leg=false, framestyle=:none, xlims=extrema(a[:,1]), ylims=extrema(a[:,2]))
end