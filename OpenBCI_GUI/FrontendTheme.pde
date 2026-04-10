/////////////////////////////////////////////////////////////
//  Frontend Variables that used to be in OpenBCI_GUI.pde  //
/////////////////////////////////////////////////////////////
PImage openbciLogoCog;
Gif loadingGIF;
Gif loadingGIF_blue;
public Gif checkingImpedanceStatusGif;

PImage logo_black;
PImage logo_blue;
PImage logo_white;
PImage consoleImgBlue;
PImage consoleImgWhite;
PImage screenshotImgWhite;
PImage checkMark_20x20;

PFont f1;
PFont f2;
PFont f3;
PFont f4;
PFont f5;

PFont h1; //large Montserrat
PFont h2; //large/medium Montserrat
PFont h3; //medium Montserrat
PFont h4; //small/medium Montserrat
PFont h5; //small Montserrat

PFont p0; //large bold Open Sans
PFont p1; //large Open Sans
PFont p2; //large/medium Open Sans
PFont p3; //medium Open Sans
PFont p15;
static PFont p4; //medium/small Open Sans
PFont p13;
static PFont p5; //small Open Sans
PFont p6; //small Open Sans
PFont p_8;
PFont p_6;
PFont p_5;

// Never use Black!!! Use OPENBCI_DARKBLUE instead
final color WHITE = color(255);
final color OPENBCI_DARKBLUE = color(1, 18, 41);
final color OPENBCI_BLUE = color(31, 69, 110);
final color OPENBCI_BLUE_ALPHA50 = color(31, 69, 110, 50);
final color OPENBCI_BLUE_ALPHA100 = color(31, 69, 110, 100);
final color boxColor = color(200);
final color boxStrokeColor = OPENBCI_DARKBLUE;
final color isSelected_color = color(184, 220, 105); //Used for textfield borders,
final color colorNotPressed = WHITE;
final color buttonsLightBlue = color(57,128,204);
final color GREY_235 = color(235);
final color GREY_200 = color(200);
final color GREY_125 = color(125);
final color GREY_100 = color(100);
final color GREY_20 = color(20);
final color TURN_ON_GREEN = color(195, 242, 181);
final color TURN_OFF_RED = color(255, 210, 210);
final color BOLD_RED = color(224, 56, 45);
final color BUTTON_HOVER = color(177, 184, 193);//color(252, 221, 198);
final color BUTTON_HOVER_LIGHT = color(211, 222, 232);
final color BUTTON_PRESSED = color(150, 170, 200); //OPENBCI_DARKBLUE;
final color BUTTON_PRESSED_LIGHT = color(179, 187, 199);
final color BUTTON_LOCKED_GREY = color(128);
final color BUTTON_PRESSED_DARKGREY = color(50);
final color BUTTON_NOOBGREEN = color(114,204,171);
final color BUTTON_EXPERTPURPLE = color(135,95,154);
final color BUTTON_CAUTIONRED = color(214,100,100);
final color OBJECT_BORDER_GREY = color(150);
final color TOPNAV_DARKBLUE = OPENBCI_BLUE;
final color SUBNAV_LIGHTBLUE = buttonsLightBlue;
//Use the same colors for X,Y,Z throughout Accelerometer widget
final color ACCEL_X_COLOR = BOLD_RED;
final color ACCEL_Y_COLOR = color(49, 113, 89);
final color ACCEL_Z_COLOR = color(54, 87, 158);
//Signal check colors
final color SIGNAL_CHECK_YELLOW = color(221, 178, 13); //Same color as yellow channel color found below
final color SIGNAL_CHECK_YELLOW_LOWALPHA = color(221, 178, 13, 150);
final color SIGNAL_CHECK_RED = BOLD_RED;
final color SIGNAL_CHECK_RED_LOWALPHA = color(224, 56, 45, 150);
public CColor dropdownColorsGlobal = new CColor();

//Channel Colors -- Defaulted to matching the OpenBCI electrode ribbon cable
final color[] CHANNEL_COLORS = {
    color(129, 129, 129),
    color(124, 75, 141),
    color(54, 87, 158),
    color(49, 113, 89),
    SIGNAL_CHECK_YELLOW,
    color(253, 94, 52),
    BOLD_RED,
    color(162, 82, 49)
};

public enum ColorScheme implements IndexingInterface {
    LEGACY(0, "Legacy"),
    LIGHT(1, "Light"),
    DARK(2, "Dark");

    private int index;
    private String label;

    ColorScheme(int index, String label) {
        this.index = index;
        this.label = label;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }
}

