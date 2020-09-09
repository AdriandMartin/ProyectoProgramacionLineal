#################################################################
# PROYECTO SUPER-PIZZA DE PROGRAMACIÓN LINEAL
# Asignatura Algoritmia Básica, EINA, universidad de Zaragoza
# --------------------------------------------------------------
# Script: instanciaSuperPizzaTAD.jl
# Autor: Adrián Martín, GitHub -> AdriandMartin
#        © Copyright 2020, Adrián Martín (AdriandMartin)
# Última revisión: 20/08/2020
# Coms: este script implementa el TAD InstanciaSuperPizza, que 
#       define completamente una instancia del problema de 
#       programación lineal de la súper pizza revisitado
#################################################################

# Importación de los paquetes que este script usa
using JuMP, CPLEX       # para plantear y resolver problema de programación lineal
using Random            # para generar instancias
 
#=**********************************************************************************************************************=#
# TIPO DE DATO INSTANCIA

 #=
 # Tipo abstracto de dato "InstanciaSuperPizza", que modela la clase de 
 # problema de la súper pizza revisitado, permitiendo crear instancias 
 # del mismo que almacenan toda la información referente al mismo
=#
mutable struct InstanciaSuperPizza

        # Atributos
        
        # atributos que definen la instancia
        a       # número de amigos
        m       # número de ingredientes
        mmax    # número máximo de ingredientes
        G       # matriz de preferencias con semántica de gustar
        N       # matriz de preferencias con semántica de no gustar
        #----------------------------
        # atributos con la solución óptima para la instancia del problema
        E       # elección de ingredientes que maximiza el número de amigos satisfechos
        optimo  # máximo número de amigos con al menos una de sus preferencias satisfechas
        
        
        #--------------------------------------------------------
        # Métodos 
        
        # observadores
        # En Julia no existe el concepto de privacidad de atributos, por lo que éstos pueden ser accedidos directamente
        
        #----------------------------
        # manipuladores
        solucionar::Function
         #= 
         # Post: calcula el máximo número de amigos que ven satisfecha al menos una de sus 
         #       preferencias con la elección de ingredientes que supone la solución óptima 
         #       para la instancia <<i>> del problema de la súper-pizza, almacenando dicho 
         #       valor óptimo y la elección de ingredientes con que se logra
         #       Además, devuelve el tiempo de ejecución empleado en resolver la instancia 
         #       del problema de programación lineal
        =#
        function resolverInstancia(i::InstanciaSuperPizza)
                # Definición del modelo de optimización
                modelo = Model(CPLEX.Optimizer)

                # Variables del problema
                @variable(modelo, E[1:i.m], Bin)
                @variable(modelo, Z[1:i.a], Bin)

                # Restricciones del problema
                @constraint(modelo, constraint1, sum(E) <= i.mmax)
                A = ( i.G * E + i.N * (ones(i.m) - E) )
                @constraint(modelo, constraint2, A .>= Z)

                # Función objetivo
                @objective(modelo, Max, sum(Z))

                # Resolver el problema de programación lineal midiendo el tiempo de ejecución
                texe = @elapsed optimize!(modelo)	

                # Asignar valor de la función objetivo en la solución óptima
                i.optimo = JuMP.objective_value(modelo) # máximo número de amigos que ven satisfecha al menos una de sus preferencias
                # Asignar elección de ingredientes que maximiza el número de amigos satisfechos en la solución óptima
                i.E = JuMP.value.(E) # elección de ingredientes que maximiza el número de amigos que ven satisfecha al menos una de sus preferencias
                
                # Devolver el tiempo de ejecución empleado en solucionar la instancia del problema
                return texe
        end
        
        #----------------------------
        # auxiliares (estas funciones no se declaran como atributos del tipo y, por tanto, no son accesibles desde fuera del struct)
         #= 
         # Pre: a >= 1 & m >= 1
         # Post: devuelve las matrices G y N, ambas de dimensión a*m y valores binarios, que 
         #       completan de forma aleatoria las preferencias de una instancia del problema 
         #       de la super-pizza con a amigos y m ingredientes. 
         #       Además se cumple que para todo i en [1,a], o existe alguna columna en 
         #       G[i,:] != 0 o existe alguna columna en N[i,:] != 0
         #       También se cumple que para todo i en [1,a], para todo j en [1,m], si 
         #       G[i,j] = 1 entonces N[i,j] = 0, y que si N[i,j] = 1 entonces G[i,j] = 0
        =#
        function generarPreferencias(a,m)
                # Generar preferencias de forma aleatoria
                rango_preferencias = [-1,0,1] # siendo -1 no gustar, 0 no haber dado preferencia y 1 gustar
                preferencias = rand(rango_preferencias,(a,m))

                # Obtener vector lógico que indique con valor 1 las filas en las que todas las preferencias generadas son 0
                amigos_sin_preferencias = map(==(0),sum((map(!=(0),preferencias)),dims=2))
                amigos_sin_preferencias = reshape(amigos_sin_preferencias,size(amigos_sin_preferencias,1))

                # Introducir preferencia distinta de 0 para aquellas filas en las que todas las preferencias tienen ese valor
                for i = findall(==(1), amigos_sin_preferencias)
                        preferencias[i,rand(1:m)] = rand([-1,1])
                end

                # Generar matriz de preferencias igual a gustar
                G = map(==(1),preferencias)
                # Generar matriz de preferencias igual a no gustar
                N = map(==(-1),preferencias)

                return G,N
        end
        
        #----------------------------
        # constructor
         #=
         # Pre: a >= 1 & m >= 1 & 1 <= mmax <= m
         # Post: devuelve un objeto de tipo InstanciaSuperPizza que supone una instancia del problema 
         #       de la super pizza con <<a>> amigos, <<m>> ingredientes posibles, <<mmax>> 
         #       ingredientes máximo a ordenar en una pizza y preferencias generadas aleatoriamente 
         #       asegurando que cada amigo haya manifestado al menos una preferencia sobre algún 
         #       ingrediente y que no se dan casos en los que un amigo ha manifestado sobre el mismo 
         #       ingrediente que le gusta y que no le gusta
        =#
        function InstanciaSuperPizza(a, m, mmax)
                # Comprobaciones sobre los valores con los que se va a crear la instancia
                @assert(1 <= a, "El número de amigos debe ser mayor o igual que 1")
                @assert(1 <= m, "El número de ingradientes posibles debe mayor o igual que 1")
                @assert(mmax <= m, "El número máximo de ingredientes en una pizza debe ser menor o igual que el número de ingredientes posibles")
                
                # Generación de los atributos necesarios para completar la instancia
                G,N = generarPreferencias(a,m)
                
                # Inicialización de atributos para la solución y de las operaciones del TAD
                E = nothing
                optimo = nothing
                
                # Creación de la instancia
                new(a,m,mmax,G,N,E,optimo,resolverInstancia)
        end

end

