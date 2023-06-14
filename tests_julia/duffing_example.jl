using InteractiveDynamics
using DynamicalSystems, GLMakie
using OrdinaryDiffEq

diffeq = (alg = Tsit5(), adaptive = false, dt = 0.01)

ds = Systems.duffing()

u1 = [10.0,20.0]
u3 = [20.0,10.0]
u0s = [u1, u3]

idxs = (1, 2)
diffeq = (alg = Tsit5(), dt = 0.01, adaptive = false)

figure = interactive_evolution(
    ds, u0s; idxs, tail = 1000, diffeq
)
