do 
{
    # Limpia la pantalla antes de mostrar el menú
    clear-host
    
    # Muestra el menú de opciones
    Write-Host "1.Listar usuarios"
    Write-Host "2.Crear usuarios (pide usuario y contraseña)"
    Write-Host "3.Eliminar usuarios (pide usuario)"
    Write-Host "4.Modificar usuarios (pide usuario y nuevo nombre)"
    Write-Host "5.Salir"
    
    # Solicita al usuario que seleccione una opción
    $x=Read-Host "Seleccione opción"

    # Opción 1: Listar usuarios
    if ($x -eq 1)
    {
        cls  # Limpia la pantalla
        Get-LocalUser | ft  # Muestra los usuarios locales en formato de tabla
    }
    
    # Opción 2: Crear usuario
    if ($x -eq 2)
    {
        cls  # Limpia la pantalla
        $nombrecr=Read-Host "Dime un nombre para el nuevo usuario"  # Solicita el nombre del usuario
        $contra=Read-Host "Dime una contraseña para el nuevo usuario" -AsSecureString  # Solicita la contraseña de manera segura
        New-LocalUser $nombrecr -Password $contra  # Crea el usuario con la contraseña especificada
    }
    
    # Opción 3: Eliminar usuario
    if ($x -eq 3)
    {
        cls  # Limpia la pantalla
        $nombrerm=Read-Host "Dime un nombre de usuario para eliminar"  # Solicita el nombre del usuario a eliminar
        Remove-LocalUser $nombrerm -Confirm  # Elimina el usuario con confirmación
    }
    
    # Opción 4: Modificar usuario
    if ($x -eq 4)
    {
        cls  # Limpia la pantalla
        $nombreviejo=Read-Host "Dime un nombre de usuario existente"  # Solicita el usuario a modificar
        $newname=Read-Host "Dime un nuevo nombre"  # Solicita el nuevo nombre
        Rename-LocalUser $nombreviejo -NewName "$newname"  # Cambia el nombre del usuario
    }
    
    # Si la opción seleccionada no es salir (5), espera una entrada para continuar
    if ($x -ne 5){
        read-host "Pulse para continuar"
    }

} while($x -ne 5)  # Repite el bucle hasta que el usuario seleccione la opción de salir
