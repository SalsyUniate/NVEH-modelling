using GLMakie
using Observables 
using Plots
using Cairo
using Gtk

const io = PipeBuffer()


xpit = 0.5e-3 
omega0 = 121.0
Q = 87.0  
Ad = 2.5  
NT = 1000  
NF = 100  
fd = 25.0  
omegad = 2.0 * pi * fd
Td = 1/fd 
dt = Td / NF  
t = (1:(NT*NF+1))*dt
X0 = [-4.0*xpit, 3.0*xpit*omega0]
# alpha = Observable(1.0)
# beta = Observable(1.0)
# delta = Observable(1.0)
global delta = 1
global alpha = 1
global beta = 1



function f(X, t)
    x, dotx = X
    dotX = zeros(2)
    dotX[1] = dotx
    # dotX[2] = -omega0/Q * dotx - omega0^2/2 * (x^3/xpit^2 - x) + Ad*sin(omegad*t)
    # dotX[2] = @lift(- $(delta[]) * dotx - $(alpha[]) * x - $(beta[]) * x^3 + t)
    dotX[2] =(- delta * dotx - alpha * x - beta * x^3 + t)
    return dotX
end 

function RK4(f, y0, t)
    n = length(t)
    y = zeros((n, length(y0)))
    y[1,:] = y0
    for i in 1:n-1
        h = t[i+1] - t[i]
        k1 = f(y[i,:], t[i])
        k2 = f(y[i,:] + k1 * h/2, t[i] + h/2)
        k3 = f(y[i,:] + k2 * h/2, t[i] + h/2)
        k4 = f(y[i,:] + k3 * h, t[i] + h)
        y[i+1,:] = y[i,:] + (h/6) * (k1 + 2*k2 + 2*k3 + k4)
    end
    return y
end 

function Duffing()
    sol = RK4(f, X0, t)
    x = sol[:,1]
    dotx = sol[:,2]
    return (x, dotx)
end 


# PLOT STATIC FIGURE
function plotting()
    fig = Figure(resolution = (400, 400), backgroundcolor = :white)
    ax = Axis(fig[1, 1],
        title = "Duffing oscillator", 
        xlabel = "Speed",
        ylabel = "Acceleration"
        )

        xaxis = Duffing()[1]
        yaxis = Duffing()[2]
        lines!(ax, xaxis, yaxis)
    fig
end

p = Plots.plot([sin, cos], zeros(0), leg = false, xlims = (0, 2π), ylims = (-1, 1), resolution = (400, 400))
anim = Animation()
for x = range(0, stop = 2π, length = 20)
    push!(p, x, Float64[sin(x), cos(x)])
    frame(anim)
end
gif(anim, "anim_gr_ref002.gif")
movingtrigo = GtkImage("anim_gr_ref002.gif")


histio() = show(io, MIME("image/png"), plotting())

function plotincanvas(h = 900, w = 800)
    win = GtkWindow("Duffing oscillator", h, w) |> (vbox = GtkBox(:v) |> (sliderA = GtkScale(false, -10:10)) |> (sliderB = GtkScale(false, -10:10)) |> (sliderD = GtkScale(false, -10:10)))
    grid = GtkGrid()
    Gtk.G_.value(sliderA, 1)
    Gtk.G_.value(sliderB, 1)
    Gtk.G_.value(sliderD, 1)
    can = GtkCanvas()
    
    @guarded draw(can) do widget
        ctx = getgc(can)
        global alpha = (Gtk.GAccessor.value(sliderA))
        global beta = (Gtk.GAccessor.value(sliderB))
        global delta = (Gtk.GAccessor.value(sliderD))
        sleep(0.1)
        histio()
        img = read_from_png(io)
        set_source_surface(ctx, img, 0, 0)
        paint(ctx)
    end

    signal_connect(sliderA, "value-changed") do widget, others...
        global alpha = GAccessor.value(sliderA)
        draw(can)
    end
    signal_connect(sliderB, "value-changed") do widget, others...
        global beta = GAccessor.value(sliderB)
        draw(can)
    end
    signal_connect(sliderD, "value-changed") do widget, others...
        global delta = GAccessor.value(sliderD)
        draw(can)
    end

    grid[1,1] = sliderA   # Cartesian coordinates, g[x,y]
    grid[1,2] = sliderB
    grid[1,3] = sliderD
    grid[2,1:3] = can
    grid[5,1:3] = movingtrigo


    # id = signal_connect((w) -> draw(can), slideA, "value-changed")
    set_gtk_property!(grid, :column_homogeneous, true)
    set_gtk_property!(grid, :column_spacing, 15)
    push!(vbox, grid, can, movingtrigo)
    set_gtk_property!(vbox, :expand, can, true)

    showall(win)
    show(can)
end

plotincanvas()