import csv
import sys

reader = csv.reader(iter(sys.stdin.readline, ''), delimiter=',', quoting=csv.QUOTE_ALL)

writer = csv.writer(sys.stdout, delimiter='\t', quoting=csv.QUOTE_MINIMAL)
for row in reader:
    # skip all header and footer lines
    if len(row) > 1 and row[0] != 'GregorianDate':
        writer.writerow(row)
