using Cairo
using Gtk
using Plots
using GLMakie

const io = PipeBuffer()


xpit = 0.5e-3  
omega0 = 121.0  
Q = 87.0  
fd = 50.0  
Ad = 2.5  
NT = 1000
NF = 100
omegad = 2.0 * pi * fd
Td = 1/fd  
dt = Td / NF  
t = (1:(NT*NF+1))*dt
X0 = [-4.0*xpit, 3.0*xpit*omega0]


function f(X, t)
    x, dotx = X
    dotX = zeros(2)
    dotX[1] = dotx
    dotX[2] = -omega0/Q * dotx - omega0^2/2 * (x^3/xpit^2 - x) + Ad*sin(omegad*t)
    # dotX[2] = - delta * dotx - alpha * x - beta * x^3 + t
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
    # xp = x[::NF]
    # dotxp = dotx[::NF]  
    return (x, dotx)



    fig = Figure(backgroundcolor = :black)
    ax = Axis(fig[1, 1],
        title = "Duffing oscillator", 
        xlabel = "Speed",
        ylabel = "Acceleration"
        )

        xaxis = Duffing()[1]
        yaxis = Duffing()[2]
        lines!(ax, xaxis, yaxis)
end


histio(n) = show(io, MIME("image/png"),  fig)

 
function plotincanvas(h = 900, w = 800)
    win = GtkWindow("Normal Histogram Widget", h, w) |> (vbox = GtkBox(:v) |> (slide = GtkScale(false, 1:500)))
    Gtk.G_.value(slide, 250.0)
    can = GtkCanvas()
    push!(vbox, can)
    set_gtk_property!(vbox, :expand, can, true)
    @guarded draw(can) do widget
        ctx = getgc(can)
        n = Int(Gtk.GAccessor.value(slide))
        histio(n)
        img = read_from_png(io)
        set_source_surface(ctx, img, 0, 0)
        paint(ctx)
    end
    id = signal_connect((w) -> draw(can), slide, "value-changed")
    showall(win)
    show(can)
end

plotincanvas()


