using InteractiveDynamics
using DynamicalSystems, GLMakie, OrdinaryDiffEq

function linear_trajectory()
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
    global x = 0

    function linear_harvester!(du, u, p, t)
        xw, omega0, Q, omegad, Ad, alpha, C0, R, M, L = p
        # L = (xw / omega0) * sqrt(4 * K_harvesting_APA / M)
        global x = u[1]
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
        2 => 100:0.1:200,
        # 3 => 1:0.01:10.0,
    )
    pnames = Dict(1 => "xw", 2 => "omega0")

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

    ax = Axis(figure[1,1][1,2]; xlabel = "points", ylabel = "distance")
    function distance_from_symmetry(u)
        Ec = (M*omega0^2 / (8*xw^2)) * (x+xw)^2 * (x-xw)^2
        return Ec
    end
    for (i, ob) in enumerate(obs)
        ord = lift(abs -> distance_from_symmetry.(abs).*i/i, ob)
        abs = 1:length(ord[])

        lines!(ax, abs, ord; color = JULIADYNAMICS_COLORS[i])
    end
    ax.limits = ((0, 1000), (0, 12))
    figure
end