class FrontendTheme {
    private final color BLUE_0 = #030A12;
    private final color BLUE_1 = #011326;
    private final color BLUE_2 = #102337;
    private final color BLUE_3 = #1F456E;
    private final color BLUE_4 = #00A3DD;
    private final color ORANGE_0 = #9F531A;
    private final color ORANGE_1 = #E37625;
    private final color ORANGE_2 = #F98025;
    private final color ORANGE_3 = #FF9444;
    private final color GREY_0 = #4C5662;
    private final color GREY_1 = #78838C;
    private final color GREY_2 = #C1C8CD;
    private final color WHITE_0 = #E3E6E8;
    private final color WHITE_1 = #FFFFFF;

    private ColorScheme colorScheme;
    private WidgetTheme widgetTheme;

    public FrontendTheme(ColorScheme colorScheme) {
        this.colorScheme = colorScheme;
        widgetTheme = new WidgetTheme(colorScheme);
    }

    public ColorScheme getColorScheme() {
        return colorScheme;
    }

    public void setColorScheme(ColorScheme colorScheme) {
        this.colorScheme = colorScheme;
        applyTheme();
    }

    public boolean isDarkMode() {
        return colorScheme == ColorScheme.DARK;
    }

    public boolean isLightMode() {
        // COLOR_SCHEME_DEFAULT
        return colorScheme == ColorScheme.LIGHT;
    }

    public boolean isLegacyMode() {
        // COLOR_SCHEME_ALTERNATIVE_A
        return colorScheme == ColorScheme.LEGACY;
    }

    public void iterateColorScheme() {
        int currentIndex = colorScheme.getIndex();
        int nextIndex = (currentIndex + 1) % ColorScheme.values().length;
        setColorScheme(ColorScheme.values()[nextIndex]);
        applyTheme();
        output("Color scheme changed to: " + colorScheme.getString());
    }

    public void applyTheme() {
        widgetTheme.setTheme(colorScheme);
        topNav.updateNavButtonsBasedOnColorScheme();
    }

    public WidgetTheme getWidgetTheme() {
        return widgetTheme;
    }

    private class WidgetTheme {
        private color backgroundColor;
        private color textColor;
        private color borderColor;
        private color buttonColor;
        private color buttonHoverColor;
        private color buttonPressedColor;

        public WidgetTheme(ColorScheme colorScheme) {
            setTheme(colorScheme);
        }

        public void setTheme(ColorScheme colorScheme) {
            switch (colorScheme) {
                case LIGHT:
                    backgroundColor = WHITE_0;
                    textColor = GREY_1;
                    borderColor = GREY_2;
                    buttonColor = BLUE_4;
                    buttonHoverColor = ORANGE_3;
                    buttonPressedColor = ORANGE_2;
                    break;
                case DARK:
                    backgroundColor = BLUE_0;
                    textColor = WHITE_1;
                    borderColor = GREY_0;
                    buttonColor = BLUE_4;
                    buttonHoverColor = ORANGE_3;
                    buttonPressedColor = ORANGE_2;
                    break;
                case LEGACY:
                default:
                    backgroundColor = WHITE_0;
                    textColor = GREY_1;
                    borderColor = GREY_2;
                    buttonColor = BLUE_4;
                    buttonHoverColor = ORANGE_3;
                    buttonPressedColor = ORANGE_2;
            }
            /*
            switch (colorScheme) {
                case LIGHT:
                    backgroundColor = WHITE_0;
                    textColor = BLACK;
                    borderColor = GREY_1;
                    buttonColor = BLUE_4;
                    buttonHoverColor = BLUE_3;
                    buttonPressedColor = BLUE_2;
                    break;
                case DARK:
                    backgroundColor = BLUE_0;
                    textColor = WHITE_1;
                    borderColor = GREY_1;
                    buttonColor = ORANGE_3;
                    buttonHoverColor = ORANGE_2;
                    buttonPressedColor = ORANGE_1;
                    break;
                case LEGACY:
                default:
                    backgroundColor = WHITE_0;
                    textColor = BLACK;
                    borderColor = GREY_1;
                    buttonColor = BLUE_4;
                    buttonHoverColor = BLUE_3;
                    buttonPressedColor = BLUE_2;
            }
            */
        }

        public void apply() {
            // Apply the theme to the widget
            fill(backgroundColor);
            stroke(borderColor);
            // Other drawing code...
        }

        public color getBackgroundColor() {
            return backgroundColor;
        }

        public color getTextColor() {
            return textColor;
        }

        public color getBorderColor() {
            return borderColor;
        }

        public color getButtonColor() {
            return buttonColor;
        }

        public color getButtonHoverColor() {
            return buttonHoverColor;
        }

        public color getButtonPressedColor() {
            return buttonPressedColor;
        }
    }
}