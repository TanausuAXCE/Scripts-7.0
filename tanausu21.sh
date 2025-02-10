#!/bin/bash

# Buscar las rutas de los directorios Fotografía, Imágenes y Dibujo
rutaFot=$(sudo find / -type d -name Fotografía 2> /dev/null) 
rutaIma=$(sudo find / -type d -name Imágenes 2> /dev/null | head -1) 
rutaDibu=$(sudo find / -type d -name Dibujo 2> /dev/null)

# Almacenar las rutas en un array
carpetas=($rutaFot $rutaIma $rutaDibu)

# Verificar si todas las rutas existen
if [[ $rutaFot && $rutaIma && $rutaDibu ]]; then

   # Recorrer cada carpeta
   for i in $carpetas; do
    # Recorrer cada archivo en la carpeta
    for z in $(ls $i); do
      # Verificar si el archivo NO tiene una extensión de imagen o NO es una imagen válida
      if ! [[ $(echo "$z" | grep -E 'png|gif|jpg|jpeg') && $(sudo file --mime-type "$i/$z" | grep -E 'image/(png|gif|jpeg)') ]]; then
        # Registrar el archivo en el log y eliminarlo
        echo "$(sudo stat $i/$z --format=%U);$i;$(date +%D);$z" >> descartados.log
        sudo rm $i/$z
      # Verificar si el archivo tiene una extensión de imagen pero NO es una imagen válida
      elif [[ $(echo "$z" | grep -E 'png|gif|jpg|jpeg') ]] && ! [[ $(sudo file --mime-type "$i/$z" | grep -E 'image/(png|gif|jpeg)') ]]; then
        # Registrar el archivo en el log y eliminarlo
        echo "$(sudo stat $i/$z --format=%U);$i;$(date +%D);$z" >> descartados.log
        sudo rm $i/$z
      # Verificar si el archivo es una imagen válida pero NO tiene la extensión correcta
      elif [[ $(sudo file --mime-type "$i/$z" | grep -E 'image/(png|gif|jpeg)') ]] && ! [[ $(echo "$z" | grep -E '\.(png|gif|jpg|jpeg)$') ]]; then
        # Obtener la extensión correcta del tipo MIME
        extension=$(sudo file --mime-type "$i/$z" | grep -E 'image/(png|gif|jpeg)' | awk -F '/' '{print $2}')
        # Cambiar la extensión del archivo
        nuevaext=$(echo "$z" | awk -F "." '{print $1 "." "'"$extension"'"}')
        sudo mv "$i/$z" "$i/$nuevaext"
      else
        # Si no cumple ninguna condición anterior, hacer algo (en este caso, imprimir "h")
        echo "h"
      fi
    done
   done 

else 
  # Si alguno de los directorios no existe, mostrar un mensaje de error
  echo "Alguno de los directorios no existen. Revise."
fi
