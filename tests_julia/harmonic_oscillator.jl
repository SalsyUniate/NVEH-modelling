# JULIA ANIMATION PHASE SPACE HARMONIC OSCILLATOR
using InteractiveDynamics
using DynamicalSystems, GLMakie
using OrdinaryDiffEq

#SETUP
m = 1.0  
k = 1.0   
d = 0.2   

p0 = [m, k, d]
ps = Dict(
    1 => 0.5:0.1:1.5,  
    2 => 0.5:0.1:1.5,  
    3 => 0.1:0.1:0.5   
)

pnames = Dict(1 => "mass", 2 => "spring constant", 3 => "damping coefficient")

u0 = [1.0, 0.0] 

function harmonic_oscillator!(du, u, p, t)
    m, k, d = p
    x = u[1]
    v = u[2]
    du[1] = v
    du[2] = -(k / m) * x - (d / m) * v
    return nothing
end

diffeq = (alg=Tsit5(), dt=0.01, abstol=1.0e-6, reltol=1.0e-6, adaptive=false)
ds = ContinuousDynamicalSystem(harmonic_oscillator!, u0, p0)

N = 10  # number of trajectories
u0s = [[1.0, x / N] for x = 0:N-1]

idxs = [1, 2]

figure = interactive_evolution(ds, u0s; ps, idxs, pnames)