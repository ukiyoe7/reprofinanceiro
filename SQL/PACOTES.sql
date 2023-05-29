WITH FIS AS (SELECT FISCODIGO FROM TBFIS WHERE FISTPNATOP IN ('V','R','SR')),
    
    PED AS (SELECT ID_PEDIDO,
                    PEDCODIGO,
                     REPLACE(PEDCODIGO,'.001','.000') PEDIDO_REL,
                      CLICODIGO,
                       PEDDTEMIS,
                        PEDDTBAIXA
                            FROM PEDID P
                             INNER JOIN FIS ON P.FISCODIGO1=FIS.FISCODIGO
                               WHERE PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023' AND PEDSITPED<>'C' ),
                               
    PROD AS (SELECT PROCODIGO,IIF(PROCODIGO2 IS NULL,PROCODIGO,PROCODIGO2)CHAVE,PROTIPO FROM PRODU WHERE PROSITUACAO='A'
     AND PROTIPO IN ('F','P')),                        
                               
PED_REL AS (                              
  SELECT PD.ID_PEDIDO
             FROM PEDID PD
              INNER JOIN PED PE ON PD.PEDCODIGO=PE.PEDIDO_REL AND PD.CLICODIGO=PE.CLICODIGO)
              
SELECT PD.ID_PEDIDO,
        PROCODIGO
         FROM PDPRD PD
          INNER JOIN PED_REL PE ON PD.ID_PEDIDO=PE.ID_PEDIDO
              