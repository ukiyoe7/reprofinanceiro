WITH 
PED AS (
SELECT P.ID_PEDIDO,
        CLICODIGO,
         RIGHT(PEDCODIGO,4) PEDCODIGO,
         REPLACE(PEDCODIGO,'.001','.000') PEDIDO_REL
                            FROM PEDID P
                               WHERE  
                               PEDDTBAIXA BETWEEN '01.05.2023' AND '31.05.2023' AND
                               PEDSITPED<>'C')
                               
SELECT * FROM PED
    WHERE PEDCODIGO='.001'
                               