# JULIA ANIMATION PHASE SPACE HARMONIC OSCILLATOR
using InteractiveDynamics
using DynamicalSystems, GLMakie
using OrdinaryDiffEq

function duffing_trajectory()
    #SETUP
    alpha = -1.0   # stiffness
    beta = 1.0     # nonlinearity
    gamma = 0.3    # damping
    delta = 0.3    # amplitude of driving force
    omega = 1.2    # frequency of driving force
    global x = 0

    p0 = [alpha, beta, gamma, delta, omega]
    ps = Dict(
        1 => -2.0:0.1:0.0, 
        2 => 0.5:0.1:1.5,  
        3 => 0.1:0.1:0.5,  
        4 => 0.1:0.1:1.0,  
        5 => 0.8:0.1:1.5   
    )
    pnames = Dict(1 => "alpha", 2 => "beta", 3 => "gamma", 4 => "delta", 5 => "omega")

    u0 = [1.0, 0.0]  # initial conditions (position, velocity)

    function duffing!(du, u, p, t)
        alpha, beta, gamma, delta, omega = p
        x = u[1]
        v = u[2]
        du[1] = v
        du[2] = -alpha*x - beta*x^3 - gamma*v + delta*cos(omega*t)
        return nothing
    end

    diffeq = (alg=Tsit5(), dt=0.01, abstol=1.0e-6, reltol=1.0e-6, adaptive=false)
    ds = ContinuousDynamicalSystem(duffing!, u0, p0)

    N = 1  # number of trajectories
    u0s = [[1.0, x/N] for x=0:N-1]

    idxs = [1, 2]

    figure, obs, step, paramvals = interactive_evolution(ds, u0s; ps, idxs, pnames)


    ax = Axis(figure[1,1][1,2]; xlabel = "Position", ylabel = "Énergie potentielle")
    function potential_energy(u)
        Ec = 0.5*alpha*x^2 + 0.25 * beta * x^4
        return Ec
    end
    for (i, ob) in enumerate(obs)
        ord = lift(abs -> potential_energy.(abs).*i/i, ob)
        abs = 1:length(ord[])

        lines!(ax, abs, ord; color = JULIADYNAMICS_COLORS[i])
    end
    ax.limits = ((0, 1000), (-1.5, 0))
    figure


end 



