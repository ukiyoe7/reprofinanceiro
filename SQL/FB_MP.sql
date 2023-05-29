
WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
    
    PED AS (SELECT ID_PEDIDO,
                    PEDCODIGO,
                     CLICODIGO,
                      PEDDTEMIS,
                       PEDDTBAIXA
                            FROM PEDID P
                             INNER JOIN FIS ON P.FISCODIGO1=FIS.FISCODIGO
                               WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023' AND PEDSITPED<>'C' ),
                               
      PROD AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROTIPO='F'),
      
      PRECO_MEDIO AS (SELECT PROCODIGO PCODIGO, PREPCOMEDIO FROM PREMP WHERE EMPCODIGO=1),
      
      MP AS (
       SELECT
        PCP.ID_PEDIDO,
         RP.PROCODIGO MATERIA_PRIMA, 
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
                         
      DF AS  (
      SELECT PD.ID_PEDIDO,
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
                                    GROUP BY 1,2,3,4,5,6,7,8 ORDER BY ID_PEDIDO DESC)
                                        
SELECT DF.ID_PEDIDO,
         CLICODIGO,
          EMPCODIGO EMPRESA,
           PEDDTEMIS DT_EMISSAO,
            PEDDTBAIXA DT_BAIXA,
             PROCODIGO,
              CHAVE,
               PDPDESCRICAO PROD_DESCRICAO,
                QTD,
                 VRVENDA,
                  MATERIA_PRIMA,
                   MATERIA_PRIMA_CHAVE,
                    PREPCOMEDIO CUSTO_MEDIO,
                     SUM(MP_QTD) MP_QTD,
                     
                      SUM(PREPCOMEDIO*MP_QTD)CUSTO_MEDIO_TOTAL
                               FROM DF
                                LEFT JOIN MP M ON M.ID_PEDIDO=DF.ID_PEDIDO
                                 LEFT JOIN PRECO_MEDIO PM ON M.MATERIA_PRIMA=PM.PCODIGO
                                  
                                 -- WHERE  MATERIA_PRIMA IS NOT NULL
                                   GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
                                
                                
                                