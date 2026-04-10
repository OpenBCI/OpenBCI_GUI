public enum TemplateDropdown1 implements IndexingInterface
{
    ITEM_A (0, 0, "Item A"),
    ITEM_B (1, 1, "Item B");
    
    private int index;
    private int value;
    private String label;
    
    TemplateDropdown1(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public int getValue() {
        return value;
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

public enum TemplateDropdown2 implements IndexingInterface
{
    ITEM_C (0, 0, "Item C"),
    ITEM_D (1, 1, "Item D"),
    ITEM_E (2, 2, "Item E");
    
    private int index;
    private int value;
    private String label;
    
    TemplateDropdown2(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public int getValue() {
        return value;
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

public enum TemplateDropdown3 implements IndexingInterface
{
    ITEM_F (0, 0, "Item F"),
    ITEM_G (1, 1, "Item G"),
    ITEM_H (2, 2, "Item H"),
    ITEM_I (3, 3, "Item I");
    
    private int index;
    private int value;
    private String label;
    
    TemplateDropdown3(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public int getValue() {
        return value;
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