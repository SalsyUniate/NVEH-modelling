using InteractiveDynamics
using DynamicalSystems, GLMakie, OrdinaryDiffEq


ps = Dict(
    1 => 1:0.1:30,
    2 => 10:0.1:50,
    3 => 1:0.01:10.0,
)
pnames = Dict(1 => "σ", 2 => "ρ", 3 => "β")

lims = (
    (-30, 30),
    (-30, 30),
    (0, 100),
)

ds = Systems.lorenz()


u1 = [10, 20, 40.0]
u3 = [20, 10, 40.0]
u0s = [u1, u3]

idxs = [1, 2, 3]
diffeq = (alg=Tsit5(), dt=0.01, adaptive=false)

figure, obs, step, paramvals = interactive_evolution(
    ds, u0s; ps, idxs, tail=1000, pnames, lims
)

# Use the `slidervals` observable to plot fixed points
lorenzfp(ρ, β) = [
    Point3f(sqrt(β * (ρ - 1)), sqrt(β * (ρ - 1)), ρ - 1),
    Point3f(-sqrt(β * (ρ - 1)), -sqrt(β * (ρ - 1)), ρ - 1),
]

fpobs = lift(lorenzfp, slidervals[2], slidervals[3])
ax = content(figure[1, 1][1, 1])
scatter!(ax, fpobs; markersize=5000, marker=:diamond, color=:black)