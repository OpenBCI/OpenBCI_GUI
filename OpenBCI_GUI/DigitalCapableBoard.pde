
interface DigitalCapableBoard {

    public boolean isDigitalActive();

    public void setDigitalActive(boolean active);

    public boolean canDeactivateDigital();

    public int[] getDigitalChannels();
};
