using InteractiveDynamics, GLMakie, DynamicalSystems

# Cette application demande beaucoup de ressources
# Diagramme de bifurcation

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
kw = 1.0


p0 = [xw, omega0, Q, omegad, Ad, alpha, C0, R, K_harvesting_APA, M, kw]

function bistable_harvester(du, u, p, t)
    xw, omega0, Q, omegad, Ad, alpha, C0, R, K_harvesting_APA, M, kw = p
    L = (xw / omega0) * sqrt(4 * K_harvesting_APA / M)

    du[1] = u[2]
    du[2] = -((kw*omega0)^2 / 2) * (u[1]^2 / (kw*xw)^2 - 1.0) * u[1]
    -omega0 / Q * u[2]
    -2.0 * alpha / (M * L) * u[1] * u[3]
    +Ad * sin(omegad * t)
    du[3] = 2.0 * alpha / (L * C0) * u[1] * u[2]
    -u[3] / (R * C0)
    return nothing
end

u0 = [xw, 1.0e-3, 0.0]
ds_bistable = ContinuousDynamicalSystem(bistable_harvester, u0, p0)
p_min, p_max, "xw"

#p_index = indice du parametre du systeme dynamique on souhaite explorer, le niveau de flambement par exemple
i = p_index = 11
ds, p_min, p_max, parname = Systems.henon(), 0.8, 1.4, "kw"
t = "orbit diagram for the VEH system"

oddata = interactive_orbitdiagram(ds, p_index, p_min, p_max, i;
                                  parname = parname, title = t)

ps, us = scaleod(oddata)
