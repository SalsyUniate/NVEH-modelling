using DynamicalSystems
using PyPlot

ds = Systems.logistic()
i = 1
pvalues = 2:0.1:4
ics = [rand() for m in 1:10]
n = 1000
Ttr = 500
p_index = 1
output = orbitdiagram(ds, i, p_index, pvalues; n=n, Ttr=Ttr)

figure()
for (j, p) in enumerate(pvalues)
    plot(p .* ones(length(output[j])), output[j], lw=0,
        marker="o", ms=0.5, color="black")
end
xlabel("\$r\$");
ylabel("\$x\$");