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
# X0 = [-4.0*xpit, 3.0*xpit*omega0]
global delta = 1
global alpha = 1
global beta = 1
global coefTrig = 0
global X01 = [-4.0 * xpit, 3.0 * xpit * omega0]
global X02 = [-7 * xpit, 20.0 * omega0 * xpit]

function f(X, t)
    x, dotx = X
    dotX = zeros(2)
    dotX[1] = dotx
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

function Duffing(X0)
    sol = RK4(f, X0, t)
    x = sol[:,1]
    dotx = sol[:,2]
    return (x, dotx)
end 

# PLOT STATIC FIGURE
function static_plot()
    fig = Figure(resolution = (600, 400), backgroundcolor = :white)
    ax = Axis(fig[1, 1],
        title = "Duffing oscillator", 
        xlabel = "Time",
        ylabel = "Speed"
        )

        xaxis = Duffing(X01)[1]/xpit
        yaxis = Duffing(X01)[2]/xpit
        lines!(ax, xaxis, yaxis)
    fig  
end


function dynamic_plot(X01, X02)
    abs1 = Duffing(X01)[1]/xpit
    graph1 = Duffing(X01)[2]/xpit
    abs2 = Duffing(X02)[1]/xpit
    graph2 = Duffing(X02)[2]/xpit
    p = Plots.plot([sin, cos], zeros(0), leg = false, title = "Duffing osillator", xlabel = "Time", ylabel = "Speed")
    anim = Animation()
    for i in 1:4*NF:length(graph1)
        push!(p, [abs1[i], abs2[i]], [graph1[i], graph2[i]])
        frame(anim)
    end
    image = gif(anim, "anim_gr_ref002.gif")
end  

histio() = show(io, MIME("image/png"), static_plot())
dynamic_plot(X01, X02)

function plotincanvas(h = 900, w = 800)
    win = GtkWindow("NVEH modelling", h, w) |> (vbox = GtkBox(:v))
    (sliderA = GtkScale(false, -10:10))
    (sliderB = GtkScale(false, -10:10))
    (sliderD = GtkScale(false, -10:10))

    labelA = GtkLabel("alpha")
    labelB = GtkLabel("beta")
    labelD = GtkLabel("delta")
    grid = GtkGrid()
    # label = GtkLabel("My text")
    Gtk.G_.value(sliderA, 1)
    Gtk.G_.value(sliderB, 1)
    Gtk.G_.value(sliderD, 1)
    movingtrigo = GtkImage("anim_gr_ref002.gif")
    can = GtkCanvas()

    # b_interactive_evolution = GtkButton("Interactive evolution")
    # b_poincare_scan = GtkButton("Poincare scan")


    
    @guarded draw(can) do widget
        ctx = getgc(can)
        sleep(0.1)
        histio()
        img = read_from_png(io)
        set_source_surface(ctx, img, 0, 0)
        paint(ctx)
    end

    cb = GtkComboBoxText()
    choice1 = [-4.0 * xpit, 5.0 * xpit * omega0]
    choice2 = [-3.0 * xpit, 4.0 * xpit * omega0]
    choice3 = [-3.0 * xpit, 5.0 * xpit * omega0]
    choice4 = [-7 * xpit, 20.0 * omega0 * xpit]
    choices = ["[-4.0 * xpit, 5.0 * xpit * omega0]", "[-3.0 * xpit, 4.0 * xpit * omega0]",  "[-3.0 * xpit, 5.0 * xpit * omega0]", "[-7 * xpit, 20.0 * omega0 * xpit]"]
    for choice in choices
        push!(cb,choice)
    end
    set_gtk_property!(cb,:active,0)


    signal_connect(cb, "changed") do widget, others...
        idx = get_gtk_property(cb, "active", Int)
        if idx == 0 
            global X02 = choice1
        elseif idx == 1
            global X02 = choice2
        elseif idx == 2 
            global X02 = choice3
        elseif idx == 3 
            global X02 = choice4 
        end 
        empty!(movingtrigo)
        dynamic_plot(X01, X02)
        movingtrigo = GtkImage("anim_gr_ref002.gif")
        grid[3:4,4] = movingtrigo
        draw(can)
        showall(win)
    end
    
    signal_connect(sliderA, "value-changed") do widget, others...
        global alpha = GAccessor.value(sliderA)
        empty!(movingtrigo)
        dynamic_plot(X01, X02)
        movingtrigo = GtkImage("anim_gr_ref002.gif")
        grid[3:4,4] = movingtrigo
        draw(can)
        showall(win)
    end
    signal_connect(sliderB, "value-changed") do widget, others...
        global beta = GAccessor.value(sliderB)
        empty!(movingtrigo)
        dynamic_plot(X01, X02)
        movingtrigo = GtkImage("anim_gr_ref002.gif")
        grid[3:4,4] = movingtrigo
        draw(can)
        showall(win)
    end
    signal_connect(sliderD, "value-changed") do widget, others...
        global delta = GAccessor.value(sliderD)
        empty!(movingtrigo)
        dynamic_plot(X01, X02)
        movingtrigo = GtkImage("anim_gr_ref002.gif")
        grid[3:4,4] = movingtrigo
        draw(can)
        showall(win)
    end

    # function button_clicked_callback_1(widget)
    #     include("tests_julia/bistable_interactiveevolution.jl")
    # end
    # function button_clicked_callback_2(widget)
    #     include("tests_julia/bistable_scanpoincare.jl")
    # end


    # id = signal_connect(button_clicked_callback_1, b_interactive_evolution, "clicked")
    # id = signal_connect(button_clicked_callback_2, b_poincare_scan, "clicked")


    grid[4,1:3] = cb
    grid[2:3,1] = sliderA   # Cartesian coordinates, g[x,y]
    grid[2:3,2] = sliderB
    grid[2:3,3] = sliderD

    grid[1,1] = labelA   # Cartesian coordinates, g[x,y]
    grid[1,2] = labelB
    grid[1,3] = labelD
   
    grid[1:2,4] = can
    grid[3:4,4] = movingtrigo

    # grid[1,5] = b_interactive_evolution
    # grid[2,5] = b_poincare_scan

    # id = signal_connect((w) -> draw(can), slideA, "value-changed")
 
    push!(vbox, grid)
    set_gtk_property!(vbox, :expand, true)
    set_gtk_property!(grid, :column_homogeneous, true)
    set_gtk_property!(grid, :column_spacing, 15) 

    showall(win)
    show(can)

end

plotincanvas()