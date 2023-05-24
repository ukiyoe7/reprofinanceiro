

    
 WITH   PED AS (SELECT ID_PEDIDO,
                    PEDCODIGO,
                     CLICODIGO,
                      PEDDTEMIS,
                       PEDDTBAIXA
                            FROM PEDID P
                               WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023' AND PEDSITPED<>'C' )
                               
SELECT A.ID_PEDIDO,CAST(REPLACE(APOBS,'Pedido ID: ','') AS INT) CONTROL  FROM ACOPED A
                                     INNER JOIN PED P ON A.ID_PEDIDO=P.ID_PEDIDO
                                      WHERE LPCODIGO=1837                          
                               
                               


