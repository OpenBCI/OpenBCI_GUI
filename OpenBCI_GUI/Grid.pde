
class Grid {
    private int numRows;
    private int numCols;

    private int[] colOffset;
    private int[] rowOffset;
    private int rowHeight;
    private boolean horizontallyCenterTextInCells = false;
    private boolean drawTableBorder = false;
    private boolean drawTableInnerLines = true;

    private int x, y, w;
    private int pad_horiz = 5;
    private int pad_vert = 5;

    private PFont tableFont = p5;
    private int tableFontSize = 12;

    private color[][] textColors;

    private String[][] strings;

    Grid(int _numRows, int _numCols, int _rowHeight) {
        numRows = _numRows;
        numCols = _numCols;
        rowHeight = _rowHeight;

        colOffset = new int[numCols];
        rowOffset = new int[numRows];

        strings = new String[numRows][numCols];
        textColors = new color[numRows][numCols];

        color defaultTextColor = OPENBCI_DARKBLUE;
        for (color[] row: textColors) {
            Arrays.fill(row, defaultTextColor);
        }
    }

    public void draw() {
        pushStyle();
        textAlign(LEFT);        
        stroke(OPENBCI_DARKBLUE);
        textFont(p5, 12);

        if (drawTableInnerLines) {
            // draw row lines
            for (int i = 0; i < numRows - 1; i++) {
                line(x, y + rowOffset[i], x + w, y + rowOffset[i]);
            }

            // draw column lines
            for (int i = 1; i < numCols; i++) {
                line(x + colOffset[i], y, x + colOffset[i], y + rowOffset[numRows - 1]);
            }
        }

        // draw cell strings
        for (int row = 0; row < numRows; row++) {
            for (int col = 0; col < numCols; col++) {
                if (strings[row][col] != null) {
                    fill(textColors[row][col]);
                    textAlign(horizontallyCenterTextInCells ? CENTER : LEFT);
                    text(strings[row][col], x + colOffset[col] + pad_horiz, y + rowOffset[row] - pad_vert);
                }
            }
        }

        if (drawTableBorder) {
            noFill();
            stroke(OPENBCI_DARKBLUE);
            rect(x, y, w, rowOffset[numRows - 1]);
        }
        
        popStyle();
    }

    public RectDimensions getCellDims(int row, int col) {
        RectDimensions result = new RectDimensions();
        result.x = x + colOffset[col] + 1; // +1 accounts for line thickness
        result.y = y + rowOffset[row] - rowHeight;
        result.w = w / numCols - 1; // -1 account for line thickness
        result.h = rowHeight;

        return result;
    }

    public void setDim(int _x, int _y, int _w) {
        x = _x;
        y = _y;
        w = _w;
        
        final float colFraction = 1.f / numCols;

        for (int i = 0; i < numCols; i++) {
            colOffset[i] = round(w * colFraction * i);
        }

        for (int i = 0; i < numRows; i++) {
            rowOffset[i] = rowHeight * (i + 1);
        }
    }

    public void setString(String s, int row, int col) {
        strings[row][col] = s;
    }

    public void setTableFontAndSize(PFont _font, int _fontSize) {
        tableFont = _font;
        tableFontSize = _fontSize;
    }

    public void setRowHeight(int _height) {
        rowHeight = _height;
    }
    
    //This overrides the rowHeight and rowOffset when setting the total height of the Grid.
    public void setTableHeight(int _height) {
        rowHeight = _height / numRows;
        for (int i = 0; i < numRows; i++) {
            rowOffset[i] = rowHeight * (i + 1);
        }
    }

    public void setTextColor(color c, int row, int col) {
        textColors[row][col] = c;
    }

    //Change vertical padding for all cells based on the string/text height from a given cell
    public void dynamicallySetTextVerticalPadding(int row, int col) {
        float _textH = getFontStringHeight(tableFont, strings[row][col]);
        pad_vert =  int( (rowHeight - _textH) / 2); //Force round down here
    }

    public void setHorizontalCenterTextInCells(boolean b) {
        horizontallyCenterTextInCells = b;
        pad_horiz = b ? getCellDims(0,0).w/2 : 5;
    }

    public void setDrawTableBorder(boolean b) {
        drawTableBorder = b;
    }

    public void setDrawTableInnerLines(boolean b) {
        drawTableInnerLines = b;
    }
}