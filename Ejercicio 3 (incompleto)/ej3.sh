#!/bin/bash

archA=$(cat $1)
archB=$(cat $2)
palabras=$(echo $archB | tr ";" "\n")
sensitive=false

shift 2
while getopts ":i" opt; do
    case $opt in
        i)
            sensitive=true
        ;;
        \?)
            echo "Opción no válida: -$OPTARG" >&2
            exit
        ;;
    esac
done

contPalabrasB=0
for palabra in $palabras; do
    ((contPalabrasB++))
done
contNoEnA=$contPalabrasB

while read -r linea; do
    cont=0
    for palabra in $palabras; do
        if $sensitive; then
            palabra=$(echo $palabra | tr [:upper:] [:lower:])
        fi
        if [ $palabra = $linea ]; then
            ((cont++))
            ((contNoEnA--))
        fi
    done
    echo "$linea: $cont"
done <<< "$archA"

echo "No existen en A: $contNoEnA"