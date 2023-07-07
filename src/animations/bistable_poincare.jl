using InteractiveDynamics
using DynamicalSystems, GLMakie
using OrdinaryDiffEq
"""
Poincare map for bistable harvesters
"""
xw = 1.0
omega0 = 1.0
Q = 87.0
fd = 1.0
Td = fd^-1
omegad = 2.0 * pi * fd
Ad = 10.0
alpha = 0.068
C0 = 1.05e-6
R = 7.83e3
K_harvesting_APA = 0.3e6
M = 17.3e-3
L = 25e-3
p0 = [xw, omega0, Q, omegad, Ad, alpha, C0, R, M, L]

function bistable_harvester!(du, u, p, t)
    xw, omega0, Q, omegad, Ad, alpha, C0, R, M, L = p

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

potential_energy(x) = (omega0^2 / (8 * xw^2)) * (x + xw)^2 * (x - xw)^2
mechanical_energy(x, dotx, v) = 0.5*dotx^2 + potential_energy(x)

u0 = [2.5, 2.5, 0.0]
diffeq = (alg=Vern9(), abstol=1e-6, reltol=1e-6)
ds = ContinuousDynamicalSystem(bistable_harvester!, u0, p0)
const E = mechanical_energy(get_state(ds)...)
v = minimum(get_state(ds))
println("Energy E = ",E)

function complete(x, dotx, v)
    Ep = potential_energy(x)
    Ek = 0.5 * (dotx^2)
    Ek + Ep ≥ E && error("Point has more energy!")
    dotx = sqrt(2((E - Ep) - Ek))
    ic = [x, dotx, v]
    return ic
end

plane = (3, 0.0) #v=0
# scatterkwargs = (; aspect=1, limits=(-2, 4, -2, 4))
scatterkwargs = ()

state, scene = interactive_poincaresos(ds, plane, (1, 2), complete;
    labels=("x", "dotx"), scatterkwargs, tfinal=(1.0, 100))

# ax = Axis(state)
# xlims!(ax, -1.0, 1.0)
# ylims!(ax, -1.0, 1.0)
# state.limits = ((-10.0,10.0), (-10.0,10.0))
