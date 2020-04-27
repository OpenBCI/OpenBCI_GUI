static class DirectoryManager {
    private static DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");

    public static String getFileNameDateTime() {
        return dateFormat.format(new Date());
    }
};