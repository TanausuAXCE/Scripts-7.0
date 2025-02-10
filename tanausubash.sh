#!/bin/bash

op=1  # Variable para controlar el bucle del menú

# Función para analizar archivos en un directorio según extensiones
analizar() {
    # Verificar que se haya proporcionado al menos un parámetro (el directorio)
    if [ $# -lt 1 ]; then
        echo "Error: Debes proporcionar al menos un directorio y una extensión."
        echo "Uso: $0 <directorio> <ext1> <ext2> ... <extN>"
        exit 1
    fi

    # Asignar el directorio y las extensiones
    directorio=$1
    shift
    extensiones=("$@")

    # Verificar que el directorio existe
    if [ ! -d "$directorio" ]; then
        echo "Error: El directorio '$directorio' no existe."
        exit 1
    fi

    # Verificar que se hayan proporcionado extensiones
    if [ ${#extensiones[@]} -eq 0 ]; then
        echo "Error: Debes proporcionar al menos una extensión."
        exit 1
    fi

    # Inicializar un array asociativo para contar archivos por extensión
    declare -A contador

    # Inicializar el contador para cada extensión
    for ext in "${extensiones[@]}"; do
        contador["$ext"]=0
    done

    # Buscar archivos en el directorio y subdirectorios
    while IFS= read -r -d '' archivo; do
        # Obtener la extensión del archivo
        ext="${archivo##*.}"
        # Convertir la extensión a minúsculas para evitar distinciones entre mayúsculas y minúsculas
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        # Incrementar el contador si la extensión está en la lista
        if [[ " ${extensiones[@],,} " =~ " ${ext} " ]]; then
            contador["$ext"]=$((contador["$ext"] + 1))
        fi
    done < <(find "$directorio" -type f -print0)

    # Mostrar el informe
    echo "Informe de análisis para el directorio: $directorio"
    echo "---------------------------------------------"
    for ext in "${extensiones[@]}"; do
        echo "Número de archivos .$ext: ${contador["$ext"]}"
    done
    echo "---------------------------------------------"
}

# Función para dibujar líneas con un carácter específico
lineas() {
    # Verificar que se hayan pasado exactamente 3 parámetros
    if [ $# -ne 3 ]; then
        echo "Error: Debes proporcionar exactamente 3 parámetros."
        echo "Uso: $0 <carácter> <longitud (1-60)> <líneas (1-10)>"
        exit 1
    fi

    # Asignar parámetros a variables
    caracter=$1
    longitud=$2
    lineas=$3

    # Validar que el segundo parámetro sea un número entre 1 y 60
    if [[ ! $longitud =~ ^[0-9]+$ ]] || ((longitud < 1 || longitud > 60)); then
        echo "Error: El segundo parámetro debe ser un número entre 1 y 60."
        exit 1
    fi

    # Validar que el tercer parámetro sea un número entre 1 y 10
    if [[ ! $lineas =~ ^[0-9]+$ ]] || ((lineas < 1 || lineas > 10)); then
        echo "Error: El tercer parámetro debe ser un número entre 1 y 10."
        exit 1
    fi

    # Dibujar las líneas
    for ((i=1; i<=lineas; i++)); do
        # Crear una línea con el carácter repetido
        linea=$(printf "%${longitud}s" | tr ' ' "$caracter")
        echo "$linea"
    done
}

# Función para reemplazar espacios en nombres de archivos por guiones bajos
quita_blancos() {
    # Recorrer todos los archivos en el directorio actual
    for archivo in *; do
        # Verificar si el nombre del archivo contiene espacios
        if [[ "$archivo" =~ [[:space:]] ]]; then
            # Reemplazar espacios por guiones bajos
            nuevo_nombre=$(echo "$archivo" | tr ' ' '_')
            
            # Renombrar el archivo
            mv "$archivo" "$nuevo_nombre"
            
            # Mostrar el cambio realizado
            echo "Renombrado: '$archivo' -> '$nuevo_nombre'"
        fi
    done
}

# Función para calcular estadísticas de notas de alumnos
alumnos() {
    # Pedir el número de alumnos
    read -p "Introduce el número de alumnos: " num_alumnos

    # Inicializar variables
    aprobados=0
    suspensos=0
    suma_notas=0

    # Pedir la nota de cada alumno
    for ((i=1; i<=num_alumnos; i++)); do
        # Pedir la nota hasta que sea válida
        nota=""
        while [[ ! $nota =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$nota < 0 || $nota > 10" | bc -l) )); do
            read -p "Introduce la nota del alumno $i (0-10): " nota
            if [[ ! $nota =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$nota < 0 || $nota > 10" | bc -l) )); then
                echo "Nota no válida. Debe ser un número entre 0 y 10."
            fi
        done

        # Contar aprobados y suspensos
        if (( $(echo "$nota >= 5" | bc -l) )); then
            aprobados=$((aprobados + 1))
        else
            suspensos=$((suspensos + 1))
        fi

        # Sumar la nota para calcular la media
        suma_notas=$(echo "$suma_notas + $nota" | bc -l)
    done

    # Calcular la nota media
    nota_media=$(echo "scale=2; $suma_notas / $num_alumnos" | bc -l)

    # Mostrar resultados
    echo "Número de aprobados: $aprobados"
    echo "Número de suspensos: $suspensos"
    echo "Nota media de la clase: $nota_media"
}

# Función para realizar una copia de seguridad de un usuario
contusu() {
    # Crear el directorio de copias de seguridad si no existe
    mkdir -p /home/copiaseguridad

    # Mostrar el número de usuarios
    echo "Número de usuarios con directorio en /home: $(echo "$(ls /home)" | wc -l)"

    # Mostrar la lista de usuarios
    echo "Lista de usuarios:"
    select usuario in $(ls /home); do
        if [ -n "$usuario" ]; then
            echo "Has seleccionado al usuario: $usuario"
            break
        else
            echo "Opción no válida. Inténtalo de nuevo."
        fi
    done

    # Crear el nombre del archivo de copia de seguridad
    backup_file="/home/copiaseguridad/${usuario}_$(date +%Y%m%d).tar.gz"

    # Realizar la copia de seguridad usando tar
    echo "Realizando copia de seguridad del directorio /home/$usuario en $backup_file..."
    tar -czf "$backup_file" -C /home "$usuario"

    # Verificar si la copia de seguridad fue exitosa
    if [ $? -eq 0 ]; then
        echo "Copia de seguridad completada con éxito en $backup_file."
    else
        echo "Hubo un error al realizar la copia de seguridad."
    fi 
}

# Función para reescribir vocales en una cadena
reescribir() {
    echo $1 | sed 'y/[aeiou]/12345/'
}

# Función para crear archivos con nombres numerados
crear_2() {
    local nombre_archivo="${1:-fichero_vacio.txt}"  # Nombre base con valor por defecto
    local tamano="${2:-1024}KB"                    # Tamaño con valor por defecto
    local max_intentos=9                           # Máximo de numeraciones a intentar

    # Función para encontrar el primer número disponible
    encontrar_numero() {
        # Busca archivos numerados y extrae los números
        find . -maxdepth 1 -name "${nombre_archivo}[0-9]" 2>/dev/null |
        awk -F"${nombre_archivo}" '{print $2}' |          # Extrae la parte numérica
        sort -n |                                         # Ordena numéricamente
        awk -v max="$max_intentos" '
            NR == 1 && $1 > 1 {print 1; exit}            # Si el primer número es mayor que 1
            $1 != NR {print NR; exit}                    # Encuentra el primer hueco
            END {if (NR == max) print ""}                # Si todos los números están ocupados
        '
    }

    # Primera versión sin número
    if ! [ -e "$nombre_archivo" ]; then
        sudo touch "$nombre_archivo"
        sudo truncate -s "$tamano" "$nombre_archivo"
        echo "Archivo creado: $nombre_archivo"
        return 0
    fi

    echo "El archivo $nombre_archivo ya existe. Buscando alternativa..."

    # Buscar números disponibles
    numero=$(encontrar_numero)

    if [ -n "$numero" ] && [ "$numero" -le $max_intentos ]; then
        local nuevo_nombre="${nombre_archivo}${numero}"
        sudo touch "$nuevo_nombre"
        sudo truncate -s "$tamano" "$nuevo_nombre"
        echo "Archivo creado: $nuevo_nombre"
    else
        echo "Error: No se pudo crear. Existen desde ${nombre_archivo}1 hasta ${nombre_archivo}${max_intentos}"
        return 1
    fi
}

# Función para crear un archivo con un nombre y tamaño específicos
crear() {
    local fich="$1"
    local tamn="$2"

    sudo touch ${1:-fichero_vacio.txt}
    sudo truncate -s ${2:-1024}KB ${1:-fichero_vacio.txt}
}

# Función para automatizar la creación de usuarios y directorios
automatizar() {
    if [[ -n $(sudo ls /mnt/usuarios) ]]; then
        for i in $(sudo ls /mnt/usuarios); do
            sudo useradd -m -s /bin/bash $i
            for z in $(sudo cat /mnt/usuarios/$i); do
                sudo mkdir /home/$i/$z
            done
            sudo passwd $i
            sudo rm /mnt/usuarios/$i
        done
    else
        echo "El directorio está vacío o no existe"
    fi
}

# Función para convertir números a romanos
romanos() {
    local numero="$1"
    local romano=""
    if [ $numero -gt 200 ] || [ $numero -lt 1 ]; then
        echo "Introduce un número entre 1 y 200"
    else
        # Arrays de valores y símbolos romanos
        valores=(1000 900 500 400 100 90 50 40 10 9 5 4 1)
        simbolos=("M" "CM" "D" "CD" "C" "XC" "L" "XL" "X" "IX" "V" "IV" "I")

        for (( i=0; i<${#valores[@]}; i++ )); do
            while (( numero >= valores[i] )); do
                romano+="${simbolos[i]}"
                (( numero -= valores[i] ))
            done
        done

        echo "$romano"
    fi
}

# Función para mostrar los permisos de un archivo en octal
permisosoctal() {
    ruta=$(find / -name $1 2> /dev/null)
    echo "Los permisos del fichero en octal son: " $(stat --format=%a $ruta)
}

# Función para verificar privilegios de administrador
privilegios() {
    us=$(whoami)
    grupos=$(groups $us)
    
    if [[ $us == 'root' || $(groups $us | grep -o 'sudo|root') ]]; then
        echo "El usuario tiene privilegios de administrador"
    else
        echo "El usuario no tiene permisos de administrador"
    fi
}

# Función para contar archivos en un directorio
contar() {
    ruta=$(sudo find / -type d -name $1 2> /dev/null)
    echo "Número de ficheros de $1: " $(ls -l $ruta | grep -o '^-' | wc -l)
}

# Función para buscar un archivo y contar sus vocales
buscar() {
    read -p "Introduzca un nombre de fichero: " f
    ruta=$((sudo find / -type f -name $f) 2>/dev/null)

    if [[ -n $ruta ]]; then
        echo "$ruta"
        echo "El fichero $f contiene las siguientes vocales: " $(grep -o -i '[aeiou]' $ruta | wc -l)
    else
        echo "El fichero especificado no existe"
    fi
}

# Función para mostrar información de un fichero
fichero() {
    ruta=$((sudo find / -type f -name $1) 2>/dev/null | grep $1 -w)
    echo "Tipo de fichero: " $(stat $ruta --format=%F)
    echo "Tamaño en bytes: " $(stat $ruta --format=%s)
    echo "Inodo: " $(stat $ruta --format=%i)
    echo "Punto de montaje: " $(stat $ruta --format=%m)
}

# Función para clasificar la edad en etapas de la vida
edad() {
    if [ $1 -lt 3 ]; then
        echo "Niñez"
    elif [[ $1 -le 10 && $1 -ge 3 ]]; then
        echo "Infancia"
    elif [[ $1 -lt 18 && $1 -gt 10 ]]; then
        echo "Adolescencia"
    elif [[ $1 -lt 40 && $1 -ge 18 ]]; then
        echo "Juventud"
    elif [[ $1 -le 65 && $1 -ge 40 ]]; then
        echo "Madurez"
    else
        echo "Vejez"
    fi
}

# Función para adivinar un número aleatorio
adivina() {
    let 'cont = 1'
    ramn=$((1 + $RANDOM % 100))
    read -p "Introduzca un número: " num

    # Bucle para adivinar el número
    while [ $num != $ramn ]; do
        if [ $num -gt $ramn ]; then
            echo "El número introducido es mayor que el número generado"
            let 'cont = cont + 1'
            read -p "Introduzca un número: " num
        else
            echo "El número introducido es menor que el número generado"
            let 'cont = cont + 1'
            read -p "Introduzca un número: " num
        fi
    done

    echo "¡Exacto, el número es $ramn!, lo has conseguido en $cont intentos."
}

# Función para configurar la red
red() {
    if [ $elec == s ]; then
        if [ $(echo $1 | grep /) ]; then
            sudo cat << EOF > tmp.txt
network:
    renderer: networkd
    ethernets:
        $5:
            dhcp4: false
            addresses: 
                - $1
            nameservers: 
                addresses: [$3,$4]
            routes:
                - to: 0.0.0.0/0
                  via: $2      
EOF
            sudo cp tmp.txt /etc/netplan/50-cloud-init.yaml
            sudo netplan apply
        else
            echo "Introduzca la máscara junto a la ip ej = 192.168.1.13/24"
        fi
    elif [ $elec == D ]; then
        cat << EOF > tmp.txt
network:
    renderer: networkd
    ethernets:
        $1:
            dhcp4: true 
EOF
        sudo cp tmp.txt /etc/netplan/50-cloud-init.yaml
        sudo netplan apply
    else
        echo "La respuesta especificada no es correcta. Recuerde, s/D"
    fi
}

# Función para verificar si un año es bisiesto
bisiesto() {
    if [[ $year%4 -eq 0 && $year%100 -ne 0 ]]; then
        echo "El año $year es bisiesto"
    elif [[ $year%400 -eq 0 && $year%100 -eq 0 ]]; then
        echo "El año $year es bisiesto"
    else
        echo "El año $year no es bisiesto"
    fi
}

# Función para calcular el factorial de un número
factorial()
{
    product=$1
           
    # Bucle
    if((product <= 2)); then
        "echo $product"
    else
        f=$((product -1))
        
    # Llamada recursiva

        f=$(factorial $f)
        f=$((f*product))
        echo $f
    fi
}





while [ $op -ne 0 ]; 
 do
# Menu que se muestra por pantalla
   echo "RECOMIENDO EJECUTAR EL SCRIPT COMO ADMINISTRADOR YA QUE ALGUNAS FUNCIONES LO NECESITAN"
   echo -e "\nOpción 1: factortal"
   echo "Opción 2: bisiesto"
   echo "Opción 3: configurarred"
   echo "Opción 4: adivina"
   echo "Opción 5: edad"
   echo "Opción 6: fichero"
   echo "Opción 7: buscar"
   echo "Opción 8: contar"
   echo "Opción 9: privilegios"
   echo "Opción 10: permisosoctal"
   echo "Opción 11: romanos"
   echo "Opción 12: automatizar"
   echo "Opción 13: crear"
   echo "Opción 14: crear_2"
   echo "Opción 15: reescribir"
   echo "Opción 16: contusu"
   echo "Opción 17: alumnos"
   echo "Opción 18: quita_blancos"
   echo "Opción 19: lineas"
   echo "Opción 20: analizar"
   echo "Opción 0: Salir"
   read -p "Elegir la opcion deseada " op
   echo ""
   case $op in

    0)

    echo "Saliendo del menú..."

    ;;

    1)
     echo "Introduce un número: "   
     read num


     if((num == 0)); then   
      echo 1
     else

      factorial $num
    fi


    ;;

    2)
     read -p "Introduce un año: " year
     bisiesto $year
    ;;

    3)
    echo " "
       read -p "Quiere una configuración e(s)tática o (D)HCP: " elec

       read -p "Introduce la interfaz: " int

       if [ $elec == s ]; then

          read  -p "Introduce una ip y máscara(ej.182.90.1.4/16): " ip 

          read -p "Introduce la gateway: " gtw

          read -p "Introduce el primer DNS: " dns1

          read -p "Introduce el segundo DNS: " dns2

          red $ip $gtw $dns $dns2 $int

      elif [ $elec == D ]; then

         red $int

      else 

        echo "Introduce la opción correcta."
     fi
    ;;

 4)
  adivina
 ;;

 5)
   read -p "Introduce tu edad: " edad


   edad $edad
 ;;

 6)
  read -p "Introduzca un nombre de fichero: " f 

  fichero $f
 ;;

 7)
 buscar
 ;;

 8)
  contar
 ;;

 9)
   read -p "Introduzca un nombre de directorio: " d


   privilegios $d
 ;;

 10)
  read -p "Introduzca un nombre de fichero o directorio: " fchd

  permisosoctal $fchd

 ;;

 11)
   read -p "Introduce un número: " numero

   romanos $numero
 ;;

 12)
   automatizar
 ;;

 13)
  read -p "Introduce un nombre de fichero: " fic
  read -p "Introduce un tamaño para el fichero: " tam

  crear $fic $tam
 ;;

 14)
  read -p "Introduce un nombre de fichero: " fic
  read -p "Introduce un tamaño para el fichero: " tam

  crear_2 $fic $tam
 ;;

 15)
   read -p "Introduce una palabra: " str
   reescribir $str
 ;;

 16)
   contusu
 ;;

 17)
   
   alumnos

 ;;

 18)

    quita_blancos

 ;;

 19)
  read -p "Introduce un caracter: " carac
  read -p "Introduce un numero del 1 al 60: " nums1
  read -p "Introduce un número del 1 al 10: " nums2

  lineas $carac $nums1 $nums2

 ;;

 20)
  read -p "Introduce un árbol de directorios: " dire
  analizar $dire  

 ;;

 *)
  echo "El dato que le ha pasado al menú es incorrecto."
 ;;
  esac
 done
