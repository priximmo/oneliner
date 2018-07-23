awk -FS ";" '{CUMUL += $3} END {print CUMUL}' fichier.txt
