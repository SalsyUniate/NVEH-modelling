using InteractiveDynamics
using DynamicalSystems, GLMakie, OrdinaryDiffEq
using LaTeXStrings

function bistable_simple_trajectory()
    function potential_energy(x, p0)
        xw = p0[1]
        omega0 = p0[2]
        M = p0[9]
        return M*omega0^2 / 4.0 * x^2 * (x^2/(2xw^2)-1)
    end

    function potential_energy_state(u)
        x = u[1]
        xw = p0[1]
        omega0 = p0[2]
        M = p0[9]
        return M*omega0^2 / 4.0 * x^2 * (x^2/(2xw^2)-1)
    end

    #SETUP
    xw = 1.0
    omega0 = 2.0*pi*47.0
    Q = 87.0
    fd = 50.0
    omegad = 2.0 * pi * fd
    Ad = 2.5
    km2 = 0.071
    C0 = 1.05e-6
    R = 7.83e3
    M = 17.3e-3
    L = 25e-3
    beta = 1.0
    K = omega0^2*L^2/xw^2 * M/4.0

    #INITIAL PARAMETER + STATE VALUES
    p0 = [xw, beta, Q, km2, Ad, omegad, C0, R, M, L, K]
    u0 = [xw, 1.0e-3]

    ps = Dict(
        1 => 0.7*xw:0.1e-3:3.0*xw,
        2 => 0:0.5:10, 
        3 => 60:10:200,
        4 => 0.05:0.001:0.1,
        5 => 1.0:0.5:10.0,
        6 => 1.0:1:700.0
    )
    pnames = Dict(1 => L"x_w",
        2 => L"\beta",
        3 => L"Q",
        4 => L"k_m^2",
        5 => L"A_d",
        6 => L"\omega_d"
    )

    function simple_bistable_harvester!(du, u, p, t)
        xw, beta, Q, km2, Ad, omegad, C0, R, M, L, K = p

        omega0 = xw/L * sqrt(4*K/M)
        alpha = sqrt(km2*K*Cp)

        x = u[1]
        dotx = u[2]

        du[1] = dotx
        du[2] = -(omega0^2 / 2.0) * (x^2 / xw^2 - 1.0) * x
            -omega0*(1+beta) / Q * dotx
            -2.0 * alpha / (M * L) * x * v
            +Ad * sin(omegad * t)
        return nothing
    end

    ds = ContinuousDynamicalSystem(bistable_harvester!, u0, p0)

    N = 2
    u0s = [[xw, x / N / 2] for x = 0:N-1]

    idxs = [1, 2]

    figure, obs, step, paramvals = interactive_evolution(
        ds, u0s; ps, idxs, tail=1000, tsidxs=nothing, pnames
    )
    

    #PLOT EQUILIBRIUM POSITIONS
    simple_bistable_equilibriums(xw) = [Point2f(-xw, 0.0), Point2f(xw, 0.0)]
    equilibrium_observables = lift(simple_bistable_equilibriums, paramvals[1])
    ax_phase_plane = content(figure[1, 1][1, 1])
    scatter!(ax_phase_plane, equilibrium_observables; markersize=16, marker=:diamond, color=:black)
    supertitle  = Label(figure[0,:][1,1:2], L"""\ddot{x} = -\frac{\omega_0^2}{2} \left( \frac{x^2}{x_w^2} - 1 \right) x - \frac{\omega_0(1+\beta)}{Q} \dot{x} + A_d \sin(\omega_d t) """, fontsize = 20)

    ax = Axis(figure[1,1][1,2]; 
        xlabel = L"\text{Position}, x", 
        ylabel = L"\text{Énergie potentielle}, E_p [J]")

    for (i, ob) in enumerate(obs)
        y = lift(x -> potential_energy_state.(x), ob)
        x_ = 1:length(y[])
        scatter!(ax, x_, y; color=JULIADYNAMICS_COLORS[i])
    end
    ax.limits = ((0, 1000), (-0.1, 0.1))


end
