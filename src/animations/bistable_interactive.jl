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
# K_harvesting_APA = 0.3e6
M = 17.3e-3
L=25e-3


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
    - v / (R * C0)


    return nothing
end

# dotXout[0] = X[1]
# dotXout[1] = -(kw*w0)**2 * X[0] - w0 / Q * X[1] \
#         - 2. * alpha / (M * L) * kw*xw * X[2]  + Ad * sin(wd * t)
# dotXout[2] = 2. * alpha / (L * C0) * kw*xw * X[1] - X[2] / (R * C0)


function linear_harvester(du, u, p, t)
    xw, omega0, Q, omegad, Ad, alpha, C0, R, M, L = p
    # L = (xw / omega0) * sqrt(4 * K_harvesting_APA / M)
    x = u[1]
    dotx = u[2]
    v = u[3]
    du[1] = dotx
    du[2] = -(omega0^2 / 2.0) * x
        -omega0 / Q * dotx
        -2.0 * alpha / (M * L) * xw * v
        +Ad * sin(omegad * t)
    du[3] = 2.0 * alpha / (L * C0) * xw * dotx
        -v / (R * C0)

    return nothing
end

p0 = [xw, omega0, Q, omegad, Ad, alpha, C0, R, M, L]
u0 = [xw, 1.0e-3, 0.0]

ps = Dict(
    1 => 0.7*p0[1]:0.1e-3:3.0*p0[1],
    # 2 => 10:0.1:50,
    # 3 => 1:0.01:10.0,
)
pnames = Dict(1 => "xw")

# limite du plan 3D (x, dotx, v)
lims = (
    (-5.0*p0[1], 5.0*p0[1]),
    (0.0, 1.0),
    (0.0, 1.0)
)

# ds = ContinuousDynamicalSystem(bistable_harvester, u0, p0)
ds = ContinuousDynamicalSystem(linear_harvester, u0, p0)

# u1 = [10, 20, 40.0]
# u3 = [20, 10, 40.0]
# u0s = [u1, u3]

N = 2
u0s = [[xw, x / N / 2, 1.0] for x = 0:N-1]

idxs = [1, 2, 3]
diffeq = (alg=Tsit5(), dt=0.01, adaptive=true)


figure, obs, step, paramvals = interactive_evolution(
    ds, u0s; ps, idxs, tail=1000, pnames
)

# Use the `slidervals` observable to plot fixed points
# lorenzfp(ρ, β) = [
#     Point3f(sqrt(β * (ρ - 1)), sqrt(β * (ρ - 1)), ρ - 1),
#     Point3f(-sqrt(β * (ρ - 1)), -sqrt(β * (ρ - 1)), ρ - 1),
# ]

# fpobs = lift(lorenzfp, slidervals[2], slidervals[3])
# ax = content(figure[1, 1][1, 1])
# scatter!(ax, fpobs; markersize=5000, marker=:diamond, color=:black)
ax = Axis(figure[1,1][1,2]; xlabel = "points", ylabel = "distance")
function distance_from_symmetry(u)
    Ec = 0.5*M*u[2]^2
    return Ec
end
for (i, ob) in enumerate(obs)
    x = range(0, 100, length=1000) 
    y = sin.(x)* p0[1]
    lines!(ax, x, y; color = JULIADYNAMICS_COLORS[i])
end
ax.limits = ((0, 1000), (0, 12))
figure