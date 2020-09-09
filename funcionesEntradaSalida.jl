#################################################################
# PROYECTO SUPER-PIZZA DE PROGRAMACIÓN LINEAL
# Asignatura Algoritmia Básica, EINA, universidad de Zaragoza
# --------------------------------------------------------------
# Script: funcionesEntradaSalida.jl
# Autor: Adrián Martín, GitHub -> AdriandMartin
#        © Copyright 2020, Adrián Martín (AdriandMartin)
# Última revisión: 20/08/2020
# Coms: este script implementa funciones que abstraen la generación
#       (leyendo desde un fichero CSV con la especificación indicada 
#       en README.txt o cargándolos desde un fichero JLD2), el 
#       almacenamiento en ficheros (en formato JLD2) y la creación 
#       de gráficas tridimensionales con los valores (a,mmax/m,optimo)
#       y (a,mmax/m,tiempo ejecución), respectivamente, de diccionarios 
#       que tienen por clave toda la información necesaria para 
#       generar instancias del problema de la super pizza usando 
#       el TAD instanciaSuperPizzaTAD (es decir, el número de amigos, 
#       el número de ingredientes posibles y el número máximo de 
#       ingredientes que se permite) y como valor asociado el valor 
#       de la función objetivo para su solución óptima y el tiempo de 
#       ejecución en encontrarla 
#################################################################

# Importación de los paquetes que este script usa
using DelimitedFiles    # para tratamiento de ficheros
using JLD2              # para cargar y guardar variables de Julia del almacenamiento persistente
using Plots             # para graficar resultados

#=**********************************************************************************************************************=#
# FUNCIONES PARA CARGAR INSTANCIAS

 #=
 # Pre: <<rutaFicheroCSV>> se corresponde con la ruta de un fichero CSV con el formato indicado en README.txt
 # Post: devuelve un diccionario con elementos que tienen como clave las ternas leídas del fichero entrada y como 
 #       valores asociados a ellas "nothing"
=#
function cargarCSV(rutaFicheroCSV)
        try
	        global fichero = readdlm(rutaFicheroCSV, ',', Int, '\n')
        catch
	        println("ERROR: no se ha podido abrir el fichero ", rutaFicheroCSV)
	        println("-> En el caso de que la ruta sea correcta, el formato no es el indicado en README.txt")
	        println("Saliendo con código de error 1...")
	        exit(1) # terminar la ejecución de Julia
        end
        
        instancias = Dict()
        
        for linea in 1:size(fichero,1)
                clave = (fichero[linea,1],fichero[linea,2],fichero[linea,3])
                instancias[clave] = nothing
        end

        return instancias
end

#=
 # Pre: <<rutaFicheroJLD2>> se corresponde con la ruta de un fichero con formato JLD2 que contiene un diccionario 
 #      de nombre "instancias"
 # Post: devuelve el diccionario de nombre "instancias" almacenado en el fichero JLD2 dado
=#
function cargarJLD2(rutaFicheroJLD2)
        try
                global instancias = nothing
                @load rutaFicheroJLD2 instancias
        catch
                println("ERROR: no se han podido cargar las instancias del fichero ", rutaFicheroJLD2)
                println("-> En el caso de que la ruta sea correcta, el formato no es JLD2")
                println("Saliendo con código de error 1...")
                exit(1) # terminar la ejecución de Julia
        end
        return instancias
end

#=**********************************************************************************************************************=#
# FUNCIONES PARA GUARDAR INSTANCIAS

#=
 # Pre: <<instancias>> es un diccionario acorde a la especificación que se describe en la cabecera de este script, y 
 #      <<rutaFicheroJLD2>> es una ruta válida en el sistema de ficheros
 # Post: almacena el diccionario <<instancias>> en un fichero de extensión JLD2 con el nombre dado en <<rutaFicheroJLD2>>
=#
function guardarJLD2(instancias, rutaFicheroJLD2)
        try
                @save string(rutaFicheroJLD2,".jld2") instancias
        catch
                println("ERROR: no se han podido guardar las instancias en el fichero ", rutaFicheroJLD2)
                println("-> Revisar si se tienen permisos para escribir en la ruta indicada")
                println("Saliendo con código de error 2...")
                exit(2) # terminar la ejecución de Julia
        end
        return nothing
end

#=**********************************************************************************************************************=#
# FUNCIONES PARA GRAFICAR RESULTADOS

#=
 # Pre: <<instancias>> es un diccionario acorde a la especificación que se describe en la cabecera de este script que 
 #      contiene al menos 3 elementos almacenados (pues re requieren al menos tres valores para poder dibujar una gráfica 
 #      tridimensional), y <<rutaFicheroPNG>> es una ruta válida en el sistema de ficheros
 # Post: abre dos ventanas, una en la que muestra la gráfica tridimensional correspondiente a las ternas de valores 
 #      (a,mmax/m,óptimo) y otra a las ternas de valores (a, mmax/m,tiempo de ejecución), estraídos de los valores de 
 #      clave/valor almacenados en <<instancias>>
=#
function graficarResultados(instancias, rutaFicheroPNG)
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

        # Finalizaciń de la función
        return nothing
end

