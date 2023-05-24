

WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
    
    PED AS (SELECT ID_PEDIDO,
                    PEDCODIGO,
                     CLICODIGO,
                      PEDDTEMIS,
                       PEDDTBAIXA
                            FROM PEDID P
                             INNER JOIN FIS ON P.FISCODIGO1=FIS.FISCODIGO
                               WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023' AND PEDSITPED<>'C' ),
                               
      PROD AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU),

 /* LENTES COM PRODUCAO */ 
      
MP AS (
SELECT
      PCP.ID_PEDIDO,
        RP.PROCODIGO MATERIAL , 
         RP.RQPDESCRICAO NOME , 
           RQPSEQ,
              RP.RQPQTDADE QTD    
               FROM PEDCELPDCAO PCP
                INNER JOIN PED P ON PCP.ID_PEDIDO=P.ID_PEDIDO
                 INNER JOIN PDCAO PDC ON PCP.PDCCODIGO = PDC.PDCCODIGO AND PCP.EMPPDCCODIGO = PDC.EMPCODIGO
                  INNER JOIN REQUI REQ ON PDC.PDCCODIGO = REQ.PDCCODIGO AND PDC.EMPCODIGO = REQ.EMPCODIGO
                   INNER JOIN REQPRO RP ON RP.REQCODIGO = REQ.REQCODIGO AND RP.EMPCODIGO = REQ.EMPCODIGO),
                   
MP2 AS (
SELECT
      PCP.ID_PEDIDO,
        RP.PROCODIGO MATERIAL , 
         RP.RQPDESCRICAO NOME , 
           RQPSEQ,
              RP.RQPQTDADE QTD    
               FROM PEDCELPDCAO PCP
                INNER JOIN PED P ON PCP.ID_PEDIDO=P.ID_PEDIDO
                 INNER JOIN PDCAO PDC ON PCP.PDCCODIGO = PDC.PDCCODIGO AND PCP.EMPPDCCODIGO = PDC.EMPCODIGO
                  INNER JOIN REQUI REQ ON PDC.PDCCODIGO = REQ.PDCCODIGO AND PDC.EMPCODIGO = REQ.EMPCODIGO
                   INNER JOIN REQPRO RP ON RP.REQCODIGO = REQ.REQCODIGO AND RP.EMPCODIGO = REQ.EMPCODIGO),                   
                   
                   
  PRECO_MEDIO AS (SELECT PROCODIGO, PREPCOMEDIO FROM PREMP WHERE EMPCODIGO=1),
  
    PRECO_MEDIO2 AS (SELECT PROCODIGO, PREPCOMEDIO FROM PREMP WHERE EMPCODIGO=1), 

/* CONTROL */   
  
  CONTROL AS (SELECT A.ID_PEDIDO,CAST(REPLACE(APOBS,'Pedido ID: ','') AS INT) PCONTROL  FROM ACOPED A
                                     INNER JOIN PED P ON A.ID_PEDIDO=P.ID_PEDIDO
                                      WHERE LPCODIGO=1837),
/* PACOTES */                                  
                                      
TA AS (

SELECT ID_PEDIDO,
        REPLACE(PEDCODIGO,'.001','.000') PEDIDO,
         CLICODIGO 
          FROM PEDID P WHERE 
           PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023'),

TB AS (
SELECT ID_PEDIDO,
         PEDCODIGO,
          CLICODIGO 
           FROM PEDID P WHERE 
            PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023'),

TAB AS (
SELECT TA.ID_PEDIDO  TA1,
        TB.ID_PEDIDO TB1
         FROM TB
          INNER JOIN TA ON TA.PEDIDO=TB.PEDCODIGO AND TA.CLICODIGO=TB.CLICODIGO
           WHERE TA.ID_PEDIDO<>TB.ID_PEDIDO) ,                                   
                                      

/* PRIMEIRA INTERSECÇÃO */  
                         
DF AS  (
      SELECT PD.ID_PEDIDO,
              TB1,
               PCONTROL,
                PEDCODIGO,
                 CLICODIGO,
                  PD.EMPCODIGO,
                   PEDDTEMIS,
                    PD.PROCODIGO,
                     PR.CHAVE,
                      MATERIAL,
                       PDPDESCRICAO,
                        PREPCOMEDIO,
                             SUM(PDPQTDADE)QTD,
                              SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                                FROM PDPRD PD
                                 INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                  INNER JOIN PROD PR ON PD.PROCODIGO=PR.PROCODIGO
                                   LEFT JOIN TAB TA ON PD.ID_PEDIDO=TA.TA1 
                                    LEFT JOIN MP M ON M.ID_PEDIDO=PD.ID_PEDIDO 
                                     LEFT JOIN PRECO_MEDIO PM ON M.MATERIAL=PM.PROCODIGO
                                      LEFT JOIN CONTROL CTL ON PD.ID_PEDIDO=CTL.ID_PEDIDO 
          
                                        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12 ORDER BY ID_PEDIDO DESC)
                                        
                                        
/* SEGUNDA INTERSECÇÃO */   
                                        
SELECT * FROM DF
          LEFT JOIN MP2 M2 ON DF.TB1=M2.ID_PEDIDO 
           LEFT JOIN PRECO_MEDIO2 PM2 ON PM2.PROCODIGO=M2.MATERIAL
