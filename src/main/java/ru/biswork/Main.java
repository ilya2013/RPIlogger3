package ru.biswork;
import java.net.UnknownHostException;
import java.sql.SQLException;

/**
 * Created by BIS on 16.04.2017.
 * Эксперименты с RPI Java+SQLite3
 * Попытка записи данных напрямую в базу Oracle, при
 * её недоступности данные пишутся на локальную базу устройства (с использованием SQLite)
 * после восстановления соединения c удалённой базой идёт перенос данных с локальной
 */
public class Main {

    public static void main(String[] args) throws InterruptedException, UnknownHostException {
        Log log=new Log(10,1);//TODO Исключить логи из GIT
        try {
            log.startLog();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}