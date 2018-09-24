package ru.biswork;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.biswork.DBConnections.DBConnections;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.concurrent.Semaphore;

/**
 * Created by BIS on 16.04.2017.
 * Обработка логов
 */
public class Log {
    boolean stop = false;
    boolean remoteDBwasUnavailable = true;
    boolean localDBwasUnavailable = false;
    int archivedCount = 0;//Хранится на локальном сервере
    private String computerName = "n/d";
    //Интервал
    private int secInterv = 10;
    //Семафор
    private Semaphore sem = new Semaphore(1);
    //Наши логи
    private LocalLog locLog = new LocalLog();
    private RemoteLog remLog = new RemoteLog(sem, locLog);
    static final Logger logger = LogManager.getLogger(Log.class.getName());

    private static SimpleDateFormat format1 = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
    private Thread transporterThread;

    public static SimpleDateFormat getSimpleDateFormat(){
        return format1;
    }

    public Log(int archivedCount, int secInterv) {
        this.archivedCount = archivedCount;
        this.secInterv = secInterv;
    }

    public void startLog() throws UnknownHostException, InterruptedException, SQLException {
        String strDate;
        String res;//Результат сохранения в Удалённую базу: 0-всё ОК, -1-что-то помшло не так
        try {
            computerName = InetAddress.getLocalHost().getHostName();
            System.out.println(computerName);
        } catch (UnknownHostException e) {
            logger.info("Не удалось определить имя компьютера!");
        }
        //Получение соединения для локальной и удаленной базы в зависимости от определлённой OS (Laptop- Windows или Raspberry Pi-Linux)
        DBConnections conn = new DBConnections();
        if (!conn.getLocalCon().isClosed())
            logger.info("SQLite доступен");

        while (!stop) {
            //Если при прошлой записе на удалённый сервер не было подключения, то пробуем переподлючиться
            if (remoteDBwasUnavailable) {
                if ((conn.getRemoteCon() != null) && (conn.getRemoteCon().isValid(2))) {
                    if ((transporterThread==null)||(!transporterThread.isAlive())) {
                        transporterThread = new Thread(new Transporter(this, conn, remLog));//Создал отдельное соединение для переноса из локальной //TODO Убедиться, что работает в один поток
                        transporterThread.start();
                        remoteDBwasUnavailable = false;
                    }
                }
            }
            strDate = format1.format(System.currentTimeMillis());
            System.out.println(strDate);
            //remoteConn=null;//Эмитируем отсутствие соединения
            if ((conn.getRemoteCon() != null) && (conn.getRemoteCon().isValid(2))) {
                logger.info("Сохранение в удалённую базу...");
                res = remLog.write(conn, computerName, strDate, "1");
            } else {
                remoteDBwasUnavailable = true;
                logger.info("Сохранение в локальную базу...");
               /* if ((localConn != null)&& (localConn.isValid(2)))*/ locLog.write(conn.getLocalCon(), computerName, strDate);
                //else System.out.println("Log-> localConn is NULL или Invalid");
            }
            System.out.println(secInterv);
            Thread.sleep((secInterv*1000) );

        }
    }


}
