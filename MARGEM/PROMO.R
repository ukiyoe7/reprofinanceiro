## PROMO EM DOBRO MODEL
## SANDRO JAKOSKA
## 06.2023


## LOAD =============================================================

library(DBI)
library(tidyverse)
library(readr)
library(clipr)
library(glue)

con2 <- dbConnect(odbc::odbc(), "reproreplica")


## MEU 1 varilux ================================================

## pedidos
query_promo2 <- dbGetQuery(con2, statement = read_file('MARGEM/PROMO2.sql'))

View(query_promo2)




ped_1_vlx <- read.table(text = read_clip(), header = TRUE, sep = "\t",colClasses = c("character")) %>% 
  rename(ID_PEDIDO=1) %>% mutate(ID_PEDIDO=as.integer(ID_PEDIDO))

View(ped_1_vlx)


query_pedidos_min2 <- dbGetQuery(con2,"
                                        WITH PED AS (
                                        SELECT ID_PEDIDO,PEDDTEMIS,PEDVRTOTAL FROM PEDID
                                           WHERE PEDDTEMIS BETWEEN '01.01.2023' AND '31.05.2023' AND PEDSITPED<>'C')
                                        
                                        SELECT 
                                        PD.ID_PEDIDO,
                                        PEDDTEMIS,
                                        PROCODIGO,
                                        SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                                        FROM PDPRD PD
                                        INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                        GROUP BY 1,2,3
                                        ")


inner_join(query_pedidos_min2,ped_1_vlx,by="ID_PEDIDO") %>% View()


## view pap


query_pedidos_pap <- dbGetQuery(con2,"
                                        WITH PED AS (
                                        SELECT ID_PEDIDO,PEDDTEMIS,PEDVRTOTAL FROM PEDID
                                           WHERE PEDDTEMIS BETWEEN '01.01.2023' AND '31.05.2023' AND PEDSITPED<>'C'),
                                           
                                        PROD AS (SELECT PROCODIGO FROM PRODU WHERE PROCODIGO='PAP') 
                                        
                                        SELECT 
                                        PD.ID_PEDIDO,
                                        PEDDTEMIS,
                                        PD.PROCODIGO,
                                        SUM(PDPUNITLIQUIDO*PDPQTDADE)VRVENDA
                                        FROM PDPRD PD
                                        INNER JOIN PED P ON PD.ID_PEDIDO=P.ID_PEDIDO
                                        INNER JOIN PROD PR ON PR.PROCODIGO=PD.PROCODIGO
                                        GROUP BY 1,2,3
                                        ")

View(query_pedidos_pap)


anti_join(
  query_pedidos_pap,
  inner_join(query_pedidos_min2,ped_1_vlx,by="ID_PEDIDO"),by="ID_PEDIDO") %>% View()

