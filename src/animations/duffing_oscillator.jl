# JULIA ANIMATION PHASE SPACE HARMONIC OSCILLATOR
using InteractiveDynamics
using DynamicalSystems, GLMakie


function duffing_trajectory()
    #SETUP
    alpha = -1.0   # stiffness
    beta = 1.0     # nonlinearity
    gamma = 0.3    # amplitude of driving force
    delta = 0.3    # damping
    omega = 1.2    # frequency of driving force


    p0 = [alpha, beta, gamma, delta, omega]
    ps = Dict(
        1 => -2.0:0.1:2.0,
        2 => 0.5:0.1:5.0,
        3 => 0.0:0.05:10.0,
        4 => 0.1:0.01:1.0,
        5 => 0.5:0.1:1.5
    )
    pnames = Dict(1 => L"\alpha", 2 => L"\beta", 3 => L"\gamma", 4 => L"\delta", 5 => L"\omega")

    u0 = [1.0, 0.0]  # initial conditions (position, velocity)

    function duffing!(du, u, p, t)
        alpha, beta, gamma, delta, omega = p
        x = u[1]
        dotx = u[2]
        du[1] = dotx
        du[2] = -alpha*x - beta*x^3 - delta*dotx + gamma*cos(omega*t)
        return nothing
    end
    # total_span = 20*(2.0*pi)/p0[5]

    ds = ContinuousDynamicalSystem(duffing!, u0, p0)

    N = 1  # number of trajectories
    u0s = [[1.0, x/N] for x=0:N-1]

    idxs = [1, 2]

    figure, obs, step, paramvals = interactive_evolution(ds, u0s; ps, idxs, pnames)#, total_span)

    supertitle  = Label(figure[0,:], L"""\ddot{x} = - \alpha x - \beta x^3 - \delta \dot{x} + \gamma \cos(\omega t)""", fontsize = 25)

    ax = Axis(figure[1,1][1,2]; 
        xlabel = L"\text{Position}, x", 
        ylabel = L"\text{Énergie potentielle}, E_p [J]")

    function potential_energy(u)
        Ec = 0.5*p0[1]*u[1]^2 + 0.25 * p0[2] * u[1]^4
        return Ec
    end
    for (i, ob) in enumerate(obs)
        y = lift(x -> potential_energy.(x), ob)
        x_ = 1:length(y[])

        scatter!(ax, x_, y; color = JULIADYNAMICS_COLORS[i])
    end
    ax.limits = ((0, 1000), (-1.5, 0))
    figure


end 

