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

function lorenz96_rule!(du, u, p, t)
    F = p[1]
    N = length(u)
    # 3 edge cases
    du[1] = (u[2] - u[N-1]) * u[N] - u[1] + F
    du[2] = (u[3] - u[N]) * u[1] - u[2] + F
    du[N] = (u[1] - u[N-2]) * u[N-1] - u[N] + F
    # then the general case
    for n in 3:(N-1)
        du[n] = (u[n+1] - u[n-2]) * u[n-1] - u[n] + F
    end
    return nothing # always `return nothing` for in-place form!
end

N = 6
u0 = range(0.1, 1; length=N)
p0 = [8.0]
lorenz96 = CoupledODEs(lorenz96_rule!, u0, p0)