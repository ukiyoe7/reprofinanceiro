

library(DBI)
library(tidyverse)
library(readr)
library(googlesheets4)

con2 <- dbConnect(odbc::odbc(), "reproreplica")

con3 <- dbConnect(odbc::odbc(), "repro_prod", timeout = 10)


query_mp_ccust <- dbGetQuery(con2, statement = read_file('SQL/CUSTO_MEDIO_MP.sql'))

View(query_mp_ccust)


query_mp <- dbGetQuery(con2, statement = read_file('SQL/MP2.sql'))

View(query_mp)

query_mp %>% distinct(PEDIDO) %>% tally()

query_ped <- dbGetQuery(con2, statement = read_file('SQL/PEDIDOS.sql'))

View(query_ped)

query_prcd <- dbGetQuery(con3, statement = read_file('SQL/TEST_PROCEDURE.sql'))

View(query_prcd)

query_ctrl <- dbGetQuery(con3, statement = read_file('SQL/CONTROL_MP.sql'))

View(query_ctrl)

## PACOTES

query_pct <- dbGetQuery(con2, statement = read_file('SQL/PACOTES2.sql'))

View(query_pct)

query_pct3 <- dbGetQuery(con2, statement = read_file('SQL/PACOTES3.sql'))

View(query_pct3)

query_model1 <- dbGetQuery(con2, statement = read_file('SQL/DATAMODEL1.sql'))

View(query_model1)

# LA

query_lamp <- dbGetQuery(con2, statement = read_file('SQL/LA_MP.sql'))

View(query_lamp)


query_lamp %>% group_by(PROTIPO) %>% summarize(n=n_distinct(ID_PEDIDO))



# MP

query_fbmp <- dbGetQuery(con2, statement = read_file('SQL/FB_MP.sql'))

View(query_fbmp)


query_fbmp %>% filter(!is.na(PCONTROL))  %>%  View()


# CTRL

query_ctrl <- dbGetQuery(con2, statement = read_file('SQL/CRTL_MP.sql'))

View(query_ctrl)


query_fbmp %>% filter(!is.na(PCONTROL))  %>%  View()

