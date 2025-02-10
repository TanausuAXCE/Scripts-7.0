# Inicializa contadores para días pares e impares
$par = 0
$impar = 0

# Itera sobre los 365 días del año 2025
0..365 | ForEach-Object{
    # Calcula el día del mes sumando los días a la fecha base (1 de enero de 2025)
    $dia = ([datetime]"01/01/2025 00:00").AddDays($_).Day
    
    # Verifica si el día es impar o par y actualiza los contadores
    if ($dia %2) {
        $impar++  # Incrementa el contador de días impares
    } else {
        $par++  # Incrementa el contador de días pares
    }
}

# Muestra los resultados en la consola
"Días pares: " + $par.ToString()
"Días impares: " + $impar.ToString()
