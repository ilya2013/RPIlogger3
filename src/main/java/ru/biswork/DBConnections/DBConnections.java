package ru.biswork.DBConnections;

import ru.biswork.Os;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Created by BIS on 17.04.2017.
 * Класс подключения к базам
 */
public class DBConnections {

    private Connection localCon;//Локальное соединение
    Connection remoteCon;//Удалённое соединение
    Connection newRemoteCon;
    Properties properties;

    private static final String con_winSQLite = "jdbc:sqlite:C:\\SQLite3\\RPI\\RPILoger.db"; //Поменять
    private static final String con_UbuntuSQLite = "jdbc:sqlite:/home/bis/sqlliteDB/test.db"; //Поменять.

    String ubuntu_remote_database;
    String ubuntu_remote_user;
    String ubuntu_remote_password;

    String windows_remote_database;
    String windows_remote_user;
    String windows_remote_password;


    public Connection getLocalCon() {
        return localCon;
    }

    public Connection getRemoteCon() {
        return remoteCon;
    }

    public DBConnections() throws SQLException {
        properties=new Properties();
        try (InputStream input = new FileInputStream("config.properties")) {
            properties.load(input);

            ubuntu_remote_database = properties.getProperty("Ubuntu_remote_database");
            ubuntu_remote_user = properties.getProperty("Ubuntu_remote_user");
            ubuntu_remote_password = properties.getProperty("Ubuntu_remote_password");

            windows_remote_database = properties.getProperty("Windows_remote_database");
            windows_remote_user = properties.getProperty("Windows_remote_user");
            windows_remote_password = properties.getProperty("Windows_remote_password");


        } catch (FileNotFoundException ex) {
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
        }

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            System.out.println("Где мой драйвер JDBC Oracle?");
        }
        try {
            Class.forName("org.sqlite.JDBC");
        } catch (ClassNotFoundException e) {
            System.out.println("Где мой драйвер JDBC SQLite?");
        }

        try {
            if (Os.isWindows()) {
                localCon = DriverManager.getConnection(con_winSQLite);
                System.out.println("Подключились к локальной базе на Windows");
            } else {
                localCon = DriverManager.getConnection(con_UbuntuSQLite);
                System.out.println("Подключились к локальной базе на Ubuntu");
            }
        } catch (SQLException e) {
            System.out.println("DBConnection->Не получилось соединиться: " + e.getMessage());
        }
        //Поток создания удалённого потока
        new RemoteConThread(this);

    }

    public Connection getNewRemoteConnection(){
        try {
        if (Os.isWindows()) {
            System.out.println("Удалённое подключение для ОС семейства Windows");
            String url="jdbc:oracle:thin:@"+ windows_remote_database;
            System.out.println(url);
                newRemoteCon = DriverManager.getConnection(url, windows_remote_user, ubuntu_remote_password);

        } else {
            System.out.println("Удаленное подключение для ОС семейства не Windows: " + Os.getOSVerion());
            newRemoteCon = DriverManager.getConnection("jdbc:oracle:thin:@"+ubuntu_remote_database, ubuntu_remote_user, ubuntu_remote_password);
        }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return newRemoteCon;
    }
}
