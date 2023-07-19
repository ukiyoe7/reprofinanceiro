WITH 
                               
   FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
   
   CLI AS (SELECT C.CLICODIGO,
                   CLIRAZSOCIAL,                
                    C.GCLCODIGO,
                     GCLNOME
                      FROM CLIEN C
                       LEFT JOIN GRUPOCLI GR ON C.GCLCODIGO=GR.GCLCODIGO),
    
    PED AS (SELECT ID_PEDIDO,
                    P.CLICODIGO,
                     CLIRAZSOCIAL,                
                      C.GCLCODIGO,
                       GCLNOME,
                        PEDDTBAIXA
                            FROM PEDID P
                              LEFT JOIN CLI C ON P.CLICODIGO=C.CLICODIGO
                               WHERE PEDDTBAIXA >=DATEADD(-1 DAY TO CURRENT_DATE) AND PEDSITPED<>'C'),


      PROD AS (SELECT PROCODIGO,
                        PROUN,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,
                         MARNOME MARCA,
                          PROTIPO,
                           GR1DESCRICAO GRUPO1
                           FROM PRODU P
                            LEFT JOIN MARCA M ON M.MARCODIGO=P.MARCODIGO
                             LEFT JOIN GRUPO1 G1 ON G1.GR1CODIGO=P.GR1CODIGO),
                             
--------- CONTROL                            
                             
CONTROL  AS(
SELECT A.ID_PEDIDO,MAX(APCODIGO)APCODIGO FROM ACOPED A
            INNER JOIN PED P ON A.ID_PEDIDO=P.ID_PEDIDO WHERE LPCODIGO=1837 
              GROUP BY 1),

CONTROL2 AS(
SELECT A.ID_PEDIDO,CAST(REPLACE(APOBS,'Pedido ID: ','') AS INT) PCONTROL FROM ACOPED A
            INNER JOIN CONTROL C 
             ON A.ID_PEDIDO=C.ID_PEDIDO AND A.APCODIGO=C.APCODIGO)                             
                             
CONTROL3 AS (
      SELECT PD.ID_PEDIDO,
                    PD.PROCODIGO,
                      PDPDESCRICAO,
                           SUM(PDPQTDADE)QTD,
                            SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                                FROM PDPRD PD
                                 INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                  INNER JOIN FIS ON PD.FISCODIGO=FIS.FISCODIGO
                                   INNER JOIN CONTROL2 C2 ON PD.ID_PEDIDO=C2.ID_PEDIDO
                                   LEFT JOIN PROD PR ON PD.PROCODIGO=PR.PROCODIGO
                                    GROUP BY 1,2,3)
                                    
SELECT                                     
                                    
                                   