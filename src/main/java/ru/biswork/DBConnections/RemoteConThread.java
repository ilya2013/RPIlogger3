package ru.biswork.DBConnections;

import ru.biswork.DBConnections.DBConnections;
import ru.biswork.Os;

import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Created by BIS on 07.11.2017.
 * Поток отвечающий за поддержание работающего удалённого соединения
 */
public class RemoteConThread implements Runnable {
    private DBConnections dbConnections;

    RemoteConThread(DBConnections dbConnections) {
        this.dbConnections = dbConnections;
        new Thread(this).start();
    }

    @Override
    public void run() {

        while (true) {
            try {
                if ((dbConnections.remoteCon == null)|| (!dbConnections.remoteCon.isValid(2))) {
                    if (Os.isWindows())  {
                        System.out.println("Удалённое подключение для ОС семейства Windows");
                        String url="jdbc:oracle:thin:@"+ dbConnections.windows_remote_database;
                        System.out.println(url);
                        dbConnections.remoteCon = DriverManager.getConnection("jdbc:oracle:thin:@" + dbConnections.windows_remote_database, dbConnections.windows_remote_user, dbConnections.windows_remote_password);

                    } else {
                        System.out.println("Удаленное подключение для ОС семейства не Windows: " + Os.getOSVerion());
                        dbConnections.remoteCon = DriverManager.getConnection("jdbc:oracle:thin:@" + dbConnections.ubuntu_remote_database, dbConnections.ubuntu_remote_user, dbConnections.ubuntu_remote_password);
                    }


                }
            } catch (SQLException e) {
                System.out.println("                                      Неудачная попытка подключения, к удалённому!!!");
                //e.printStackTrace();
            }finally {
                try {
                    Thread.sleep(5000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

        }
    }
}