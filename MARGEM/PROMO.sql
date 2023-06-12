-- PEDIDOS PROMO

WITH 
PEDID_DATE AS (SELECT ID_PEDIDO FROM PEDID WHERE PEDDTBAIXA BETWEEN '01.01.2023' AND 'TODAY'),   
    

PED_PROMO_PAP AS
(
SELECT P1.ID_PEDIDO ID_PEDIDO_PROMO 
    FROM PDPRD P1
    INNER JOIN PEDID_DATE PDT ON P1.ID_PEDIDO=PDT.ID_PEDIDO
    WHERE PROCODIGO='PAP'),
  
  PED_PROMO_PLUGIN AS 
  (SELECT ID_PEDIDPROMOCAO ID_PEDIDO_PROMO 
    FROM PEDIDPROMO P2
     INNER JOIN PEDID_DATE PDT ON P2.ID_PEDIDPROMOCAO=PDT.ID_PEDIDO),
    
PED_PROMO_CONECTA AS (SELECT P3.ID_PEDIDO ID_PEDIDO_PROMO 
                               FROM PDINFOPROMO P3
                                INNER JOIN PEDID_DATE PDT ON P3.ID_PEDIDO=PDT.ID_PEDIDO
                                 WHERE PIPPAR=2)
                                 
SELECT DISTINCT ID_PEDIDO_PROMO ID_PEDIDO
                          FROM PED_PROMO_PAP UNION
                           SELECT  DISTINCT ID_PEDIDO_PROMO ID_PEDIDO
                            FROM PED_PROMO_PLUGIN UNION
                             SELECT  DISTINCT ID_PEDIDO_PROMO ID_PEDIDO
                              FROM PED_PROMO_CONECTA
