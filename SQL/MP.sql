SELECT
      ID_PEDIDO,
        RP.PROCODIGO MATERIAL , 
         RP.RQPDESCRICAO NOME , 
          PD.PROUN UN , 
           RQPSEQ,
            PD.PROCODIGO2 CHAVE,
             (SELECT DISTINCT PRODESCRICAO FROM PRODU WHERE PROCODIGO=PD.PROCODIGO2) DESCRICAO_CHAVE,
              RP.RQPQTDADE QTD    
               FROM PEDCELPDCAO PCP
              LEFT JOIN PDCAO PDC ON PCP.PDCCODIGO = PDC.PDCCODIGO AND PCP.EMPPDCCODIGO = PDC.EMPCODIGO
               LEFT JOIN REQUI REQ ON PDC.PDCCODIGO = REQ.PDCCODIGO AND PDC.EMPCODIGO = REQ.EMPCODIGO
                LEFT JOIN REQPRO RP ON RP.REQCODIGO = REQ.REQCODIGO AND RP.EMPCODIGO = REQ.EMPCODIGO
               INNER JOIN (SELECT PROCODIGO,PROCODIGO2,PRODESCRICAO,PROUN FROM PRODU WHERE PROTIPO NOT IN ('T','S')) PD ON PD.PROCODIGO = RP.PROCODIGO
WHERE ID_PEDIDO=13351707