///////////////////////////////////////////////////////////////////////////////////////
//
//  Style.pde - Theme Manager for OpenBCI GUI
//  
//  Created for GUI v7 Dark Mode Feature (Issue #705)
//  This class centralizes all color definitions and allows switching between themes.
//
//  Themes available:
//    - THEME_DEFAULT: Original OpenBCI blue theme
//    - THEME_DARK: Dark mode for accessibility (reduced eye strain)
//
///////////////////////////////////////////////////////////////////////////////////////

// Theme constants - these identify which theme is active
final int THEME_DEFAULT = 0;  // Original OpenBCI blue
final int THEME_DARK = 1;     // Dark mode

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
    private int currentTheme;
    
    // ============================================================
    // COLOR DEFINITIONS FOR EACH THEME
    // ============================================================
    
    // --- THEME_DEFAULT (Original OpenBCI Blue) ---
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
    
    // --- THEME_DARK (Dark Mode - OpenBCI colors but darker, near black) ---
    // Based on OpenBCI blue (31, 69, 110) but much darker
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
        // Default to the original OpenBCI theme
        this.currentTheme = THEME_DEFAULT;
    }
    
    Style(int theme) {
        this.currentTheme = theme;
    }
    
    // ============================================================
    // THEME SWITCHING
    // ============================================================
    
    /**
     * Set the current theme
     * @param theme Use THEME_DEFAULT or THEME_DARK
     */
    void setTheme(int theme) {
        if (theme >= THEME_DEFAULT && theme <= THEME_DARK) {
            this.currentTheme = theme;
            println("Style: Theme changed to " + getThemeName());
        }
    }
    
    /**
     * Get the current theme ID
     */
    int getTheme() {
        return this.currentTheme;
    }
    
    /**
     * Get the current theme name as a string
     */
    String getThemeName() {
        switch(currentTheme) {
            case THEME_DARK:
                return "Dark";
            default:
                return "Default";
        }
    }
    
    /**
     * Cycle to the next theme (toggle between Default and Dark)
     */
    void cycleTheme() {
        currentTheme = (currentTheme + 1) % 2;  // Only 2 themes now
        println("Style: Theme cycled to " + getThemeName());
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
        if (isDarkMode()) {
            dropdownColorsGlobal.setActive((int)color(15, 35, 60));      // bg when pressed
            dropdownColorsGlobal.setForeground((int)color(25, 50, 80));  // hover
            dropdownColorsGlobal.setBackground((int)color(18, 35, 55));  // bg of boxes
            dropdownColorsGlobal.setCaptionLabel((int)color(200, 210, 220)); // text in primary
            dropdownColorsGlobal.setValueLabel((int)color(180, 190, 200));   // text in dropdowns
        } else {
            dropdownColorsGlobal.setActive((int)BUTTON_PRESSED);
            dropdownColorsGlobal.setForeground((int)BUTTON_HOVER);
            dropdownColorsGlobal.setBackground((int)color(255));
            dropdownColorsGlobal.setCaptionLabel((int)color(1, 18, 41));
            dropdownColorsGlobal.setValueLabel((int)color(100));
        }
    }
    
    /**
     * Check if dark mode is active
     */
    boolean isDarkMode() {
        return currentTheme == THEME_DARK;
    }
    
    // ============================================================
    // COLOR GETTER METHODS
    // These return the appropriate color based on current theme
    // ============================================================
    
    // --- Navigation Colors ---
    
    color getTopNavBackground() {
        return isDarkMode() ? DARK_TOPNAV_BG : DEFAULT_TOPNAV_BG;
    }
    
    color getSubNavBackground() {
        return isDarkMode() ? DARK_SUBNAV_BG : DEFAULT_SUBNAV_BG;
    }
    
    // --- Box/Panel Colors ---
    
    color getBoxColor() {
        return isDarkMode() ? DARK_BOX_BG : DEFAULT_BOX_BG;
    }
    
    color getBoxStrokeColor() {
        return isDarkMode() ? DARK_BOX_STROKE : DEFAULT_BOX_STROKE;
    }
    
    // --- Widget Colors ---
    
    color getWidgetBackground() {
        return isDarkMode() ? DARK_WIDGET_BG : DEFAULT_WIDGET_BG;
    }
    
    // --- Text Colors ---
    
    color getTextColor() {
        return isDarkMode() ? DARK_TEXT_PRIMARY : DEFAULT_TEXT_PRIMARY;
    }
    
    color getSecondaryTextColor() {
        return isDarkMode() ? DARK_TEXT_SECONDARY : DEFAULT_TEXT_SECONDARY;
    }
    
    color getTextOnDarkBackground() {
        return isDarkMode() ? DARK_TEXT_ON_DARK : DEFAULT_TEXT_ON_DARK;
    }
    
    // --- Button Colors ---
    
    color getButtonColor() {
        return isDarkMode() ? DARK_BUTTON_BG : DEFAULT_BUTTON_BG;
    }
    
    color getButtonTextColor() {
        return isDarkMode() ? DARK_BUTTON_TEXT : DEFAULT_BUTTON_TEXT;
    }
    
    color getButtonHoverColor() {
        return isDarkMode() ? DARK_BUTTON_HOVER : DEFAULT_BUTTON_HOVER;
    }
    
    color getButtonPressedColor() {
        return isDarkMode() ? DARK_BUTTON_PRESSED : DEFAULT_BUTTON_PRESSED;
    }
    
    // --- Help Widget (Console) Colors ---
    
    color getHelpWidgetBackground() {
        return isDarkMode() ? DARK_HELP_WIDGET_BG : DEFAULT_HELP_WIDGET_BG;
    }
    
    color getHelpWidgetTextBackground() {
        return isDarkMode() ? DARK_HELP_WIDGET_TEXT_BG : DEFAULT_HELP_WIDGET_TEXT_BG;
    }
    
    // --- Graph/Plot Colors ---
    
    color getGraphBackground() {
        // The outer background of plots
        return isDarkMode() ? DARK_WIDGET_BG : color(255);
    }
    
    color getGraphBoxBackground() {
        // The inner box background of plots (where data is drawn)
        return isDarkMode() ? color(12, 25, 40) : color(245);
    }
    
    color getGraphGridColor() {
        return isDarkMode() ? color(35, 55, 80) : color(210);
    }
    
    color getGraphLineColor() {
        return isDarkMode() ? color(45, 70, 100) : color(210);
    }
    
    color getGraphAxisColor() {
        // Axis text and lines
        return isDarkMode() ? color(160, 175, 190) : OPENBCI_DARKBLUE;
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
