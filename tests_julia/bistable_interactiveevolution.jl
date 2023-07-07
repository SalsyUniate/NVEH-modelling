using InteractiveDynamics
using DynamicalSystems, GLMakie
using OrdinaryDiffEq
"""
Interactive animation for bistable harvesters
"""

function potential_energy(x, p0)
    xw = p0[1]
    omega0 = p0[2]
    M = p0[9]
    return (M * omega0^2 / (8 * xw^2)) * (x + xw)^2 * (x - xw)^2
end

function potential_energy_state(u)
    x = u[1]
    xw = p0[1]
    omega0 = p0[2]
    M = p0[9]
    return (M * omega0^2 / (8 * xw^2)) * (x + xw)^2 * (x - xw)^2
end

xw = 1.0
omega0 = 1.0
Q = 87.0  
fd = 50.0  
omegad = 2.0 * pi * fd
Ad = 2.5 
alpha = 0.068
C0 = 1.05e-6
R = 7.83e3
K_harvesting_APA = 0.3e6
M = 17.3e-3
L = 25e-3
p0 = [xw, omega0, Q, omegad, Ad, alpha, C0, R, M, L]

function bistable_harvester(du, u, p, t)
    xw, omega0, Q, omegad, Ad, alpha, C0, R, M, L = p
    # L = (xw / omega0) * sqrt(4 * K_harvesting_APA / M)

    x = u[1]
    dotx = u[2]
    v = u[3]

    du[1] = dotx
    du[2] = -(omega0^2 / 2.0) * (x^2 / xw^2 - 1.0) * x
    -omega0 / Q * dotx
    -2.0 * alpha / (M * L) * x * v
    +Ad * sin(omegad * t)
    du[3] = 2.0 * alpha / (L * C0) * x * dotx
    -v / (R * C0)
    return nothing
end

p0 = [xw, omega0, Q, omegad, Ad, alpha, C0, R, M, L]
u0 = [xw, 1.0e-3, 0.0]

ps = Dict(
    1 => 0.7*p0[1]:0.1e-3:3.0*p0[1],
    2 => 0:0.1e-3:2,
    3 => 50:0.1e-3:150,
    4 => 1.0:0.1:20.0
)
pnames = Dict(1 => "xw",
    2 => "omega0",
    3 => "Q",
    4 => "omegad"
)

ds = ContinuousDynamicalSystem(bistable_harvester, u0, p0)

N=2
u0s = [[xw, x/N/2, 0.0] for x=0:N-1]

idxs = [1, 2]

plotkwargs = (; :linestyle => nothing)

figure, obs, step, paramvals = interactive_evolution(
    ds, u0s; ps, idxs, tail=1000, tsidxs=nothing, pnames, plotkwargs
)

bistable_equilibriums(xw) = [Point2f(-xw, 0.0), Point2f(xw, 0.0)]
equilibrium_observables = lift(bistable_equilibriums, paramvals[1])
ax_phase_plane = content(figure[1,1][1,1])
scatter!(ax_phase_plane, equilibrium_observables; markersize=16, marker=:diamond, color=:black)
supertitle  = Label(figure[0,:], "THIS IS A TITLE", fontsize = 30)

ax = Axis(figure[1, 1][1, 2]; xlabel="Position, x", ylabel="Énergie potentielle, Ep")

for (i, ob) in enumerate(obs)
    y = lift(x -> potential_energy_state.(x), ob)
    x_ = 1:length(y[])
    scatter!(ax, x_, y; color=JULIADYNAMICS_COLORS[i])
end

ax.limits = ((0, 1000), (-0.1, 0.1))