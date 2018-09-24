package ru.biswork;

/**
 * Created by BIS on 19.04.2017.
 * Определение ОС системы и её свойств
 */
public class Os {

    public static boolean isWindows(){

        String os = System.getProperty("os.name").toLowerCase();
        //windows
        return (os.contains("win"));

    }

    public static boolean isMac(){

        String os = System.getProperty("os.name").toLowerCase();
        //Mac
        return (os.contains("mac"));

    }

    public static boolean isUnix (){

        String os = System.getProperty("os.name").toLowerCase();
        //linux or unix
        return (os.contains("nix") || os.indexOf( "nux") >=0);

    }
    public static String getOSVerion() {
        String os = System.getProperty("os.version");
        return os;
    }
}
