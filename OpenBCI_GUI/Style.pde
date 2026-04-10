///////////////////////////////////////////////////////////////////////////////////////
//
//  Style.pde - Theme Manager for OpenBCI GUI
//  
//  Created for GUI v7 Dark Mode Feature (Issue #705)
//  Based on PR #1063 (Andrey1994) and PR #1248 (retiutut) architecture.
//  This class centralizes all color definitions and allows switching between themes.
//
//  Themes available:
//    - DEFAULT: Original OpenBCI blue theme (Legacy)
//    - LIGHT: Light/soft theme with reduced contrast
//    - DARK: Dark mode for accessibility (reduced eye strain)
//
///////////////////////////////////////////////////////////////////////////////////////

/**
 * Enum to store all possible themes.
 * Based on PR #1063 ThemeType pattern.
 */
public enum ThemeType implements IndexingInterface {
    DEFAULT(0, "Default"),
    LIGHT(1, "Light"),
    DARK(2, "Dark");

    private int index;
    private String label;

    ThemeType(int index, String label) {
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

    public ThemeType next() {
        ThemeType[] vals = values();
        return vals[(ordinal() + 1) % vals.length];
    }
}

// Global style instance - use this throughout the GUI
Style style;

/**
 * Style class manages all GUI colors based on the selected theme.
 * 
 * HOW TO USE:
 * Instead of using hardcoded colors like:
 *     fill(color(200));  // old way
 * 
 * Use the style methods:
 *     fill(style.getBoxColor());  // new way
 * 
 * This allows colors to change automatically when the theme changes.
 */
class Style {
    
    // Current active theme
    private ThemeType currentTheme;
    
    // ============================================================
    // COLOR DEFINITIONS FOR EACH THEME
    // ============================================================
    
    // --- DEFAULT Theme (Original OpenBCI Blue / Legacy) ---
    private final color DEFAULT_TOPNAV_BG = color(31, 69, 110);        // OPENBCI_BLUE
    private final color DEFAULT_SUBNAV_BG = color(57, 128, 204);       // buttonsLightBlue
    private final color DEFAULT_BOX_BG = color(200);                    // boxColor
    private final color DEFAULT_BOX_STROKE = color(1, 18, 41);         // OPENBCI_DARKBLUE
    private final color DEFAULT_WIDGET_BG = color(255);                 // WHITE
    private final color DEFAULT_TEXT_PRIMARY = color(1, 18, 41);       // OPENBCI_DARKBLUE
    private final color DEFAULT_TEXT_SECONDARY = color(100);            // GREY_100
    private final color DEFAULT_TEXT_ON_DARK = color(255);             // WHITE
    private final color DEFAULT_BUTTON_BG = color(57, 128, 204);       // buttonsLightBlue
    private final color DEFAULT_BUTTON_TEXT = color(255);              // WHITE
    private final color DEFAULT_BUTTON_HOVER = color(177, 184, 193);
    private final color DEFAULT_BUTTON_PRESSED = color(150, 170, 200);
    private final color DEFAULT_HELP_WIDGET_BG = color(31, 69, 110);   // OPENBCI_BLUE
    private final color DEFAULT_HELP_WIDGET_TEXT_BG = color(1, 18, 41);
    
    // --- LIGHT Theme (Soft/reduced contrast) ---
    private final color LIGHT_TOPNAV_BG = color(55, 95, 140);          // Softer OpenBCI blue
    private final color LIGHT_SUBNAV_BG = color(80, 145, 215);         // Lighter blue
    private final color LIGHT_BOX_BG = color(227, 230, 232);           // #E3E6E8 soft grey
    private final color LIGHT_BOX_STROKE = color(193, 200, 205);       // #C1C8CD light grey border
    private final color LIGHT_WIDGET_BG = color(240, 242, 245);        // Near-white with slight warmth
    private final color LIGHT_TEXT_PRIMARY = color(50, 60, 70);        // Dark grey (not harsh black)
    private final color LIGHT_TEXT_SECONDARY = color(120, 131, 140);   // #78838C muted grey
    private final color LIGHT_TEXT_ON_DARK = color(255);               // WHITE
    private final color LIGHT_BUTTON_BG = color(0, 163, 221);          // #00A3DD cyan-blue
    private final color LIGHT_BUTTON_TEXT = color(255);                // WHITE
    private final color LIGHT_BUTTON_HOVER = color(255, 148, 68);      // #FF9444 orange hover
    private final color LIGHT_BUTTON_PRESSED = color(249, 128, 37);    // #F98025 orange pressed
    private final color LIGHT_HELP_WIDGET_BG = color(55, 95, 140);     // Match topnav
    private final color LIGHT_HELP_WIDGET_TEXT_BG = color(30, 55, 85);
    
