
    
 WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),   
 
 
 PEDID_DATE AS (SELECT ID_PEDIDO FROM PEDID WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023'),
 
 PED AS (SELECT ID_PEDIDO,
                         REPLACE(PEDCODIGO,'.001','.000') PEDIDO_REL,
                          CLICODIGO,
                           PEDDTEMIS,
                            PEDDTBAIXA
                             FROM PEDID P
                              WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023' AND PEDSITPED<>'C'),
                              
                               PRECO_MEDIO AS (SELECT PROCODIGO PCODIGO, PREPCOMEDIO FROM PREMP WHERE EMPCODIGO=1),
                              
PROD_F AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROTIPO='F'),
                              
                                 
MP AS (
       SELECT
        PCP.ID_PEDIDO,
         RP.PROCODIGO MATERIA_PRIMA , 
          PR.PROCODIGO2 MATERIA_PRIMA_CHAVE,
           RP.RQPDESCRICAO NOME , 
            RQPSEQ,
              SUM(RP.RQPQTDADE) MP_QTD     
               FROM PEDCELPDCAO PCP
                INNER JOIN (SELECT ID_PEDIDO FROM PEDID WHERE PEDDTEMIS BETWEEN '01.04.2023' AND 'TODAY') P ON PCP.ID_PEDIDO=P.ID_PEDIDO
                 INNER JOIN PDCAO PDC ON PCP.PDCCODIGO = PDC.PDCCODIGO AND PCP.EMPPDCCODIGO = PDC.EMPCODIGO
                  INNER JOIN REQUI REQ ON PDC.PDCCODIGO = REQ.PDCCODIGO AND PDC.EMPCODIGO = REQ.EMPCODIGO
                   INNER JOIN REQPRO RP ON RP.REQCODIGO = REQ.REQCODIGO AND RP.EMPCODIGO = REQ.EMPCODIGO
                    INNER JOIN (SELECT PROCODIGO,PROCODIGO2 FROM PRODU WHERE PROTIPO IN ('F','E','P'))PR ON RP.PROCODIGO=PR.PROCODIGO
                     GROUP BY 1,2,3,4,5),                               
                               
CONTROLA  AS(
SELECT A.ID_PEDIDO,MAX(APCODIGO)APCODIGO FROM ACOPED A
            INNER JOIN PEDID_DATE PT ON A.ID_PEDIDO=PT.ID_PEDIDO WHERE LPCODIGO=1837 
              GROUP BY 1),

 CONTROLB AS (SELECT A.ID_PEDIDO,CAST(REPLACE(APOBS,'Pedido ID: ','') AS INT) PCONTROL FROM ACOPED A
            INNER JOIN CONTROLA CA 
             ON A.ID_PEDIDO=CA.ID_PEDIDO AND A.APCODIGO=CA.APCODIGO), 
             
             
PEDIDOS_CONTROL AS  (
      SELECT PD.ID_PEDIDO,
                  PCONTROL,   
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
                                   -- INNER JOIN CONTROLB CB ON PD.ID_PEDIDO=CB.ID_PEDIDO
                                    GROUP BY 1,2,3,4,5,6,7,8,9 ORDER BY ID_PEDIDO DESC)


                                      
SELECT PCC.ID_PEDIDO,
                   CLICODIGO,
                    EMPCODIGO,
                     PEDDTEMIS,
                      PEDDTBAIXA,
                       PROCODIGO,
                        CHAVE,
                         PDPDESCRICAO,
                           QTD,
                            VRVENDA,
                             MATERIA_PRIMA,
                              MATERIA_PRIMA_CHAVE,
                               PREPCOMEDIO CUSTO_MEDIO,
                                SUM(MP_QTD) MP_QTD,
                                 SUM(PREPCOMEDIO*QTD)CUSTO_MEDIO_TOTAL
                                  FROM PEDIDOS_CONTROL PCC
                                   LEFT JOIN MP M ON M.ID_PEDIDO=PCC.PCONTROL
                                    LEFT JOIN PRECO_MEDIO PM ON PCC.PROCODIGO=PM.PCODIGO
                                    -- WHERE PCONTROL IS NOT NULL
                                      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13  


