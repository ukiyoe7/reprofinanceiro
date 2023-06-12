
## LOAD =============================================================

library(DBI)
library(tidyverse)
library(readr)

con2 <- dbConnect(odbc::odbc(), "reproreplica")


## VIEWS ================================================

query_ped <- dbGetQuery(con2, statement = read_file('MARGEM/PEDIDOS.sql'))

View(query_ped)

query_ped %>% summarize(v=sum(VRVENDA))

query_compo <- dbGetQuery(con2, statement = read_file('MARGEM/COMPOSICAO.sql'))
View(query_compo)

query_compo %>% .[duplicated(.$ID_PEDIDO),]

query_promo <- dbGetQuery(con2, statement = read_file('MARGEM/PROMO.sql')) %>% 
                 mutate(PAR_PROMO=1)

View(query_promo)

## JOINS  ================================================

margem <-
left_join(query_ped,query_promo,by="ID_PEDIDO") %>% 
   left_join(.,query_compo,by="ID_PEDIDO")

View(margem)