    // --- DARK Theme (Dark Mode - OpenBCI colors but darker, near black) ---
    private final color DARK_TOPNAV_BG = color(8, 18, 28);             // Very dark OpenBCI blue (near black)
    private final color DARK_SUBNAV_BG = color(12, 28, 45);            // Slightly lighter dark blue
    private final color DARK_BOX_BG = color(18, 35, 55);               // Dark blue-grey for boxes
    private final color DARK_BOX_STROKE = color(25, 50, 80);           // Subtle blue border
    private final color DARK_WIDGET_BG = color(10, 22, 35);            // Very dark blue widget background
    private final color DARK_TEXT_PRIMARY = color(200, 210, 220);      // Soft off-white text (not harsh)
    private final color DARK_TEXT_SECONDARY = color(140, 155, 170);    // Muted blue-grey text
    private final color DARK_TEXT_ON_DARK = color(200, 210, 220);      // Same as primary in dark
    private final color DARK_BUTTON_BG = color(20, 45, 75);            // Dark OpenBCI blue button
    private final color DARK_BUTTON_TEXT = color(200, 210, 220);       // Soft light text on buttons
    private final color DARK_BUTTON_HOVER = color(28, 58, 95);         // Slightly lighter on hover
    private final color DARK_BUTTON_PRESSED = color(15, 35, 60);       // Darker when pressed
    private final color DARK_HELP_WIDGET_BG = color(8, 18, 28);        // Match topnav
    private final color DARK_HELP_WIDGET_TEXT_BG = color(5, 12, 20);   // Near black
    
    // --- Dimmed accent colors for dark mode (reduced contrast) ---
    private final color DARK_SUCCESS = color(140, 190, 130);           // Dimmed green
    private final color DARK_ERROR = color(180, 70, 60);               // Dimmed red
    private final color DARK_WARNING = color(180, 145, 40);            // Dimmed yellow
    private final color DARK_ACCENT = color(45, 100, 160);             // Dimmed OpenBCI blue
    
    // ============================================================
    // CONSTRUCTOR
    // ============================================================
    
    Style() {
        this.currentTheme = ThemeType.DEFAULT;
    }
    
    Style(ThemeType theme) {
        this.currentTheme = theme;
    }
    
    // ============================================================
    // THEME SWITCHING
    // ============================================================
    
    /**
     * Set the current theme
     * @param theme ThemeType enum value
     */
    void setTheme(ThemeType theme) {
        this.currentTheme = theme;
        println("Style: Theme changed to " + getThemeName());
    }
    
    /**
     * Get the current ThemeType
     */
    ThemeType getThemeType() {
        return this.currentTheme;
    }
    
    /**
     * Get the current theme name as a string
     */
    String getThemeName() {
        return currentTheme.getString();
    }
    
    /**
     * Cycle to the next theme and persist the choice
     */
    void cycleTheme() {
        currentTheme = currentTheme.next();
        println("Style: Theme cycled to " + getThemeName());
        // Persist the theme choice
        if (guiSettings != null) {
            guiSettings.setThemeType(currentTheme);
        }
        notifyThemeChange();
    }
    
    /**
     * Notify all widgets that the theme has changed so they can update their colors
     */
    void notifyThemeChange() {
        // Update global dropdown colors
        updateDropdownColors();
        
        // Update all widget plot colors when theme changes
        if (widgetManager != null) {
            widgetManager.updateAllWidgetColors();
        }
    }
    
