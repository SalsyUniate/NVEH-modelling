using InteractiveDynamics
using DynamicalSystems, GLMakie, OrdinaryDiffEq

function linear_trajectory()
    xw = 0.5e-3
    omega0 = 1
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


    function linear_harvester!(du, u, p, t)
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
        2 => 0:0.1e-3:2, 
        3 => 50:0.1e-3:150,
        4 => 100:0.1:500
    )
    pnames = Dict(1 => L"x_w", 
        2 => L"\omega_0", 
        3 => L"Q",
        4 => L"\omega_d"
    )


    # limite du plan 3D (x, dotx, v)
    lims = (
        (-5.0*p0[1], 5.0*p0[1]),
        (0.0, 1.0),
        (0.0, 1.0)
    )

    ds = ContinuousDynamicalSystem(linear_harvester!, u0, p0)

    N = 2
    u0s = [[xw, x / N / 2, 1.0] for x = 0:N-1]

    idxs = [1, 2]
    diffeq = (alg=Tsit5(), dt=0.01, adaptive=true)


    figure, obs, step, paramvals = interactive_evolution(
        ds, u0s; ps, idxs, tail=1000, pnames
    )

    supertitle  = Label(figure[0,:][1,1:2], L"""\ddot{x} = -\frac{\omega_0^2}{2} - \frac{\omega_0}{Q}\dot{x} - 2 \frac{\alpha}{ML}x_wv +A_d \sin(\omega_d t)""", fontsize = 23)
    title = Label(figure[0,:][2,1:2], L""" \dot{v} =   2 \frac{\alpha}{LC_0} x_w \dot{x} - \frac{v}{R C_0} """, fontsize = 23)


    ax = Axis(figure[1,1][1,2]; 
        xlabel = L"\text{Position}, x", 
        ylabel = L"\text{Énergie potentielle}, E_p [J]")

    function potential_energy(u)
        Ep = (p0[2]*u[1])^2/4
        return Ep
    end
    for (i, ob) in enumerate(obs)
        y = lift(x -> potential_energy.(x), ob)
        x_ = 1:length(y[])

        scatter!(ax, x_, y; color = JULIADYNAMICS_COLORS[i])
    end
    ax.limits = ((0, 1000), (-1.5, 0))
    figuree
end

