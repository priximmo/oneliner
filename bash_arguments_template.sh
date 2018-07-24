#!/bin/bash


affichage_aide() {
cat << EOF
Usage: ${0##*/} [-hv] [-f OUTFILE] [FILE]...

Affiche le fichier dans l'output

    -h          affichage de l'aide
    -f OUTFILE  récupération du fichier
    -v          mode verbeux
EOF
}

output_file=""
verbose=0

OPTIND=1

while getopts hvf: opt; do
    case $opt in
        h)
            affichage_aide
            exit 0
            ;;
        v)  verbose=$((verbose+1))
            ;;
        f)  output_file=$OPTARG
            ;;
        *)
            affichage_aide >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

printf 'verbose=<%d>\noutput_file=<%s>\nLeftovers:\n' "$verbose" "$output_file"
printf '<%s>\n' "$@"

