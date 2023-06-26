using InteractiveDynamics, GLMakie, OrdinaryDiffEq, DynamicalSystems
diffeq = (alg = Vern9(), abstol = 1e-9, reltol = 1e-9)

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
u0 = [xw, 1.0e-3, 0.0]

p0 = [xw, omega0, Q, omegad, Ad, alpha, C0, R, K_harvesting_APA, M]

function bistable_harvester(du, u, p, t)
    xw, omega0, Q, omegad, Ad, alpha, C0, R, K_harvesting_APA, M = p
    L = (xw / omega0) * sqrt(4 * K_harvesting_APA / M)

    du[1] = u[2]
    du[2] = -(omega0^2 / 2) * (u[1]^2 / xw^2 - 1.0) * u[1]
        -omega0 / Q * u[2]
        -2.0 * alpha / (M * L) * u[1] * u[3]
        +Ad * sin(omegad * t)
    du[3] = 2.0 * alpha / (L * C0) * u[1] * u[2]
        -u[3] / (R * C0)
    return nothing
end

hh = ContinuousDynamicalSystem(bistable_harvester, u0, p0)

# potential(x, y) = 0.5(x^2 + y^2) + (x^2*y - (y^3)/3)
# function energy(x,y,px,py) 
#     0.5(px^2 + py^2) + potential(x,y)
# end 
# const E = energy(get_state(hh)...)

function potential(u)
    M*omega0^2/(8*xw^2) * (u[1]+xw)^2 * (u[1]-xw)^2
end

function energy(u)
    0.5(u[2]^2) + potential(u)
end

const E = energy(get_state(hh)...)

function complete(u)
    V = potential(u)
    # Ky = 0.5*(py^2)
    V ≥ E && error("Point has more energy!")
    u[2] = sqrt(2(E - V))
    ic = u
    return ic
end

plane = (1, 0.0) # first variable crossing 0

state, scene = interactive_poincaresos(hh, plane, (2, 3), complete;
labels = ("q₂" , "p₂"), diffeq...)