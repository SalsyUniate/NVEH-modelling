using DynamicalSystems, PyPlot
using FFTW, Statistics
hh = Systems.henonheiles()
u0s = [
    [0.0, -0.25, 0.42, 0.0],
    [0.0, 0.1, 0.5, 0.0],
    [0.0, 0.30266571044921875,
        0.4205654433900762, 0.0],
]
δt = 0.05
for (i, u) in enumerate(u0s)
    r = trajectory(
        hh, 1000.0, u; ∆t=δt
    )[:, 1]
    P = abs2.(rfft(r .- mean(r)))
    ν = rfftfreq(length(r)) ./ δt
    semilogy(ν, P ./ maximum(P))
    # ylim(10.0^(-5), 1.0)
end