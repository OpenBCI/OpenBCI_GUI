
import os
import csv


def split(filehandler, delimiter=',', row_limit=4000000,
          output_name_template='output_%s.csv', output_path='.', keep_headers=True):
    
    reader = csv.reader(filehandler, delimiter=delimiter)
    current_piece = 1
    current_out_path = os.path.join(
        output_path,
        output_name_template % current_piece
    )
    current_out_writer = csv.writer(open(current_out_path, 'w', newline=''), delimiter=delimiter)
    current_limit = row_limit
    headers = []
    if keep_headers:
        for i in range (5):
            headerRow = next(reader);
            headers.append(headerRow)
            current_out_writer.writerow(headerRow)

    for i, row in enumerate(reader):
        if i + 1 > current_limit:
            current_piece += 1
            current_limit = row_limit * current_piece
            current_out_path = os.path.join(
                output_path,
                output_name_template % current_piece
            )
            current_out_writer = csv.writer(open(current_out_path, 'w', newline=''), delimiter=delimiter)
            if keep_headers:
                for headerRowI in headers:
                    current_out_writer.writerow(headerRowI)
                    print (headerRowI) 
            print (i)    
        current_out_writer.writerow(row)

split(open('OpenBCI-RAW-2021-04-05_21-49-12.txt', 'r'));