    /**
     * Update the global dropdown colors based on current theme
     */
    void updateDropdownColors() {
        switch(currentTheme) {
            case DARK:
                dropdownColorsGlobal.setActive((int)color(15, 35, 60));
                dropdownColorsGlobal.setForeground((int)color(25, 50, 80));
                dropdownColorsGlobal.setBackground((int)color(18, 35, 55));
                dropdownColorsGlobal.setCaptionLabel((int)color(200, 210, 220));
                dropdownColorsGlobal.setValueLabel((int)color(180, 190, 200));
                break;
            case LIGHT:
                dropdownColorsGlobal.setActive((int)LIGHT_BUTTON_PRESSED);
                dropdownColorsGlobal.setForeground((int)LIGHT_BUTTON_HOVER);
                dropdownColorsGlobal.setBackground((int)color(227, 230, 232));
                dropdownColorsGlobal.setCaptionLabel((int)color(50, 60, 70));
                dropdownColorsGlobal.setValueLabel((int)color(120, 131, 140));
                break;
            default: // DEFAULT
                dropdownColorsGlobal.setActive((int)BUTTON_PRESSED);
                dropdownColorsGlobal.setForeground((int)BUTTON_HOVER);
                dropdownColorsGlobal.setBackground((int)color(255));
                dropdownColorsGlobal.setCaptionLabel((int)color(1, 18, 41));
                dropdownColorsGlobal.setValueLabel((int)color(100));
                break;
        }
    }
    
    /**
     * Check if dark mode is active
     */
    boolean isDarkMode() {
        return currentTheme == ThemeType.DARK;
    }
    
    /**
     * Check if light mode is active
     */
    boolean isLightMode() {
        return currentTheme == ThemeType.LIGHT;
    }
    
    /**
     * Check if default mode is active
     */
    boolean isDefaultMode() {
        return currentTheme == ThemeType.DEFAULT;
    }
    
    // ============================================================
    // COLOR GETTER METHODS
    // These return the appropriate color based on current theme
    // ============================================================
    
    // --- Navigation Colors ---
    
    color getTopNavBackground() {
        switch(currentTheme) {
            case DARK: return DARK_TOPNAV_BG;
            case LIGHT: return LIGHT_TOPNAV_BG;
            default: return DEFAULT_TOPNAV_BG;
        }
    }
    
    color getSubNavBackground() {
        switch(currentTheme) {
            case DARK: return DARK_SUBNAV_BG;
            case LIGHT: return LIGHT_SUBNAV_BG;
            default: return DEFAULT_SUBNAV_BG;
        }
    }
    
    // --- Box/Panel Colors ---
    
    color getBoxColor() {
        switch(currentTheme) {
            case DARK: return DARK_BOX_BG;
            case LIGHT: return LIGHT_BOX_BG;
            default: return DEFAULT_BOX_BG;
        }
    }
    
    color getBoxStrokeColor() {
        switch(currentTheme) {
            case DARK: return DARK_BOX_STROKE;
            case LIGHT: return LIGHT_BOX_STROKE;
            default: return DEFAULT_BOX_STROKE;
        }
    }
    
    // --- Widget Colors ---
    
    color getWidgetBackground() {
        switch(currentTheme) {
            case DARK: return DARK_WIDGET_BG;
            case LIGHT: return LIGHT_WIDGET_BG;
            default: return DEFAULT_WIDGET_BG;
        }
    }
    
    // --- Text Colors ---
    
    color getTextColor() {
        switch(currentTheme) {
            case DARK: return DARK_TEXT_PRIMARY;
            case LIGHT: return LIGHT_TEXT_PRIMARY;
            default: return DEFAULT_TEXT_PRIMARY;
        }
    }
    
    color getSecondaryTextColor() {
        switch(currentTheme) {
            case DARK: return DARK_TEXT_SECONDARY;
            case LIGHT: return LIGHT_TEXT_SECONDARY;
            default: return DEFAULT_TEXT_SECONDARY;
        }
    }
    
    color getTextOnDarkBackground() {
        switch(currentTheme) {
            case DARK: return DARK_TEXT_ON_DARK;
            case LIGHT: return LIGHT_TEXT_ON_DARK;
            default: return DEFAULT_TEXT_ON_DARK;
        }
    }
    
