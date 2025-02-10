$op = Read-Host "Elige un tipo de pizza (1.Vegetariana/2.No vegetariana): "

# Verifica si el usuario eligió una pizza vegetariana
if ($op -eq 1){

    # Solicita al usuario elegir un ingrediente vegetariano
    $ingveg = Read-Host "Los ingredientes para la pizza vegetariana son 1(tofu)/2(Pimiento)"
    
    # Verifica la elección del ingrediente
    if ($ingveg -eq 1){
        Write-host "Su pizza es vegetariana y contiene tomate, mozzarella y tofu"
    } elseif($ingveg -eq 2){
        Write-host "Su pizza es vegetariana y contiene tomate, mozzarella y pimiento"
    } else {
        # Mensaje de error si el usuario introduce una opción inválida
        Write-host "Lo que ha introducido no es un ingrediente de los listados. (1=tofu o 2=pimiento)"
    }

# Verifica si el usuario eligió una pizza no vegetariana
} elseif($op -eq 2){

    # Muestra las opciones de ingredientes no vegetarianos
    Write-Host "1.Peperoni"
    Write-Host "2.Jamón"
    Write-Host "3.Salmón"

    # Solicita al usuario elegir un ingrediente no vegetariano
    $ingnoveg = Read-host "Escoja un ingrediente: "

    # Utiliza una estructura switch para evaluar la elección del usuario
    switch($ingnoveg) {
        1{
            Write-host "Su pizza es no vegetariana y contiene tomate, mozzarella y peperoni"
        }
        2{
            Write-host "Su pizza es no vegetariana y contiene tomate, mozzarella y jamón"
        }
        3{
            Write-host "Su pizza es no vegetariana y contiene tomate, mozzarella y salmón"
        }
        default{
            # Mensaje de error si el usuario introduce una opción inválida
            Write-host "Lo que ha introducido no es uno de los ingredientes listados."
        }
    }
} else {
    # Mensaje de error si el usuario no elige un tipo de pizza válido
    Write-Host "Escoja un tipo de pizza correcto."
}
