using DrWatson
using DynamicalSystems, InteractiveDynamics
using OrdinaryDiffEq
import GLMakie

# ds = Systems.henonqheiles()
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
    -u[3] / (R * C0)
    return nothing
end



# u0 = [xw, 1.0e-3, 0.0, omegad]
u0 = [xw, 1.0e-3, 0.0]

ds = ContinuousDynamicalSystem(bistable_harvester, u0, p0)
# ds = ContinuousDynamicalSystem(adim_harvester, u0, p0)

diffeq = (alg=DP5(), dt=1e-3, adaptive=false)
# u0s = [
#     [0.0, -0.25, 0.42, 0.0], # chaotic
#     [0.0, 0.1, 0.5, 0.0], # quasiperiodic
#     [0.0, 0.30266571044921875, 0.4205654433900762, 0.0], # periodic
# ]

N = 5
u0s = [[xw, x / N / 2, 1.0] for x = 0:N-1]
trs = [trajectory(ds, 1000, u0; diffeq=diffeq)[:, SVector(1,2,3)] for u0 ∈ u0s]

fig, ax3D, ax2D = brainscan_poincaresos(trs, 2; linekw = (transparency = false,))
