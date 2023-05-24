
WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
    
    PED AS (SELECT ID_PEDIDO,
                    PEDCODIGO,
                     CLICODIGO,
                      PEDDTEMIS,
                       PEDDTBAIXA
                            FROM PEDID P
                             INNER JOIN FIS ON P.FISCODIGO1=FIS.FISCODIGO
                               WHERE PEDDTEMIS BETWEEN '01.04.2023' AND 'TODAY' AND PEDSITPED<>'C' ),
                               
      PROD AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROTIPO='E'),
      
      PRECO_MEDIO AS (SELECT PROCODIGO PCODIGO, PREPCOMEDIO FROM PREMP WHERE EMPCODIGO=1),
                         
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

                                        
SELECT ID_PEDIDO,
        CLICODIGO,
         EMPCODIGO,
          PEDDTEMIS,
           PEDDTBAIXA,
            PROCODIGO,
             CHAVE,
              PDPDESCRICAO,
               QTD,
                VRVENDA,
                 PREPCOMEDIO CUSTO_MEDIO,
                  SUM(PREPCOMEDIO*QTD)CUSTO_MEDIO_TOTAL
                               FROM DF
                                LEFT JOIN PRECO_MEDIO PM ON DF.PROCODIGO=PM.PCODIGO
                                 GROUP BY 1,2,3,4,5,6,7,8,9,10,11
                                
                                
                                