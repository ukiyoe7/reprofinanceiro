
## LOAD =============================================================

library(DBI)
library(tidyverse)
library(readr)
library(googlesheets4)

con2 <- dbConnect(odbc::odbc(), "reproreplica")

con3 <- dbConnect(odbc::odbc(), "repro_prod", timeout = 10)

## VIEWS ================================================

query_ped <- dbGetQuery(con2, statement = read_file('SQL/PEDIDOS.sql'))

View(query_ped)

query_premp <- dbGetQuery(con2, statement = read_file('SQL/PREMP.sql'))

View(query_premp)


## MAIN ===========================================================


query_custo_medio3 <- dbGetQuery(con2, statement = read_file('SQL/CUSTO_MEDIO_MPv3.sql')) 

query_custo_medio3 <- query_custo_medio3 %>% 
  mutate(PROCODIGO=str_trim(PROCODIGO)) %>%
  mutate(CHAVE=str_trim(CHAVE)) %>% 
  mutate(PDPDESCRICAO=str_trim(PDPDESCRICAO)) %>%
  mutate(MATERIA_PRIMA=str_trim(MATERIA_PRIMA)) %>%
  mutate(MATERIA_PRIMA=str_trim(MATERIA_PRIMA_CHAVE))


View(query_custo_medio3)



# LENTES ACABADAS =========================================


query_lamp <- dbGetQuery(con2, statement = read_file('SQL/LA_MP.sql'))

View(query_lamp)


query_lamp %>% group_by(PROTIPO) %>% summarize(n=n_distinct(ID_PEDIDO))



# FABRICADOS =============================================


query_fbmp <- dbGetQuery(con2, statement = read_file('SQL/FB_MP.sql'))

View(query_fbmp)


query_fbmp %>% filter(!is.na(PCONTROL))  %>%  View()


# CTRL ====================================================

query_ctrl <- dbGetQuery(con2, statement = read_file('SQL/CRTL_MP.sql'))

View(query_ctrl)

query_ctrl %>% filter(is.na(MATERIA_PRIMA))  %>%  View()


query_ctrl <- dbGetQuery(con3, statement = read_file('SQL/CONTROL_MP.sql'))

View(query_ctrl)


query_ctrlv2 <- dbGetQuery(con2, statement = read_file('SQL/CONTROL_MP_v2.sql'))

View(query_ctrlv2)

query_test_temp <- dbGetQuery(con2, statement = read_file('SQL/TEST_TEMP.sql'))

View(query_test_temp)


## PACOTES ===============================================


query_pct <- dbGetQuery(con2, statement = read_file('SQL/PACOTES.sql'))

View(query_pct)


query_pct3 <- dbGetQuery(con2, statement = read_file('SQL/PACOTES3.sql'))

View(query_pct3)


query_model1 <- dbGetQuery(con2, statement = read_file('SQL/DATAMODEL1.sql'))

View(query_model1)



query_pct <- dbGetQuery(con2, statement = read_file('SQL/PCT_MP.sql'))

View(query_pct)


query_pct %>% filter(is.na(MATERIA_PRIMA))  %>%  View()


## DUMP  ===================================


query_mp_ccust <- dbGetQuery(con2, statement = read_file('SQL/CUSTO_MEDIO_MP.sql'))

View(query_mp_ccust)


query_mp <- dbGetQuery(con2, statement = read_file('SQL/MP.sql'))

View(query_mp)


query_prcd <- dbGetQuery(con3, statement = read_file('SQL/TEST_PROCEDURE.sql'))

View(query_prcd)


query_custo_medio <- dbGetQuery(con2, statement = read_file('SQL/CUSTO_MEDIO_MPv2.sql')) 

query_custo_medio <- query_custo_medio %>% 
  mutate(PROCODIGO=str_trim(PROCODIGO)) %>%
   mutate(CHAVE=str_trim(CHAVE)) %>% 
    mutate(PDPDESCRICAO=str_trim(PDPDESCRICAO)) %>%
     mutate(MATERIA_PRIMA=str_trim(MATERIA_PRIMA)) %>%
      mutate(MATERIA_PRIMA=str_trim(MATERIA_PRIMA_CHAVE))
   
  

View(query_custo_medio)

query_custo_medio %>% filter(is.na(MATERIA_PRIMA)) %>% View()




write.csv2(query_custo_medio,file = "C:\\Users\\Repro\\Documents\\FINANCEIRO\\query_custo_medio.csv")


anti_join(query_ped,query_custo_medio3,by="ID_PEDIDO") %>% View()










