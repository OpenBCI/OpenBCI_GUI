

///////////////////////////////////////////////////////////////
//
// Class: Table_CSV
// Purpose: Extend the Table class to handle data files with comment lines
// Created: Chip Audette  May 2, 2014
//
// Usage: Only invoke this object when you want to read in a data
//    file in CSV format.  Read it in at the time of creation via
//
//    String fname = "myfile.csv";
//    TableCSV myTable = new TableCSV(fname);
//
///////////////////////////////////////////////////////////////

class Table_CSV extends Table {
    private int sampleRate;
    public int getSampleRate() { return sampleRate; }
    Table_CSV(String fname) throws IOException {
        init();
        readCSV(PApplet.createReader(createInput(fname)));
    }

    //this function is nearly completely copied from parseBasic from Table.java
    void readCSV(BufferedReader reader) throws IOException {
        boolean header=false;  //added by Chip, May 2, 2014;
        boolean tsv = false;  //added by Chip, May 2, 2014;

        String line = null;
        int row = 0;
        if (rowCount == 0) {
            setRowCount(10);
        }
        //int prev = 0;  //-1;
        try {
            while ( (line = reader.readLine ()) != null) {
                //added by Chip, May 2, 2014 to ignore lines that are comments
                if (line.charAt(0) == '%') {
                    if (line.length() > 18) {
                        if (line.charAt(1) == 'S') {
                            sampleRate = Integer.parseInt(line.substring(15, 18));
                            if (sampleRate == 100 || sampleRate == 160) {
                                sampleRate = Integer.parseInt(line.substring(15, 19));
                            }
                            println("Sample rate set to " + sampleRate);
                        }
                    }
                    println("readCSV: " + line);
                    continue;
                }

                if (row == getRowCount()) {
                    setRowCount(row << 1);
                }
                if (row == 0 && header) {
                    setColumnTitles(tsv ? PApplet.split(line, '\t') : split(line,','));
                    header = false;
                }
                else {
                    setRow(row, tsv ? PApplet.split(line, '\t') : split(line,','));
                    row++;
                }

                // this is problematic unless we're going to calculate rowCount first
                if (row % 10000 == 0) {
                    try {
                        // Sleep this thread so that the GC can catch up
                        Thread.sleep(10);
                    }
                    catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Error reading table on line " + row, e);
        }
        // shorten or lengthen based on what's left
        if (row != getRowCount()) {
            setRowCount(row);
        }
    }
}