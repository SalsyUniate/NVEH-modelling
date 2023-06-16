using GLMakie, DynamicalSystems, InteractiveDynamics
using OrdinaryDiffEq

xpit = 0.5e-3  
omega0 = 121.0  
Q = 87.0  
fd = 50.0  
omegad = 2.0 * pi * fd
Ad = 2.5  

u0 = [xpit, 0]
p0 = [xpit, omega0, Q, omegad, Ad]

function my_duffing(du, u, p, t)
    xpit, omega0, Q, omegad, Ad = p
    # x, dotx = u
    x = u[1]
    dotx = u[2]
    du[1] = dotx
    du[2] = -(omega0^2 / 2) * (x^2 / xpit^2 - 1.0) * x - omega0 / Q * dotx + Ad * sin(omegad * t)
    return nothing
end

ds = ContinuousDynamicalSystem(my_duffing, u0, p0)

diffeq = (alg = Vern9(),)
u0s = [
    [xpit, 0.0]
]
trs = [trajectory(ds, 1000, u0; diffeq)[:, SVector(1)] for u0 ∈ u0s]
for i in 2:length(u0s)
    append!(trs[1], trs[i])
end

# Inputs:
j = 2 # the dimension of the plane
tr = trs[1]

brainscan_poincaresos(tr, j; linekw = (transparency = true,))