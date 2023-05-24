WITH PED AS(
SELECT ID_PEDIDO,
        CLICODIGO,
         PEDDTEMIS,
          PEDDTBAIXA,
           PEDORIGEM
            FROM PEDID P
             WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023')
          
          
          SELECT PD.ID_PEDIDO,
                  CLICODIGO,
                   PEDDTEMIS,
                    PEDDTBAIXA,
                     PEDORIGEM,
                      PCTNUMERO
                       FROM PDPRD PD
                        INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO