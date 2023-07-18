using InteractiveDynamics
using DynamicalSystems, GLMakie, OrdinaryDiffEq
using LaTeXStrings


function dimensionless_trajectory()

    xw=0.5e-3
    Ad=2.5
    fd=55
    w0=121.0
    R=7.83e3
    L=25e-3
    M=17.3e-3
    Q=87.0
    alpha=0.068
    C0=1.05e-6
    kw=1.0
    km2 = 0.0274


    function dimensionless_generator!(du, u, p, t)
        xw, Ad, fd, w0, R, L, M, Q, alpha, C0, kw, km2 = p

        Omega = (2.0*pi*fd)/w0
        r = R*C0*w0
        K = alpha^2 / (km2 * C0)
        Adb = Ad/(kw*xw*(kw*w0)^2)

        x = u[1]
        dotx = u[2]
        v = u[3]

        du[1] = dotx
        du[2] = -0.5 * x * (x^2 - 1) - dotx / Q - v * x * km2 + Adb * sin(Omega * t)
        du[3] = x * dotx - v/r
        return nothing
    end

    
    p0 = [xw, Ad, fd, w0, R, L, M, Q, alpha, C0, kw, km2]
    u0 = [1.0, 1.0e-3, 0.0]

    ps = Dict(
        1 => 0.7*p0[1]:0.1e-3:3.0*p0[1],
        2 => 0:0.1:10, 
        3 => 50:0.1e-3:150,
        4 => 100:0.1:200,
        5 => 0:1:200e3
    )
    pnames = Dict(1 => L"x_w", 
        2 => L"A_d", 
        3 => L"f_d",
        4 => L"\omega_0",
        5 => L"R"
    )


    # limite du plan 3D (x, dotx, v)
    lims = (
        (-5.0*p0[1], 5.0*p0[1]),
        (0.0, 1.0),
        (0.0, 1.0)
    )

    ds = ContinuousDynamicalSystem(dimensionless_generator!, u0, p0)

    N = 5
    u0s = [[2.0, x / N / 2, 1.0] for x = 0:N-1]

    idxs = [1, 2]
    diffeq = (alg=Tsit5(), dt=0.01, adaptive=true)


    figure, obs, step, paramvals = interactive_evolution(
        ds, u0s; ps, idxs, tail=1000, pnames
    )


    #PLOT EQUILIBRIUM POSITIONS
    dimless_equilibriums(xw) = [Point2f(-1, 0.0), Point2f(1, 0.0)]
    equilibrium_observables = lift(dimless_equilibriums, paramvals[1])
    ax_phase_plane = content(figure[1, 1][1, 1])
    scatter!(ax_phase_plane, equilibrium_observables; markersize=16, marker=:diamond, color=:black)
    supertitle  = Label(figure[0,:][1,1:2], L"""\ddot{x} = - \frac{x^2}{2}(x^2-1) - \frac{1}{Q} \dot{x} -k_m^2 x v + A_d\sin(\Omega t) """, fontsize = 20)
    title = Label(figure[0,:][2,1:2], L""" \dot{v} = x \dot{x} - \frac{1}{r}v""", fontsize = 20)


    ax = Axis(figure[1,1][1,2]; 
        xlabel = L"\text{Position}, x", 
        ylabel = L"\text{Énergie potentielle}, E_p [J]")

    function potential_energy(u)
        x = u[1]
        xw = p0[1]
        # newx = x/xw
        return x^4/8 - x^2/4 + 1/8
        # return newx^5/20 - newx^3/6
    end 
    for (i, ob) in enumerate(obs)
        y = lift(x -> potential_energy.(x), ob)
        x_ = 1:length(y[])

        scatter!(ax, x_, y; color = JULIADYNAMICS_COLORS[i])
    end
    ax.limits = ((0, 1000), (-1.5, 0))
    figure
end
