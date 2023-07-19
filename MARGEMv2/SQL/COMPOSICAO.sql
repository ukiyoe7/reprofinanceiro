
WITH 
PEDID_DATE AS (SELECT ID_PEDIDO FROM PEDID WHERE PEDDTBAIXA >=DATEADD(-90 DAY TO CURRENT_DATE)),

PRECO_MEDIO AS (SELECT PROCODIGO PCODIGO, PREPCOMEDIO FROM PREMP WHERE EMPCODIGO=1)

SELECT
        PCP.ID_PEDIDO,
          PR.PROCODIGO2 MATERIA_PRIMA_CHAVE,
              AVG(PREPCOMEDIO) CUSTO_MEDIO, 
               SUM(RP.RQPQTDADE) MP_QTD   
                FROM PEDCELPDCAO PCP
                 INNER JOIN PEDID_DATE P ON PCP.ID_PEDIDO=P.ID_PEDIDO
                  LEFT JOIN PDCAO PDC ON PCP.PDCCODIGO = PDC.PDCCODIGO AND PCP.EMPPDCCODIGO = PDC.EMPCODIGO
                   LEFT JOIN REQUI REQ ON PDC.PDCCODIGO = REQ.PDCCODIGO AND PDC.EMPCODIGO = REQ.EMPCODIGO
                    LEFT JOIN REQPRO RP ON RP.REQCODIGO = REQ.REQCODIGO AND RP.EMPCODIGO = REQ.EMPCODIGO
                     LEFT JOIN PRECO_MEDIO PM ON RP.PROCODIGO=PM.PCODIGO
                      INNER JOIN (SELECT PROCODIGO,PROCODIGO2 FROM PRODU WHERE PROTIPO IN ('F','E','P'))PR ON RP.PROCODIGO=PR.PROCODIGO
                       GROUP BY 1,2