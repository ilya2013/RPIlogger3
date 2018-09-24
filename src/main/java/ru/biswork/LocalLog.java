package ru.biswork;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.sql.*;
import java.util.Date;
import java.util.concurrent.Semaphore;

/**
 * Created by BIS on 17.04.2017.
 *Запись в SQLite3
 */

public class LocalLog {
    static final Logger logger = LogManager.getLogger(LocalLog.class.getName());

    public String write(Connection conn, String device, String strDate) throws SQLException {
        String res="0";
        String sql = String.format("INSERT INTO PING values (1,\"%s\",\"%s\")",device,strDate);
        Statement st = conn.createStatement();
        //Заполняем входные папраметры
        try {
            logger.info("Сохранение в локальную базу (LoacalLog.Java)");
            st.execute(sql);
        } catch (Exception e) {
            logger.error("Ошибка Заполняем входные параметры: " + e.getMessage());
            res="0";
        }

        st.close();
//        conn.commit();
        //conn.close();
        res="1";
        return res;
    }
}
