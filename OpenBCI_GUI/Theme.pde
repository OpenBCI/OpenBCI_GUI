/**
 * enum to store all possible themes
 */
public enum ThemeType {

    LIGHT("Light Theme", 0),
    DARK("Dark Theme", 1);

    static public final ThemeType[] values = values();

    private String name;
    private final int code;
    
    ThemeType(String name, int code) {
        this.name = name;
        this.code = code;
    }
   
    public String getName() {
        return name;
    }

    public int get_code() {
        return code;
    }

    public ThemeType prev() {
        return values[(ordinal() - 1  + values.length) % values.length];
    }

    public ThemeType next() {
        return values[(ordinal() + 1) % values.length];
    }
}

/**
 * theme interface
 */
public interface Theme {

    color getBoxColor();
    color getBoxStrokeColor();
    color getTextfieldBorderColor();
    color getSubNavColor();
    color getTurnOnButtonColor ();
    color getTurnOffButtonColor();
    color getButtonHoverColor();
    color getButtonPressedColor();
    color getTopNavColor();
    color getAccelXColor();
    color getAccelYColor();
    color getAccelZColor();
    color[] getChannelColors();
};

/**
 * light theme
 */
public class OpenBCILightTheme implements Theme {

    protected final color WHITE = color(255);
    protected final color BLACK = color(0);
    protected final color DARKBLUE = color(1, 18, 41);
    protected final color BLUE = color(31, 69, 110);
    protected final color LIGHT_BLUE = color(57,128,204);
    protected final color GREY_200 = color(200);
    protected final color GREY_175 = color(175);
    protected final color GREY_150 = color(125);
    protected final color GREY_125 = color(125);
    protected final color GREY_100 = color(100);
    protected final color GREY_75 = color(75);
    protected final color GREY_50 = color(50);
    protected final color GREY_25 = color(25);
    protected final color GREEN = color(195, 242, 181);
    protected final color RED = color(255, 210, 210);
    protected final color BOLD_RED = color(224, 56, 45);
    protected final color BOLD_GREEN = color(49, 113, 89);
    protected final color BOLD_BLUE = color(54, 87, 158);
    protected final color YELLOW = color(221, 178, 13);
    protected final color PURPLE = color(135,95,154);

    color getBoxColor() {
        return GREY_200;
    }
    
    color getBoxStrokeColor() {
        return DARKBLUE;
    }

    color getTextfieldBorderColor() {
        return color(184, 220, 105);
    }

    color getSubNavColor() {
        return LIGHT_BLUE;
    }

    color getTurnOnButtonColor() {
        return GREEN;
    }

    color getTurnOffButtonColor() {
        return RED;
    }

    color getButtonHoverColor() {
        return color(177, 184, 193);
    }

    color getButtonPressedColor() {
        return color(150, 170, 200);
    }

    color getTopNavColor() {
        return BLUE;
    }

    color getAccelXColor() {
        return BOLD_RED;
    }
    
    color getAccelYColor() {
        return BOLD_GREEN;
    }
    
    color getAccelZColor() {
        return BOLD_BLUE;
    }

    color[] getChannelColors() {
        color[] channelColors = {
            color(129, 129, 129),
            color(124, 75, 141),
            color(54, 87, 158),
            color(49, 113, 89),
            YELLOW,
            color(253, 94, 52),
            BOLD_RED,
            color(162, 82, 49)
        };
        return channelColors;
    }
}

// TODO[theme manager] its a placeholder for testing for now, need to create a new theme
/**
 * dark theme
 */
public class OpenBCIDarkTheme extends OpenBCILightTheme {

    color getTopNavColor() {
        return GREY_25;
    }

    color getSubnavColor() {
        return GREY_50;
    }
}
