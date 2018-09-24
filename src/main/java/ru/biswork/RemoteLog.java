package ru.biswork;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.biswork.DBConnections.DBConnections;

import java.sql.*;
import java.util.concurrent.Semaphore;

/**
 * Created by BIS on 17.04.2017.
 * Запись в базу Oracle
 */
public class RemoteLog {
    private Semaphore sem;
    private LocalLog local;
    static final Logger logger = LogManager.getLogger(RemoteLog.class.getName());
    //DBConnection con;


    public RemoteLog(Semaphore sem, LocalLog local) {
        this.sem = sem;
        this.local = local;
    }

    private void writeLocal(Connection localConn ,String device, String strDate) throws SQLException {
        local.write(localConn,device,strDate);
    }

/*
 * Запись в удалённую базу
 */
    public String write(DBConnections connections, String device, String strDate, String direct) throws SQLException {
        CallableStatement st = connections.getRemoteCon().prepareCall("{?=call RPI_LIB.set_ping(?,?,?,?)}");
        String res = "-1";
        String dbErrDesc;//Подробное описание ошибки от Oracle

        //Заполняем входные папраметры
        try {
            st.setString(2, device);
            st.setString(3, strDate);
            st.setString(4, direct);
        }catch (Exception e){
            logger.error("Ошибка Заполняем входные параметры: "+e.getMessage());
            //Пишем в локальную, из-за ошибки при попытке "записи"
            if (direct.equals(1))
            writeLocal(connections.getLocalCon() , device,  strDate);
            return "-1";

        }
        try {
            st.registerOutParameter(1,Types.VARCHAR);
            st.registerOutParameter(5,Types.VARCHAR);
        }catch (Exception e){
            logger.error("Ошибка Заполняем входные параметры: "+e.getMessage());
            //Пишем в локальную, из-за ошибки при попытке "записи"
            if (direct.equals('1'))
                writeLocal(connections.getLocalCon() , device,  strDate);
        }
        try {
            logger.info("Сохранение в удалённую базу  Direct: "+direct);
            st.execute();
            res=st.getString(1);
            if (!res.equals(0))
                System.out.println(st.getString(5));
        }catch (Exception e){
            System.out.println("Ошибка при Execute "+e.getMessage());
            //Пишем в локальную, из-за ошибки при попытке "записи"
            if (direct.equals('1'))
                writeLocal(connections.getLocalCon() , device,  strDate);
        }finally {
         st.close();
        }
        return res;


    }
}

