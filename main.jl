#################################################################
# PROYECTO SUPER-PIZZA DE PROGRAMACIÓN LINEAL
# Asignatura Algoritmia Básica, EINA, universidad de Zaragoza
# --------------------------------------------------------------
# Script: main.jl
# Autor: Adrián Martín, GitHub -> AdriandMartin
#        © Copyright 2020, Adrián Martín (AdriandMartin)
# Última revisión: 20/08/2020
# Coms: este script resuelve el problema de la súper pizza 
#       revisitado para las instancias dadas en el fichero 
#       de nombre dado como tercer argumento, almacenando su 
#       solución (la media de los resultados obtenidos tras el 
#       número de repeticiones de cada instancia dado como 
#       segundo argumento) en otro fichero en formato JLD2 con 
#       nombre indicado como cuarto argumento (en caso de darse, 
#       si no se indica se guarda en un fichero de nombre 
#       "resultados" y extensión "jld2"), cuando el primer 
#       argumento es "run"
#       
#       este script genera una gráfica tridimensional con
#       los resultados de tiempo de ejecución y número óptimo de 
#       amigos dado en formato JLD2 como segundo argumento que 
#       guarda en formato PNG con el nombre que se indique como 
#       tercer argumento (en caso de darse, si no se indica se 
#       guarda en dos fichero con nombres "grafica-tiempo" y 
#       "grafica-optimo"), cuando el primer argumento es "plot"
#################################################################

# Include de scripts implementados que usa
include("instanciaSuperPizzaTAD.jl")    # TAD que define instancias del problema de la súper pizza
include("funcionesEntradaSalida.jl")    # funciones que cargan, almacenan instancias del problema de la súper pizza y grafican sus resultados

#=**********************************************************************************************************************=#
# FUNCIONES AUXILIARES

#=
 # Pre: <<instancias>> es un diccionario acorde a la especificación que se describe en el script "funcionesEntradaSalida", 
 #      <<repeticiones>> es un número natural mayor que 0 y <<nombreSalida>> es una ruta válida en el sistema de ficheros
 # Post: ejecuta <<repeticiones>> veces cada una de las instancias descritas como claves en el diccionario <<instancias>>, 
 #      y tras asociarle a cada una de ellas los resultados obtenidos, vuelca el contenido del diccionario en un fichero 
 #      con el nombre dado en <<resultados>>
=#
function run(repeticiones, instancias, nombreSalida="resultados")
        for instancia in keys(instancias)
                # Obtención de los parámetros que no se generan automáticamente y sirven para caracterizar la instancia
                a = instancia[1]
                m = instancia[2]
                mmax = instancia[3]

                # Definición de la misma instancia repeticiones veces
                experimentaciones = [InstanciaSuperPizza(a,m,mmax) for i=1:repeticiones]

                # Resolver las instancias
                tEjecucion = [experimentaciones[i].solucionar(experimentaciones[i]) for i=1:repeticiones]

                # Asignar la media de los resultados, (optimo, Texe), como valor asociado a la terna (a,m,mmax) en el diccionario
                instancias[(a,m,mmax)] = ( sum([experimentaciones[i].optimo for i=1:repeticiones])/repeticiones, sum([tEjecucion[i] for i=1:repeticiones])/repeticiones )
        end
        guardarJLD2(instancias, nombreSalida)
        return nothing
end

#=
 # Pre: <<instancias>> es un diccionario acorde a la especificación que se describe en el script "funcionesEntradaSalida", 
 #      y <<nombreGraficas>> es una ruta válida en el sistema de ficheros
 # Post: abre dos ventanas, una en la que muestra la gráfica tridimensional correspondiente a las ternas de valores 
 #      (a,mmax/m,óptimo) y otra a las ternas de valores (a, mmax/m,tiempo de ejecución), estraídos de los valores de 
 #      clave/valor almacenados en <<instancias>>
=#
function plot(instancias, nombreGraficas="grafica")
        graficarResultados(instancias, nombreGraficas)
        return nothing
end

#=**********************************************************************************************************************=#
# CÓDIGO PRINCIPAL

# "Switch-case" de parsing de argumentos de línea de comandos
ejecucionSolicitada = nothing
if size(ARGS,1) == 4 && ARGS[1] == "run"
        try
                global ejecucionSolicitada = ("RUN", parse(Int,ARGS[2]), ARGS[3], ARGS[4])
                @assert(ejecucionSolicitada[2] >= 1, "ERROR, el número de repeticiones incicadas para cada instancia debe ser mayor o igual que 1")
        catch
                println("ERROR en \"", ARGS[2], "\", el número de repeticiones incicadas para cada instancia debe ser un número mayor o igual que 1")
                exit(4)
        end
elseif size(ARGS,1) == 3
        if ARGS[1] == "run"
                try
                        global ejecucionSolicitada = ("RUN", parse(Int,ARGS[2]), ARGS[3], nothing)
                        @assert(ejecucionSolicitada[2] >= 1, "ERROR, el número de repeticiones incicadas para cada instancia debe ser mayor o igual que 1")
                catch
                        println("ERROR en \"", ARGS[2], "\", el número de repeticiones incicadas para cada instancia debe ser un número mayor o igual que 1")
                        exit(4)
                end
        elseif ARGS[1] == "plot"
                global ejecucionSolicitada = ("PLOT", ARGS[2], ARGS[3])
        end
elseif size(ARGS,1) == 2 && ARGS[1] == "plot"
        global ejecucionSolicitada = ("PLOT", ARGS[2], nothing)
