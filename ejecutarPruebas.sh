#!/bin/bash

# Nombres de los ficheros en el actual directorio
INPUT="pruebas"
OUTPUT="resultados"
GRAFICA="grafica"

# Obtención de resultados
julia main.jl run 10 ${INPUT}.csv ${OUTPUT}
# Plot de los resultados obtenidos
julia main.jl plot ${OUTPUT}.jld2 ${GRAFICA}

