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
//    - THEME_LIGHT: Light/white theme
//
///////////////////////////////////////////////////////////////////////////////////////

// Theme constants - these identify which theme is active
final int THEME_DEFAULT = 0;  // Original OpenBCI blue
final int THEME_DARK = 1;     // Dark mode
final int THEME_LIGHT = 2;    // Light mode

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
    
    // --- THEME_DARK (Dark Mode) ---
    private final color DARK_TOPNAV_BG = color(25, 25, 30);            // Very dark blue-grey
    private final color DARK_SUBNAV_BG = color(35, 35, 45);            // Slightly lighter
    private final color DARK_BOX_BG = color(45, 45, 55);               // Dark grey for boxes
    private final color DARK_BOX_STROKE = color(70, 70, 80);           // Subtle border
    private final color DARK_WIDGET_BG = color(30, 30, 38);            // Dark widget background
    private final color DARK_TEXT_PRIMARY = color(230, 230, 235);      // Off-white text
    private final color DARK_TEXT_SECONDARY = color(160, 160, 170);    // Muted text
    private final color DARK_TEXT_ON_DARK = color(230, 230, 235);      // Same as primary in dark
    private final color DARK_BUTTON_BG = color(60, 65, 80);            // Dark button
    private final color DARK_BUTTON_TEXT = color(230, 230, 235);       // Light text on buttons
    private final color DARK_BUTTON_HOVER = color(75, 80, 95);         // Slightly lighter on hover
    private final color DARK_BUTTON_PRESSED = color(50, 55, 70);       // Darker when pressed
    private final color DARK_HELP_WIDGET_BG = color(25, 25, 30);       // Match topnav
    private final color DARK_HELP_WIDGET_TEXT_BG = color(20, 20, 25);  // Very dark
    
    // --- THEME_LIGHT (Light Mode) ---
    private final color LIGHT_TOPNAV_BG = color(255);                  // White
    private final color LIGHT_SUBNAV_BG = color(245, 245, 248);        // Very light grey
    private final color LIGHT_BOX_BG = color(250, 250, 252);           // Almost white
    private final color LIGHT_BOX_STROKE = color(200, 200, 205);       // Light grey border
    private final color LIGHT_WIDGET_BG = color(255);                  // White
    private final color LIGHT_TEXT_PRIMARY = color(30, 30, 35);        // Near black
    private final color LIGHT_TEXT_SECONDARY = color(100, 100, 110);   // Grey
    private final color LIGHT_TEXT_ON_DARK = color(255);               // White (for accent buttons)
    private final color LIGHT_BUTTON_BG = color(31, 69, 110);          // Keep OpenBCI blue for buttons
    private final color LIGHT_BUTTON_TEXT = color(255);                // White on blue buttons
    private final color LIGHT_BUTTON_HOVER = color(45, 90, 140);       // Lighter blue
    private final color LIGHT_BUTTON_PRESSED = color(20, 50, 90);      // Darker blue
    private final color LIGHT_HELP_WIDGET_BG = color(245, 245, 248);   // Light grey
    private final color LIGHT_HELP_WIDGET_TEXT_BG = color(255);        // White
    
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
     * @param theme Use THEME_DEFAULT, THEME_DARK, or THEME_LIGHT
     */
    void setTheme(int theme) {
        if (theme >= THEME_DEFAULT && theme <= THEME_LIGHT) {
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
            case THEME_LIGHT:
                return "Light";
            default:
                return "Default";
        }
    }
    
    /**
     * Cycle to the next theme (useful for toggle buttons)
     */
    void cycleTheme() {
        currentTheme = (currentTheme + 1) % 3;
        println("Style: Theme cycled to " + getThemeName());
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
        switch(currentTheme) {
            case THEME_DARK:  return DARK_TOPNAV_BG;
            case THEME_LIGHT: return LIGHT_TOPNAV_BG;
            default:          return DEFAULT_TOPNAV_BG;
        }
    }
    
    color getSubNavBackground() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_SUBNAV_BG;
            case THEME_LIGHT: return LIGHT_SUBNAV_BG;
            default:          return DEFAULT_SUBNAV_BG;
        }
    }
    
    // --- Box/Panel Colors ---
    
    color getBoxColor() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_BOX_BG;
            case THEME_LIGHT: return LIGHT_BOX_BG;
            default:          return DEFAULT_BOX_BG;
        }
    }
    
    color getBoxStrokeColor() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_BOX_STROKE;
            case THEME_LIGHT: return LIGHT_BOX_STROKE;
            default:          return DEFAULT_BOX_STROKE;
        }
    }
    
    // --- Widget Colors ---
    
    color getWidgetBackground() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_WIDGET_BG;
            case THEME_LIGHT: return LIGHT_WIDGET_BG;
            default:          return DEFAULT_WIDGET_BG;
        }
    }
    
    // --- Text Colors ---
    
    color getTextColor() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_TEXT_PRIMARY;
            case THEME_LIGHT: return LIGHT_TEXT_PRIMARY;
            default:          return DEFAULT_TEXT_PRIMARY;
        }
    }
    
    color getSecondaryTextColor() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_TEXT_SECONDARY;
            case THEME_LIGHT: return LIGHT_TEXT_SECONDARY;
            default:          return DEFAULT_TEXT_SECONDARY;
        }
    }
    
    color getTextOnDarkBackground() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_TEXT_ON_DARK;
            case THEME_LIGHT: return LIGHT_TEXT_ON_DARK;
            default:          return DEFAULT_TEXT_ON_DARK;
        }
    }
    
    // --- Button Colors ---
    
    color getButtonColor() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_BUTTON_BG;
            case THEME_LIGHT: return LIGHT_BUTTON_BG;
            default:          return DEFAULT_BUTTON_BG;
        }
    }
    
    color getButtonTextColor() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_BUTTON_TEXT;
            case THEME_LIGHT: return LIGHT_BUTTON_TEXT;
            default:          return DEFAULT_BUTTON_TEXT;
        }
    }
    
    color getButtonHoverColor() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_BUTTON_HOVER;
            case THEME_LIGHT: return LIGHT_BUTTON_HOVER;
            default:          return DEFAULT_BUTTON_HOVER;
        }
    }
    
    color getButtonPressedColor() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_BUTTON_PRESSED;
            case THEME_LIGHT: return LIGHT_BUTTON_PRESSED;
            default:          return DEFAULT_BUTTON_PRESSED;
        }
    }
    
    // --- Help Widget (Console) Colors ---
    
    color getHelpWidgetBackground() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_HELP_WIDGET_BG;
            case THEME_LIGHT: return LIGHT_HELP_WIDGET_BG;
            default:          return DEFAULT_HELP_WIDGET_BG;
        }
    }
    
    color getHelpWidgetTextBackground() {
        switch(currentTheme) {
            case THEME_DARK:  return DARK_HELP_WIDGET_TEXT_BG;
            case THEME_LIGHT: return LIGHT_HELP_WIDGET_TEXT_BG;
            default:          return DEFAULT_HELP_WIDGET_TEXT_BG;
        }
    }
    
    // --- Special Colors (these stay consistent across themes for recognition) ---
    
    color getSuccessColor() {
        return color(195, 242, 181);  // TURN_ON_GREEN - always green
    }
    
    color getErrorColor() {
        return color(224, 56, 45);    // BOLD_RED - always red
    }
    
    color getWarningColor() {
        return color(221, 178, 13);   // SIGNAL_CHECK_YELLOW - always yellow
    }
    
    color getAccentColor() {
        // OpenBCI blue accent - slightly adjusted for dark mode visibility
        switch(currentTheme) {
            case THEME_DARK:  return color(70, 130, 200);  // Brighter blue for dark bg
            case THEME_LIGHT: return color(31, 69, 110);   // Original OPENBCI_BLUE
            default:          return color(57, 128, 204);  // buttonsLightBlue
        }
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
        switch(currentTheme) {
            case THEME_DARK:  return whiteLogo;  // White logo on dark background
            case THEME_LIGHT: return blackLogo;  // Black logo on light background
            default:          return whiteLogo;  // White logo on blue background
        }
    }
}