else
        println("ERROR, ejecutar como: \"julia ", PROGRAM_FILE, " run  <N> <fichero TXT instancias> [<nombre JLD2 resultados>]\" ...para (1)")
        println("              o como: \"julia ", PROGRAM_FILE, " plot <nombre JLD2 resultados> [<nombre PNG gráfica>]\"         ...para (2)")
        println("...(1) resolver N veces cada instancia especificada en el fichero TXT y volcar la media de los resultados obtenidos en un fichero JLD2 de nombre dado (sin extensión)")
        println("...(2) graficar los resultados dados en un fichero JLD2 guardando las dos gráficas, una de tiempo de ejecución y otra de valores óptimos obtenidos, en formato PNG con el nombre dado")
        println("...en caso de no darse los argumentos entre corchetes, se usarán los nombres por defecto, \"resultados\" y \"grafica\", respectivamente")
        exit(3)
end

# Ejecución solicitada
if ejecucionSolicitada[1] == "RUN"
        instancias = cargarCSV(ejecucionSolicitada[3])
        ejecucionSolicitada[4] == nothing ? run(ejecucionSolicitada[2],instancias) : run(ejecucionSolicitada[2],instancias,ejecucionSolicitada[4])

elseif ejecucionSolicitada[1] == "PLOT"
        instancias = cargarJLD2(ejecucionSolicitada[2])
        #ejecucionSolicitada[3] == nothing ? plot(instancias) : plot(instancias,ejecucionSolicitada[3])
        ################################################################
        # ADVERTENCIA: la línea anterior se ha tenido que reemplazar por el código que sigue, que es una copia de la implementación de la función 
        #              "graficarResultados" del script "funcionesEntradaSalida.jl" arreglando antes el que el nombre de las gráficas se pueda haber 
        #              dado o no como arguento del script "mail.jl". Se ha tenido que recurrir a esto para mantener la interfaz del script ya que, 
        #              si bien el código está bien, no es posible usar la función "display" dentro de funciones, solo directamente en el script. En 
        #              el momento en el que ese aspecto sea solucionado, se podría eliminar todo el código añadido a continuación hasta "FIN 
        #              ADVERTENCIA" reemplazándolo por la línea comentada que precede a esta sección de código, pues la implementación es la misma 
        #              solo que accedida de manera distinta
        #              Como las dependencias de paquetes se incluyen en el actual script por medio de incluir el script "funcionesEntradaSalida.jl", 
        #              ninguna modificación adicional es necesaria

        # Solucionar posibilidad de que no haya nombre para la gráfica
        rutaFicheroPNG = ejecucionSolicitada[3] == nothing ? "grafica" : ejecucionSolicitada[3]

        # Preparación del backend para el plotting
        pyplot()
        
        # Obtener los valores en cada eje
        valores = [(clave[1],clave[2],clave[3],instancias[clave][1],instancias[clave][2]) for clave in keys(instancias)]

        OX = [valor[1] for valor in valores]
        OY = [valor[3]/valor[2] for valor in valores]
        OZ_optimo = [valor[4] for valor in valores]
        OZ_tiempo = [valor[5] for valor in valores]

        # Plot de tiempo de ejecución
        println("Mostrando gráfica de tiempo de ejecución medio...")
        # https://matplotlib.org/3.3.1/api/api_changes.html#removals
        # Cambio en la API todavía no implementado en PyPlot de Julia, deja argumento set_ticklabels vacío y "Axis.set_ticklabels() does not accept arbitrary positional arguments other than ticklabels"
        display(surface(OX,OY,OZ_tiempo,title = "Tiempo de ejecución problema súper pizza", xlabel = "amigos", ylabel = "nº ingredientes máximo / nº ingredientes", zlabel = "Texe", size = (800,800), set_ticklabels = "ticklabels"))
        try
                print("Pulse 's'+<Enter> para guardar la gráfica con la orientación inicial antes de salir o <Enter> para no hacerlo...")
                guardar = readline()
                if guardar == "s"
                        savefig(string(rutaFicheroPNG,"-tiempo.png"))
                end
        catch
                println("ERROR: no se ha podido guardar la gráfica como imagen en ", string(rutaFicheroPNG,"-tiempo.png"))
                println("-> Revisar si se tienen permisos para escribir en la ruta indicada")
                println("Saliendo con código de error 2...")
                exit(2) # terminar la ejecución de Julia
        end

        # Plot de número de amigos satisfechos
        println("Mostrando gráfica de número medios de amigos satisfechos")
        # https://matplotlib.org/3.3.1/api/api_changes.html#removals
        # Cambio en la API todavía no implementado en PyPlot de Julia, deja argumento set_ticklabels vacío y "Axis.set_ticklabels() does not accept arbitrary positional arguments other than ticklabels"
        display(surface(OX,OY,OZ_optimo,title = "Nº amigos satisfechos problema súper pizza", xlabel = "amigos", ylabel = "nº ingredientes máximo / nº ingredientes", zlabel = "nº amigos satisfechos", size = (800,800), set_ticklabels = "ticklabels"))
        try
                print("Pulse 's'+<Enter> para guardar la gráfica con la orientación inicial antes de salir o <Enter> para no hacerlo...")
                guardar = readline()
                if guardar == "s"
                        savefig(string(rutaFicheroPNG,"-optimo.png"))
                end
        catch
                println("ERROR: no se ha podido guardar la gráfica como imagen en ", string(rutaFicheroPNG,"-optimo.png"))
                println("-> Revisar si se tienen permisos para escribir en la ruta indicada")
                println("Saliendo con código de error 2...")
                exit(2) # terminar la ejecución de Julia
        end

        # FIN ADVERTENCIA: fin del fragmento de código añadido
        ################################################################

end

# Finalización
println("Ejecución terminada con éxito")
exit(0)
