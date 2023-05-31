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
global coefTrig = 0



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
function static_plot()
    fig = Figure(resolution = (550, 400), backgroundcolor = :white)
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

function dynamic_plot()
    abs = Duffing()[1]
    ord = Duffing()[2]
    p = Plots.plot([sin, cos], zeros(0), leg = false, title = "Duffing oscillator", xlabel = "Speed", ylabel = "Acceleration")
    anim = Animation()
    for i in 1:8*NF:length(ord)
        push!(p, abs[i], ord[i])
        frame(anim)
    end
    image = gif(anim, "anim_gr_ref002.gif")
end


histio() = show(io, MIME("image/png"), static_plot())
dynamic_plot()

function plotincanvas(h = 900, w = 800)
    win = GtkWindow("Duffing oscillator", h, w) |> (vbox = GtkBox(:v) |> (sliderA = GtkScale(false, -10:10)) |> (sliderB = GtkScale(false, -10:10)) |> (sliderD = GtkScale(false, -10:10)))
    grid = GtkGrid()
    label = GtkLabel("My text")
    Gtk.G_.value(sliderA, 1)
    Gtk.G_.value(sliderB, 1)
    Gtk.G_.value(sliderD, 1)
    movingtrigo = GtkImage("anim_gr_ref002.gif")
    can = GtkCanvas()
    
    @guarded draw(can) do widget
        ctx = getgc(can)
        sleep(0.1)
        histio()
        img = read_from_png(io)
        set_source_surface(ctx, img, 0, 0)
        paint(ctx)
    end


    signal_connect(sliderA, "value-changed") do widget, others...
        global alpha = GAccessor.value(sliderA)
        empty!(movingtrigo)
        dynamic_plot()
        movingtrigo = GtkImage("anim_gr_ref002.gif")
        grid[3,1] = movingtrigo
        draw(can)
        showall(win)
    end
    signal_connect(sliderB, "value-changed") do widget, others...
        global beta = GAccessor.value(sliderB)
        empty!(movingtrigo)
        dynamic_plot()
        movingtrigo = GtkImage("anim_gr_ref002.gif")
        grid[3,1] = movingtrigo
        draw(can)
        showall(win)
    end
    signal_connect(sliderD, "value-changed") do widget, others...
        global delta = GAccessor.value(sliderD)
        empty!(movingtrigo)
        dynamic_plot()
        movingtrigo = GtkImage("anim_gr_ref002.gif")
        grid[3,1] = movingtrigo
        draw(can)
        showall(win)
    end

    grid[1,1] = label
    grid[1,2] = sliderA   # Cartesian coordinates, g[x,y]
    grid[1,3] = sliderB
    grid[1,4] = sliderD
   
    grid[2,1] = can
    grid[3,1] = movingtrigo


    # id = signal_connect((w) -> draw(can), slideA, "value-changed")
    set_gtk_property!(grid, :column_homogeneous, true)
    set_gtk_property!(grid, :column_spacing, 15)    
    push!(vbox, grid)
    set_gtk_property!(vbox, :expand, can, true)

    showall(win)
    show(can)
end

plotincanvas()