    // --- Button Colors ---
    
    color getButtonColor() {
        switch(currentTheme) {
            case DARK: return DARK_BUTTON_BG;
            case LIGHT: return LIGHT_BUTTON_BG;
            default: return DEFAULT_BUTTON_BG;
        }
    }
    
    color getButtonTextColor() {
        switch(currentTheme) {
            case DARK: return DARK_BUTTON_TEXT;
            case LIGHT: return LIGHT_BUTTON_TEXT;
            default: return DEFAULT_BUTTON_TEXT;
        }
    }
    
    color getButtonHoverColor() {
        switch(currentTheme) {
            case DARK: return DARK_BUTTON_HOVER;
            case LIGHT: return LIGHT_BUTTON_HOVER;
            default: return DEFAULT_BUTTON_HOVER;
        }
    }
    
    color getButtonPressedColor() {
        switch(currentTheme) {
            case DARK: return DARK_BUTTON_PRESSED;
            case LIGHT: return LIGHT_BUTTON_PRESSED;
            default: return DEFAULT_BUTTON_PRESSED;
        }
    }
    
    // --- Help Widget (Console) Colors ---
    
    color getHelpWidgetBackground() {
        switch(currentTheme) {
            case DARK: return DARK_HELP_WIDGET_BG;
            case LIGHT: return LIGHT_HELP_WIDGET_BG;
            default: return DEFAULT_HELP_WIDGET_BG;
        }
    }
    
    color getHelpWidgetTextBackground() {
        switch(currentTheme) {
            case DARK: return DARK_HELP_WIDGET_TEXT_BG;
            case LIGHT: return LIGHT_HELP_WIDGET_TEXT_BG;
            default: return DEFAULT_HELP_WIDGET_TEXT_BG;
        }
    }
    
    // --- Graph/Plot Colors ---
    
    color getGraphBackground() {
        switch(currentTheme) {
            case DARK: return DARK_WIDGET_BG;
            case LIGHT: return color(240, 242, 245);
            default: return color(255);
        }
    }
    
    color getGraphBoxBackground() {
        switch(currentTheme) {
            case DARK: return color(12, 25, 40);
            case LIGHT: return color(250, 251, 252);
            default: return color(245);
        }
    }
    
    color getGraphGridColor() {
        switch(currentTheme) {
            case DARK: return color(35, 55, 80);
            case LIGHT: return color(220, 225, 230);
            default: return color(210);
        }
    }
    
    color getGraphLineColor() {
        switch(currentTheme) {
            case DARK: return color(45, 70, 100);
            case LIGHT: return color(200, 208, 215);
            default: return color(210);
        }
    }
    
    color getGraphAxisColor() {
        switch(currentTheme) {
            case DARK: return color(160, 175, 190);
            case LIGHT: return color(80, 95, 110);
            default: return OPENBCI_DARKBLUE;
        }
    }
    
    // --- Special Colors (dimmed in dark mode for reduced contrast) ---
    
    color getSuccessColor() {
        // Green - dimmed in dark mode
        return isDarkMode() ? DARK_SUCCESS : color(195, 242, 181);
    }
    
    color getErrorColor() {
        // Red - dimmed in dark mode
        return isDarkMode() ? DARK_ERROR : color(224, 56, 45);
    }
    
    color getWarningColor() {
        // Yellow - dimmed in dark mode
        return isDarkMode() ? DARK_WARNING : color(221, 178, 13);
    }
    
    color getAccentColor() {
        // OpenBCI blue accent - dimmed in dark mode
        return isDarkMode() ? DARK_ACCENT : color(57, 128, 204);
    }
    
    // ============================================================
    // LOGO SELECTION
    // Returns appropriate logo based on theme
    // ============================================================
    
    /**
     * Get the appropriate logo for the current theme
     * @param whiteLogo The white version of the logo
     * @param blackLogo The black version of the logo
     * @return The logo that contrasts best with current theme
     */
    PImage getLogo(PImage whiteLogo, PImage blackLogo) {
        // White logo works for both Default (blue bg) and Dark (dark bg)
        return whiteLogo;
    }
}
