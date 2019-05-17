# Escriba su código aquí
# primero, limpiar lineas vacias
for file in data*; do sed -e '/^$/d' "$file" > $(echo prueba-$file) ; done

# agregar nombre de archivo
for f in prueba*.csv; do sed s/^/"$f",/g $f > $(echo 2-$f); done
rm prueba*

# agregar numero de fila
for f in 2-*; do csvstack -l -H $f > $(echo 3-$f); done
rm 2-*

# agrupar archivos
csvstack 3-* > consolidado.csv
rm 3-*

# limpiar titulos, lineas vacias, nombre de archivos, tabuladores y espacios
sed -e 's/^line_number.*//g' -e '/^$/d' -e 's/prueba-//g' -e 's/[[:space:]]\+/,/g' consolidado.csv > consolidado2.csv

# limpiar principio de lineas
sed 's/^\([0-9]\+\),\([[:alnum:]]\+\.csv\),/\2,\1,/' consolidado2.csv > consolidado3.csv

# se va a crear una llave con las primeras tres columnas identificando con punto y coma los valores a separar
sed 's/,/;/3' consolidado3.csv > consolidado4.csv

# se realiza la primera separacion
sed 's/\(.*\);\(.*\),/\1;\2\n\1,/' consolidado4.csv > consolidado5.csv

# se corre la separacion mientras los archivos sean diferentes hasta no poder separar más
while [ $(cmp -s consolidado4.csv consolidado5.csv || echo T) ];
do
    sed 's/\(.*\);\(.*\),/\1;\2\n\1,/' consolidado5.csv > consolidado4.csv
    mv consolidado5.csv consolidado6.csv
    mv consolidado4.csv consolidado5.csv
    mv consolidado6.csv consolidado4.csv
done

# cambiar archivos preparatorios y borrar
mv consolidado5.csv final.csv
rm consol*

# limpiar archivo final e imprimir
sed 's/;/,/g' final.csv
rm final.csv