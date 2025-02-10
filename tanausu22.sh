#!/bin/bash

# Mensaje de advertencia para ejecutar el script con permisos de administrador
echo "EJECUTE EL SCRIPT CON PERMISOS DE ADMINISTRADOR PARA SU CORRECTO FUNCIONAMIENTO."
echo " "

# Verifica si se ha pasado exactamente un parámetro al script
if [ "$#" -ne 1 ]; then
    echo "Pase solamente un parametro"
fi

# Inicializa la variable n con valor 1
let "n = 1"

# Busca el archivo especificado en todo el sistema y guarda la ruta en la variable 'ruta'
ruta=$(sudo find / -type f -name $1 2> /dev/null)

# Verifica si el archivo existe en el sistema
if [ -f $1 ] && [ -e $1 ]; then

    # Itera sobre las líneas del archivo encontrado (separando por el cuarto campo con awk)
    for i in $(cat $ruta | awk -F ":" '{print $4}'); do 

        # Verifica si el usuario extraído existe en /etc/passwd
        if [[ $(cat /etc/passwd | grep -w $i) ]]; then 
            
            # Crea el directorio del usuario en /home/proyecto si no existe
            sudo mkdir -p /home/proyecto/$i
            
            # Mueve los archivos del directorio trabajo del usuario al nuevo directorio
            sudo mv "/home/$i/trabajo/"* "/home/proyecto/$i"
            
            # Registra la acción en bajas.log
            echo "$(date +%D)-$(date +%T)-$i-/home/proyecto/$i" >> bajas.log

            # Itera sobre los archivos movidos y registra cada uno en bajas.log
            for j in $(ls /home/proyecto/$i); do
                echo "$n:$j" >> bajas.log
                let "n = n + 1"
                # Cambia el propietario del archivo a root
                sudo chown root:root /home/proyecto/$i/$j
            done
            
            # Ajusta el contador y registra el total de archivos movidos
            let "n = n - 1"
            echo "Total de fichero movidos: $n" >> bajas.log
            
            # Elimina el usuario y su directorio home
            sudo userdel -r $i 2> /dev/null
        else
            # Si el usuario no existe, se registra en error.log
            echo "$(date +%D)-$(date +%T)-$(cat $ruta | grep -w $i | awk -F : '{print $4 "-" $1 "-" $2 "-" $3}')-ERROR:login no existe en el sistema" >> error.log
        fi
    done
else 
    # Mensaje si el archivo especificado no existe
    echo "El fichero que ha elegido no existe. Escoja otro."
fi
