class Grid {
    private int numRows;
    private int numCols;

    private int[] colOffset;
    private int[] rowOffset;
    private int rowHeight;

    private int x, y, w;

    private String[][] strings;

    Grid(int _numRows, int _numCols, int _rowHeight) {
        numRows = _numRows;
        numCols = _numCols;
        rowHeight = _rowHeight;

        colOffset = new int[numCols];
        rowOffset = new int[numRows];

        strings = new String[numRows][numCols];
    }

    public void draw() {
        pushStyle();
        textAlign(LEFT);

        final int pad = 5;
        final float colFraction = 1.f / numCols;

        for (int i = 0; i < numCols; i++) {
            colOffset[i] = round(w * colFraction * i);
        }

        for (int i = 0; i < numRows; i++) {
            rowOffset[i] = rowHeight * (i + 1);
        }

        
        stroke(0);

        // draw row lines
        for (int i = 0; i < numRows - 1; i++) {
            line(x, y + rowOffset[i], x + w, y + rowOffset[i]);
        }

        // draw column lines
        for (int i = 1; i < numCols; i++) {
            line(x + colOffset[i], y, x + colOffset[i], y + rowOffset[numRows - 1]);
        }

        // draw cell strings
        for (int row = 0; row < numRows; row++) {
            for (int col = 0; col < numCols; col++) {
                if (strings[row][col] != null) {
                    text(strings[row][col], x + colOffset[col] + pad, y + rowOffset[row] - pad);
                }
            }
        }
        
        popStyle();
    }

    public void setDim(int _x, int _y, int _w) {
        x = _x;
        y = _y;
        w = _w;
    }

    public void setString(String s, int row, int col) {
        strings[row][col] = s;
    }
}