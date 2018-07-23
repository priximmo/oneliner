
python -c "import csv,json;
print json.dumps(list(csv.reader(open('fichier.csv'))))"
