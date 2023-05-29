
WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
    
    PED AS (SELECT ID_PEDIDO,
                    PEDCODIGO,
                     CLICODIGO,
                      PEDDTEMIS,
                       PEDDTBAIXA
                            FROM PEDID P
                             INNER JOIN FIS ON P.FISCODIGO1=FIS.FISCODIGO
                               WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '01.04.2023' AND PEDSITPED<>'C' ),
                               
      PROD AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROTIPO='F'),
      
      PRECO_MEDIO AS (SELECT PROCODIGO PCODIGO, PREPCOMEDIO FROM PREMP WHERE EMPCODIGO=1),
      
  /* CONTROL */   
  
CONTROLA  AS(
SELECT A.ID_PEDIDO,MAX(APCODIGO)APCODIGO FROM ACOPED A
            INNER JOIN (SELECT ID_PEDIDO FROM PEDID WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '01.04.2023') P 
             ON A.ID_PEDIDO=P.ID_PEDIDO WHERE LPCODIGO=1837 
              GROUP BY 1),

 CONTROLB AS (SELECT A.ID_PEDIDO,CAST(REPLACE(APOBS,'Pedido ID: ','') AS INT) PCONTROL FROM ACOPED A
            INNER JOIN CONTROLA CA 
             ON A.ID_PEDIDO=CA.ID_PEDIDO AND A.APCODIGO=CA.APCODIGO),
      
      MP AS (
       SELECT
        PCP.ID_PEDIDO,
         RP.PROCODIGO MATERIA_PRIMA , 
          RP.RQPDESCRICAO NOME , 
            RQPSEQ,
              RP.RQPQTDADE MP_QTD    
               FROM PEDCELPDCAO PCP
                INNER JOIN (SELECT ID_PEDIDO FROM PEDID WHERE PEDDTEMIS BETWEEN '01.04.2023' AND 'TODAY') P ON PCP.ID_PEDIDO=P.ID_PEDIDO
                 INNER JOIN PDCAO PDC ON PCP.PDCCODIGO = PDC.PDCCODIGO AND PCP.EMPPDCCODIGO = PDC.EMPCODIGO
                  INNER JOIN REQUI REQ ON PDC.PDCCODIGO = REQ.PDCCODIGO AND PDC.EMPCODIGO = REQ.EMPCODIGO
                   INNER JOIN REQPRO RP ON RP.REQCODIGO = REQ.REQCODIGO AND RP.EMPCODIGO = REQ.EMPCODIGO
                    INNER JOIN (SELECT PROCODIGO FROM PRODU WHERE PROTIPO IN ('F','E','P'))PR ON RP.PROCODIGO=PR.PROCODIGO),
                         
      DF AS  (
      SELECT PD.ID_PEDIDO,
                PCONTROL,
                 CLICODIGO,
                  PD.EMPCODIGO,
                   PEDDTEMIS,
                    PEDDTBAIXA,
                     PD.PROCODIGO,
                      PR.CHAVE,
                       PDPDESCRICAO,
                             SUM(PDPQTDADE)QTD,
                              SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                                FROM PDPRD PD
                                  INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                   INNER JOIN PROD PR ON PD.PROCODIGO=PR.PROCODIGO
                                    LEFT JOIN CONTROLB CTL ON PD.ID_PEDIDO=CTL.ID_PEDIDO
                                    GROUP BY 1,2,3,4,5,6,7,8,9 ORDER BY ID_PEDIDO DESC)
                                    
                                    
                                    
SELECT DF.ID_PEDIDO,
        PCONTROL,
         CLICODIGO,
          EMPCODIGO,
           PEDDTEMIS,
            PEDDTBAIXA,
             PROCODIGO,
              CHAVE,
               PDPDESCRICAO,
                MATERIA_PRIMA,
                 MP_QTD,
                  QTD,
                   VRVENDA,
                    PREPCOMEDIO CUSTO_MEDIO,
                     SUM(PREPCOMEDIO*QTD)CUSTO_MEDIO_TOTAL
                               FROM DF
                                LEFT JOIN PRECO_MEDIO PM ON DF.PROCODIGO=PM.PCODIGO
                                 LEFT JOIN MP M ON M.ID_PEDIDO=DF.PCONTROL
                                  WHERE PCONTROL IS NOT NULL
                                  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
                                
                                
                                