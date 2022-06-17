
library(DBI)
library(tidyverse)

con2 <- dbConnect(odbc::odbc(), "reproreplica")





recebi <- dbGetQuery(con2,"
WITH CLI AS (SELECT C.CLICODIGO,
                     CLINOMEFANT,
                      GCLCODIGO GRUPO, 
                       SETOR 
                        FROM CLIEN C
                         INNER JOIN (SELECT CLICODIGO, ZODESCRICAO SETOR FROM ENDCLI E
                          INNER JOIN (SELECT ZOCODIGO,ZODESCRICAO FROM ZONA 
                           WHERE ZOCODIGO IN(20,21,22,23,24,28))Z ON E.ZOCODIGO=Z.ZOCODIGO WHERE ENDFAT='S') ED ON C.CLICODIGO=ED.CLICODIGO
                             WHERE CLICLIENTE='S' AND C.CLICODIGO=400),
  
  RCB AS (SELECT 
            EMPCODIGO,
             B.CLICODIGO,
              RECCODIGO
               FROM RECEB B
                INNER JOIN CLI C ON B.CLICODIGO=C.CLICODIGO
                 WHERE B.RECSITUACAO = 'N') ,  
  
   RBX AS (SELECT RX.EMPCODIGO,
                   REBDTPAGTO,
                    CLICODIGO,
                     RX.RECCODIGO,
                      SUM((RX.REBVALOR + RX.REBVRJUROS) - (RX.REBVRDESC + RX.REBVRABAT)) VR_LIQUIDO,
                      1 CLASS 
                      FROM RECBX RX
                       INNER JOIN RCB RC ON RX.RECCODIGO=RC.RECCODIGO AND RX.EMPCODIGO=RC.EMPCODIGO
                        WHERE RX.REBDTLIQ >=DATEADD(-30 DAY TO CURRENT_DATE)
                         GROUP BY 1,2,3,4
                        ) ,
                        
    RBX2 AS (SELECT RX.EMPCODIGO,
                   REBDTPAGTO,
                    CLICODIGO,
                     RX.RECCODIGO,
                     SUM((RX.REBVALOR + RX.REBVRJUROS) - (RX.REBVRDESC + RX.REBVRABAT)) VR_LIQUIDO2,
                      2 CLASS 
                      FROM RECBX RX
                       INNER JOIN RCB RC ON RX.RECCODIGO=RC.RECCODIGO AND RX.EMPCODIGO=RC.EMPCODIGO
                        WHERE RX.REBDTLIQ >=DATEADD(-10 DAY TO CURRENT_DATE)
                        GROUP BY 1,2,3,4
                        )  

    SELECT C.CLICODIGO,
               VR_LIQUIDO  V,
                VR_LIQUIDO2 V2
                  FROM CLI C
                   LEFT JOIN RBX RX ON C.CLICODIGO=RX.CLICODIGO 
                    LEFT JOIN RBX2 RX2 ON C.CLICODIGO=RX2.CLICODIGO 
                 
")

View(recebi)

recebi %>% .[duplicated(.$CLICODIGO),]
