
         

                                
EXECUTE BLOCK RETURNS ( 
                        ID_PEDIDO INT,
                        CLICODIGO INT,
                        PEDCODIGO VARCHAR(30))
  
  AS DECLARE VARIABLE PEDIDO VARCHAR(30);
      DECLARE VARIABLE CLI INT;
  
  BEGIN
  FOR
  
SELECT DISTINCT 
                            REPLACE(PEDCODIGO,'.001','.000') PEDIDO,
                            CLICODIGO CLI
                             FROM PEDID P WHERE 

PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023'


  INTO :PEDIDO ,:CLI
  DO
  BEGIN
  FOR
  
  
SELECT DISTINCT ID_PEDIDO,CLICODIGO,PEDCODIGO FROM PEDID WHERE PEDCODIGO=:PEDIDO AND CLICODIGO=:CLI
AND 

PEDDTEMIS BETWEEN '01.04.2023' AND '30.04.2023'

  
  INTO :ID_PEDIDO,:CLICODIGO,:PEDCODIGO
  
  DO BEGIN
  
  SUSPEND;
  
  END
  END
  END
  
