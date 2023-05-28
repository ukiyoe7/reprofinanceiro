WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
    
    PED AS (SELECT ID_PEDIDO,
                    PEDCODIGO,
                     CLICODIGO,
                      PEDDTEMIS,
                       PEDDTBAIXA
                            FROM PEDID P
                             INNER JOIN FIS ON P.FISCODIGO1=FIS.FISCODIGO
                               WHERE PEDDTEMIS BETWEEN '01.04.2023' AND 'TODAY' AND PEDSITPED<>'C' ),
                               
      PRECO_MEDIO AS (SELECT PROCODIGO PCODIGO, PREPCOMEDIO FROM PREMP WHERE EMPCODIGO=1),
      
-- LENTES ACABADAS      
                               
      PROD_E AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROTIPO='E' AND PROSITUACAO='A'),
                         
      DF_E AS  (
      SELECT PD.ID_PEDIDO,
                 CLICODIGO,
                  PD.EMPCODIGO,
                   PEDDTEMIS,
                    PEDDTBAIXA,
                     PD.PROCODIGO,
                      PE.CHAVE,
                       PDPDESCRICAO,
                             SUM(PDPQTDADE)QTD,
                              SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                                FROM PDPRD PD
                                 INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                  INNER JOIN PROD_E PE ON PD.PROCODIGO=PE.PROCODIGO
                                    GROUP BY 1,2,3,4,5,6,7,8 ORDER BY ID_PEDIDO DESC),


LA AS (                                        
SELECT DE.*, 
'CHAVE' MATERIA_PRIMA,
QTD MP_QTD,
PREPCOMEDIO CUSTO_MEDIO,
                  SUM(PREPCOMEDIO*QTD)CUSTO_MEDIO_TOTAL
                               FROM DF_E DE
                                LEFT JOIN PRECO_MEDIO PM ON DE.PROCODIGO=PM.PCODIGO
                                 GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13),
                                 
                                 
--- LENTES FABRICADAS


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


PROD_F AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROTIPO='F' AND PROSITUACAO='A'),
      
      
PEDIDOS_FABRICADOS AS  (
      SELECT PD.ID_PEDIDO,
                 CLICODIGO,
                  PD.EMPCODIGO,
                   PEDDTEMIS,
                    PEDDTBAIXA,
                     PD.PROCODIGO,
                      PF.CHAVE,
                       PDPDESCRICAO,
                             SUM(PDPQTDADE)QTD,
                              SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                                FROM PDPRD PD
                                 INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                  INNER JOIN PROD_F PF ON PD.PROCODIGO=PF.PROCODIGO
                                    GROUP BY 1,2,3,4,5,6,7,8 ORDER BY ID_PEDIDO DESC),


LDLP AS (                                        
SELECT DFF.*, 
MATERIA_PRIMA,
MP_QTD,
PREPCOMEDIO CUSTO_MEDIO,
                  SUM(PREPCOMEDIO*QTD)CUSTO_MEDIO_TOTAL
                               FROM PEDIDOS_FABRICADOS DFF
                                LEFT JOIN PRECO_MEDIO PM ON DFF.PROCODIGO=PM.PCODIGO
                                 LEFT JOIN MP M ON M.ID_PEDIDO=DFF.ID_PEDIDO
                                  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13)    
                                 
                                 
-- UNION =======================================================================

SELECT * FROM LA 
UNION
SELECT * FROM LDLP 


                                 