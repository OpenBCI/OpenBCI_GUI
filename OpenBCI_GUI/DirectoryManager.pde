static class DirectoryManager {

    public static String getDateString() {
        String fname = year() + "-";
        if (month() < 10) fname=fname+"0";
        fname = fname + month() + "-";
        if (day() < 10) fname = fname + "0";
        fname = fname + day();

        fname = fname + "_";
        if (hour() < 10) fname = fname + "0";
        fname = fname + hour() + "-";
        if (minute() < 10) fname = fname + "0";
        fname = fname + minute() + "-";
        if (second() < 10) fname = fname + "0";
        fname = fname + second();
        return fname;
    }
}