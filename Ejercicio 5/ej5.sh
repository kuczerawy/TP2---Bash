#!/bin/bash

#export PATH_ENTRADA="/home/santi/Documents/TP2-20180519T214819Z-001/TP2/Ejercicio 5/entrada"
#export PATH_SALIDA="/home/santi/Documents/TP2-20180519T214819Z-001/TP2/Ejercicio 5/salida"

mostrar_ayuda() {
    echo './ej5.sh <archivo>'
    echo 'Donde:'
    echo '<archivo> -> es el archivo de log donde se registrarán los eventos.'
    echo 'Ejemplo: ./ej5.sh log.txt'
    exit
}

error_gen() {
    echo $1 >&2
    echo "Utilice la opción -h para ver como se utiliza este comando." >&2 
    exit
}

dir=
while [ $# -ne 0 ]; do
    case $1 in
        -h|-\?|-help)
            mostrar_ayuda
        ;;
        -?*)
            error_gen "Este script no acepta ningún parámetro opcional!" >&2
        ;;
        *)
            if [ -z $dir ]; then
                dir="$1"
            else
                error_gen "Parámetros incorrectos."
            fi
    esac 
    shift
done

if [ -z $dir ]; then
    error_gen "No se envió ninguna dirección donde generar el archivo log."
fi

touch $dir
path=$(readlink -f $dir)

listen() {
    echo "El PID del proceso es $$"

    zipear() {
        # muevo a la carpeta de entrada para operar
        cd "$PATH_ENTRADA"
        # nombre del archivo
        base=$(basename "$PATH_ENTRADA")
        fecha=$(date '+%d-%m-%Y %H:%M:%S')
        nombre="$base ($fecha).zip"
        # cuento archivos
        cont=$(ls -R -1q | awk '
        $0 && !/^[.]/ {
            print $0
        }
        ' | wc -l)
        # zipeo
        zip -r "$nombre" * > /dev/null
        # calculo el tamaño
        size=$(wc -c < "$nombre")
        tam=$(bc -l <<< "scale=6; $size/1000000")
        # muevo el archivo
        mv "$nombre" "$PATH_SALIDA"
        # imprimo en log
        echo "$fecha | Comprimidos $cont archivos en $nombre. Tamaño del .zip: $tam megabytes." >> "$path"
    }

    borrar() {
        # muevo a la carpeta de entrada para operar
        cd "$PATH_SALIDA"
        # obtengo fecha
        fechaf=$(date '+%d-%m-%Y %H:%M:%S')
        # cuento archivos
        contf=$(ls -R -1q | awk '
        $0 && !/^[.]/ {
            print $0
        }
        ' | wc -l)
        # obtengo tamaño de la carpeta
        sizef=$(du -b "$PATH_SALIDA" | awk '
        $1 {
            print $1
        }
        ')
        sizef=$((sizef-4096))
        tamf=$(bc -l <<< "scale=6; $sizef/1000000")
        # elimino archivos
        rm -r "$PATH_SALIDA"/*
        # imprimo en log
        echo "$fechaf | Eliminados $contf archivos. Espacio liberado: $tamf megabytes." >> "$path"
    }

    trap "zipear" SIGUSR1
    trap "borrar" SIGUSR2
    while true; 
        do sleep 1
    done
}

listen &
