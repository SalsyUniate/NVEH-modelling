using InteractiveDynamics
using DynamicalSystems, GLMakie
using OrdinaryDiffEq

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
    # delta = 2.0
    # p = 0.
    # phi = 0.0
    # x = u[1]
    # dotx = u[2]
    du[1] = u[2]
    du[2] = -(omega0^2 / 2) * (u[1]^2 / xw^2 - 1.0) * u[1]
        - omega0 / Q * u[2] 
        -2.0 * alpha / (M * L) * u[1] * u[3]
        + Ad * sin(omegad * t)
    du[3] = 2.0 * alpha / (L * C0) * u[1] * u[2] 
        - u[3] / (R * C0)
    # du[2] = -(omega0^2 / 2) * (u[1]^2 / xw^2 + 2.0 * delta * u[1] - 1.0) * u[1] - omega0 / Q * u[2] + Ad * sin(omegad * t) + p * sin(phi)
    return nothing
end

u0 = [xw, 1.0e-3, 0.0]

ds = ContinuousDynamicalSystem(bistable_harvester, u0, p0)

N=2
u0s = [[xw, x/N/2, 0.0] for x=0:N-1]

idxs = (1, 2)
diffeq = (alg=Tsit5(), dt=0.01, adaptive=false)

figure = interactive_evolution(
    ds, u0s; idxs, tail=1000, diffeq
)

# Use the `slidervals` observable to plot fixed points
# lorenzfp(ρ,β) = [
#     Point3f(sqrt(β*(ρ-1)), sqrt(β*(ρ-1)), ρ-1),
#     Point3f(-sqrt(β*(ρ-1)), -sqrt(β*(ρ-1)), ρ-1),
# ]

# fpobs = lift(lorenzfp, slidervals[2], slidervals[3])
# ax = content(figure[1,1][1,1])
# scatter!(ax, fpobs; markersize = 5000, marker = :diamond, color = :black)