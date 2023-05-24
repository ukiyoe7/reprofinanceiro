
WITH PED1 AS (
SELECT ID_PEDIDO,PEDORIGEM
FROM PEDID
WHERE PEDDTEMIS >='YESTERDAY'),


PED2 AS (
SELECT ID_PEDIDO,PEDORIGEM
FROM PEDID
WHERE PEDDTEMIS >='YESTERDAY')

SELECT
CASE WHEN PED1.PEDORIGEM='W' THEN PED1.PEDORIGEM
ELSE NULL END,
CASE WHEN PED2.PEDORIGEM='D' THEN PED2.PEDORIGEM
ELSE NULL END 
FROM PED1
LEFT JOIN PED2 ON PED1.ID_PEDIDO=PED2.ID_PEDIDO




