package ru.biswork;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.biswork.DBConnections.DBConnections;

import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

/**
 * Created by BIS on 19.04.2017.
 * Переносчик накопившихся данных из локальной базы в удалённую
 */
public class Transporter implements Runnable{
    static final Logger logger = LogManager.getLogger(Transporter.class.getName());
    private Log log;
    private Connection remCon;
    private Connection locCon;
    private RemoteLog remLog;
    //private int bulkSize=10;
    private final static int bulkSize = 100;
    private final static boolean AUTO_COMMIT_MODE = false;
    private ArrayList<String> record=new ArrayList();

   /* public Transporter(Log log, Connection remCon, Connection locCon) {
        this.log = log;
        this.remCon = remCon;
        this.locCon = locCon;
    }
    */

    public Transporter(Log log, Connection remCon, Connection locCon, RemoteLog remLog) {
        this.log = log;
        this.remCon = remCon;
        this.locCon = locCon;
        this.remLog = remLog;
        //new Thread(this).start();
    }

    public Transporter(Log log, DBConnections conn, RemoteLog remLog) {
        this.log = log;
        this.remCon = conn.getNewRemoteConnection();
        this.locCon = conn.getLocalCon();
        this.remLog = remLog;
        //new Thread(this).start();//TODO запускается ли выше поток
    }

//    private Number getLocalRecords(){
//
//    }

    @Override
    public void run() {

        boolean stop = false;
        int rowCount = 0;
        long startTime;
        // while (!log.stop && !stop){
        logger.info("Начало переноса данных из локального хранилища в удалённое...");
        //System.out.println("Начало переноса данных из локального хранилища в удалённое...");//Вычитование
        String res = "0";
        //
        //String readSQL = "select p1.device,p1.datetime,substr(p1.datetime,1,2)||substr(p1.datetime,4,2)||substr(p1.datetime,7,4) as day from ping p1 where  substr(p1.datetime,1,2)||substr(p1.datetime,4,2)||substr(p1.datetime,7,4)=  (select  substr(p2.datetime,1,2)||substr(p2.datetime,4,2)||substr(p2.datetime,7,4)  from ping p2 limit 1)";
        String readSQL ="Select device,datetime from ping";
        String deleteSQL = "delete from ping";
        final String ADD_DATA_SQL = "insert into ping(ID,DEVICE, DATETIME, DIRECT,insert_datetime) values (PING_SEQ.nextval,?,?,?,CURRENT_TIMESTAMP)";

        Statement readST = null;
        Statement deleteST = null;
        CallableStatement writeST = null;

        StringBuilder device = new StringBuilder();
        StringBuilder datetime = new StringBuilder();
        //StringBuilder day = new StringBuilder();

        SimpleDateFormat dateFormat = Log.getSimpleDateFormat();
        java.util.Date date;
        try {
            writeST = remCon.prepareCall(ADD_DATA_SQL);
            remCon.setAutoCommit(AUTO_COMMIT_MODE);
        } catch (SQLException e1) {
            e1.printStackTrace();
        }
        //while (true) {//TODO Подумать как остановиться
            try {
                readST = locCon.createStatement();
                deleteST = locCon.createStatement();
                //Thread.sleep(5000);

            } catch (SQLException e) {
                e.printStackTrace();
            }
            startTime = System.nanoTime();
            //Заполняем входные параметры
            try {
                readST.setFetchSize(bulkSize*3);
                ResultSet rs = readST.executeQuery(readSQL);

                while (rs.next()) {
                    device.delete(0, Integer.MAX_VALUE);
                    datetime.delete(0, Integer.MAX_VALUE);
                    //day.delete(0, Integer.MAX_VALUE);

                    device.append(rs.getString(rs.findColumn("device")));
                    datetime.append(rs.getString(rs.findColumn("datetime")));
                    //day.append(rs.getString(3));
                    //Перенос записи

                    Long timestamp = System.currentTimeMillis();
                    int batchSize = bulkSize;
                    writeST.setString(1, device.toString());
                    date = dateFormat.parse(datetime.toString());
                    writeST.setDate(2, new java.sql.Date(date.getTime()));
                    writeST.setString(3, "0");
                    writeST.addBatch();
                    if (--batchSize <= 0) {
                        writeST.executeBatch();
                        batchSize = bulkSize;
                    }
                    rowCount += 1;
                }
                //Передача не полной пачки
                writeST.executeBatch();
                res = "0";
                remCon.commit();

            } catch (SQLException e1) {
                e1.printStackTrace();
                logger.error("Ошибка заполнения входных параметров: " + e1.getMessage());
                res = "-1";

            } catch (ParseException e) {
                e.printStackTrace();
                logger.error("Ошибка парсинга даты: " + e.getMessage());
                res = "-1";
            } finally {
                try {
                    readST.close();//В любом случае пытаемся закрыть statement
                    writeST.close();
                    log.remoteDBwasUnavailable = false;
                    remCon.close();
                    if (rowCount > 0)logger.info("Успешно перенесено записей:" + rowCount);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            logger.info("Вставка данных в удалённое хранилище завершена");
            if (res.equals("0")) {
                logger.info("Перенос данных из локальной базы в удаленную прошёл успешно!!!");
                logger.info("Время переноса: " + String.format("%,12d", System.nanoTime() - startTime) + " ns");
                try {
                   // if (day.length() > 0) {
                        deleteST.executeUpdate(deleteSQL);
                        logger.info("Удаление данных из резервной таблицы завершено.");
                    //}
                } catch (SQLException e) {
                    e.printStackTrace();
                    try {
                        deleteST.close();
                    } catch (SQLException e1) {
                        e1.printStackTrace();
                    }
                }
        //    }
        }
    }
}
