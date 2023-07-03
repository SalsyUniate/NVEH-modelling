using InteractiveDynamics
using DynamicalSystems, GLMakie, OrdinaryDiffEq


xw = 0.5e-3
omega0 = 121.0
Q = 87.0
fd = 50.0
omegad = 2.0 * pi * fd
Ad = 2.5
alpha = 0.068
C0 = 1.05e-6
R = 7.83e3
K_harvesting_APA = 0.3e6
M = 17.3e-3


p0 = [xw, omega0, Q, omegad, Ad, alpha, C0, R, K_harvesting_APA, M]

function bistable_harvester(du, u, p, t)
    xw, omega0, Q, omegad, Ad, alpha, C0, R, K_harvesting_APA, M = p
    L = (xw / omega0) * sqrt(4 * K_harvesting_APA / M)

    du[1] = u[2]
    du[2] = -(omega0^2 / 2) * (u[1]^2 / xw^2 - 1.0) * u[1]
        -omega0 / Q * u[2]
        -2.0 * alpha / (M * L) * u[1] * u[3]
        +Ad * sin(omegad * t)
    du[3] = 2.0 * alpha / (L * C0) * u[1] * u[2]
    -   u[3] / (R * C0)
    return nothing
end



# u0 = [xw, 1.0e-3, 0.0, omegad]
u0 = [xw, 1.0e-3, 0.0]

ps = Dict(
    1 => 1:0.1:30,
    2 => 10:0.1:50,
    3 => 1:0.01:10.0,
)
pnames = Dict(1 => "σ", 2 => "ρ", 3 => "β")

lims = (
    (-1000, 1000),
    (-1000, 1000),
    (-1000, 1000),
)

ds = ContinuousDynamicalSystem(bistable_harvester, u0, p0)

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