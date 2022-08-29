#!/bin/bash

if [ -n "$1" ]
then
    arquivo_memoria="$1.txt"
else
    echo "
          Informe um nome para o arquivo:
          $0 nome_do_arquivo
          " >&2
    exit 1
fi

zeros="$(for i in {1..256}
do
    echo 0 
done)"

echo "$zeros" > "$arquivo_memoria"
echo "$arquivo_memoria"
