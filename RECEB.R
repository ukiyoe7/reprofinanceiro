library(DBI)
library(tidyverse)

con2 <- dbConnect(odbc::odbc(), "reproreplica")


recebi3 <- dbGetQuery(con2,"

/* SQL PARA EXTRAÇÃO DE VALORES A RECEBER E RECEBIDOS DE CLIENTES

   CRIADA EM 17.06.2022 */

-- OBTEM INFO CLIENTES NAS TABELAS CLIEN,ENDCLI E ZONAS

WITH CLI AS (SELECT C.CLICODIGO,
                     CLINOMEFANT,
                      GCLCODIGO GRUPO, 
                       SETOR 
                        FROM CLIEN C
                         INNER JOIN (SELECT CLICODIGO, ZODESCRICAO SETOR FROM ENDCLI E
                          INNER JOIN (SELECT ZOCODIGO,ZODESCRICAO FROM ZONA 
                           WHERE ZOCODIGO IN (24))Z ON E.ZOCODIGO=Z.ZOCODIGO WHERE ENDFAT='S') ED ON C.CLICODIGO=ED.CLICODIGO
                            WHERE CLICLIENTE='S'),

-- EXTRAI RECEBIVEIS DO CLIENTE NA TABELA RECEB

   RCB AS (SELECT 
            EMPCODIGO,
             B.CLICODIGO,
              RECCODIGO
               FROM RECEB B
                INNER JOIN CLI C ON B.CLICODIGO=C.CLICODIGO
                 WHERE B.RECSITUACAO = 'N') ,  
 
 -- EXTRAI RECEBIMENTOS DO CLIENTE DOS ULTIMOS 30 DIAS DA TABELA RECBX
  
    RBX AS (SELECT CLICODIGO,
                     'RECEBIDO' TIPO,
                       SUM((RX.REBVALOR + RX.REBVRJUROS) - (RX.REBVRDESC + RX.REBVRABAT)) VR_LIQUIDO
                        FROM RECBX RX
                         INNER JOIN RCB RC ON RX.RECCODIGO=RC.RECCODIGO AND RX.EMPCODIGO=RC.EMPCODIGO
                          WHERE RX.REBDTLIQ >=DATEADD(-30 DAY TO CURRENT_DATE)
                           GROUP BY 1,2), 
                        
 -- EXTRAI VALORES EM ABERTO

    NRCB AS (SELECT RC.CLICODIGO,
                     'A RECEBER' TIPO,
                       SUM(RECVALORABERTO) A_RECEBER
                        FROM RECEB RC
                         INNER JOIN CLI C ON RC.CLICODIGO=C.CLICODIGO
                          LEFT OUTER JOIN (SELECT REPARCNRDOC FROM REPARCRECEB)A ON RC.RECNRDOC=A.REPARCNRDOC
                           WHERE RECSITUACAO <> 'C' AND RECVALORABERTO > 0.009 AND A.REPARCNRDOC IS NULL 
                            GROUP BY 1,2)                     

 -- SELECT FINAL BUSCA OS CLIENTES FAZ OS JOINS E A UNIAO DAS 2 EXTRAÇÕES PARA ALTERNAR LINHAS VAZIAS
                        
       SELECT DISTINCT C.CLICODIGO,
                VR_LIQUIDO RECEB_30,
                  IIF(VR_LIQUIDO IS NOT NULL,NULL,A_RECEBER) A_RECEBER,
                   RX.TIPO
                    FROM CLI C
                     LEFT JOIN RBX RX ON C.CLICODIGO=RX.CLICODIGO
                      LEFT JOIN NRCB NC ON C.CLICODIGO=NC.CLICODIGO 
                      
                      UNION
                      
        SELECT DISTINCT C.CLICODIGO,
                IIF(A_RECEBER IS NOT NULL,NULL,VR_LIQUIDO) RECEB_30,
                 A_RECEBER,
                   NC.TIPO
                    FROM CLI C
                     LEFT JOIN RBX RX ON C.CLICODIGO=RX.CLICODIGO
                      LEFT JOIN NRCB NC ON C.CLICODIGO=NC.CLICODIGO
                    ")

View(recebi3)









