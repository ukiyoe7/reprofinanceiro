-- 

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
                               WHERE PEDDTBAIXA >=DATEADD(-90 DAY TO CURRENT_DATE) AND PEDSITPED<>'C'),


      PROD AS (SELECT PROCODIGO,
                        PROUN,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,
                         MARNOME MARCA,
                          PROTIPO,
                           GR1DESCRICAO GRUPO1
                           FROM PRODU P
                            LEFT JOIN MARCA M ON M.MARCODIGO=P.MARCODIGO
                             LEFT JOIN GRUPO1 G1 ON G1.GR1CODIGO=P.GR1CODIGO)

      SELECT PD.ID_PEDIDO,
              PD.FISCODIGO CFOP,
               CLICODIGO COD_CLIENTE,
                CLIRAZSOCIAL,                
                 GCLCODIGO COD_GRUPO,
                  GCLNOME NOME_GRUPO,
                   PEDDTBAIXA,
                    PD.PROCODIGO,
                     CHAVE,
                      PDPDESCRICAO DESCRICAO,
                       PROUN,
                        MARCA,
                         GRUPO1,
                          PROTIPO,
                           PDPVRICMS,
                            PDPVRPIS,
                             PDPVRCOFINS,
                           SUM(PDPQTDADE)QTD,
                            SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA,
                             (SUM(PDPUNITLIQUIDO*PDPQTDADE)-PDPVRICMS-PDPVRPIS-PDPVRCOFINS)VRVENDA_LIQUIDA
                                FROM PDPRD PD
                                 INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                  INNER JOIN FIS ON PD.FISCODIGO=FIS.FISCODIGO
                                   LEFT JOIN PROD PR ON PD.PROCODIGO=PR.PROCODIGO
                                    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
                                   
                                   
                                   