WITH 
PED AS (
SELECT P.ID_PEDIDO,
        CLICODIGO,
         RIGHT(PEDCODIGO,4) PEDCODIGO,
         REPLACE(PEDCODIGO,'.001','.000') PEDIDO_REL
                            FROM PEDID P
                               WHERE  
                               PEDDTBAIXA >=DATEADD(-90 DAY TO CURRENT_DATE) AND
                               PEDSITPED<>'C')
                               
SELECT * FROM PED
    WHERE PEDCODIGO='.001'
                               