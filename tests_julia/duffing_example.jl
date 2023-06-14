using InteractiveDynamics
using DynamicalSystems, GLMakie
using OrdinaryDiffEq

xpit = 0.5e-3  
omega0 = 121.0 
Q = 87.0  
fd = 50.0  
omegad = 2.0 * pi * fd
Ad = 2.5 

p0 = [xpit, omega0, Q, omegad, Ad]


function my_duffing(du, u, p, t)
    xpit, omega0, Q, omegad, Ad = p
    x = u[1]
    dotx = u[2]
    du[1] = dotx
    du[2] = -(omega0^2 / 2) * (x^2 / xpit^2 - 1.0) * x - omega0 / Q * dotx + Ad * sin(omegad * t)
    return nothing
end


ds = ContinuousDynamicalSystem(my_duffing, u0, p0)

N=2
u0s = [[xpit, x/N/2] for x=0:N-1]

idxs = (1, 2)
diffeq = (alg=Tsit5(), dt=0.002, adaptive=false)

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