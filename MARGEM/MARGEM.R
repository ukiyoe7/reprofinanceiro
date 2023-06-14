
## LOAD =============================================================

library(DBI)
library(tidyverse)
library(readr)

con2 <- dbConnect(odbc::odbc(), "reproreplica")


## VIEWS ================================================

## pedidos
query_ped <- dbGetQuery(con2, statement = read_file('MARGEM/PEDIDOS.sql'))

View(query_ped)

query_ped %>% summarize(v=sum(VRVENDA))

## composicao

query_compo_full <- dbGetQuery(con2, statement = read_file('MARGEM/COMPOSICAO_FULL.sql'))
View(query_compo_full)


## promo
query_promo <- dbGetQuery(con2, statement = read_file('MARGEM/PROMO.sql')) %>% 
                 mutate(PAR_PROMO=1)
View(query_promo)

## preco medio
query_preco_medio <- dbGetQuery(con2, statement = read_file('MARGEM/PREMP.sql'))

View(query_preco_medio)

##control
query_control <- dbGetQuery(con2, statement = read_file('MARGEM/CONTROL.sql'))

View(query_control)


## LENTES ACABADAS  ================================================

pedidos_LA <- 
query_ped %>% 
   filter(GRUPO1=="LENTES ACABADAS") %>% select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
     group_by(ID_PEDIDO,CHAVE) %>% summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
       rename(MATERIA_PRIMA_CHAVE=CHAVE) %>% 
         rename(MP_QTD=QTD) %>% .[,c(1,2,4,3)]

View(pedidos_LA)

## LENTES PRODUZIDAS  ================================================


pedidos_LP <- dbGetQuery(con2, statement = read_file('MARGEM/COMPOSICAO.sql'))
View(pedidos_lentes_fabricadas)


pedidos_LP2 <- 
  
inner_join(pedidos_LP,query_ped %>% distinct(ID_PEDIDO),by="ID_PEDIDO") 

View(pedidos_LP2)

## PRODUCAO EXTERNA ================================================

pedidos_prod_ext <- 
  query_ped %>% mutate(GRUPO1=str_trim(GRUPO1)) %>% 
   filter(GRUPO1=="LT PROD. EXTERNA") %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% 
      rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
       select(ID_PEDIDO,PROCODIGO,CUSTO_MEDIO,QTD) %>% 
        rename(MATERIA_PRIMA_CHAVE=PROCODIGO) %>% 
         rename(MP_QTD=QTD)
   

 View(pedidos_prod_ext)


## CONTROL ================================================

pedidos_control <- 
  left_join(query_control,query_compo,by=c("PCONTROL"="ID_PEDIDO")) 


View(pedidos_control)

pedidos_control2 <- pedidos_control %>% 
  select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)

View(pedidos_control2)

## PACOTES ================================================


query_pedidos_pacotes <- dbGetQuery(con2, statement = read_file('MARGEM/PEDIDOS_PACOTES.sql'))

View(query_pedidos_pacotes)

query_pedidos_min <- dbGetQuery(con2,"SELECT ID_PEDIDO ID_PEDIDO_REL,PEDCODIGO PEDIDO_REL,CLICODIGO FROM PEDID
                                           WHERE PEDDTEMIS BETWEEN '01.01.2023' AND 'TODAY'")



query_pedidos_pacotes_inner <-
   inner_join(query_pedidos_min,query_pedidos_pacotes, by=c("PEDIDO_REL","CLICODIGO"))


View(query_pedidos_pacotes_inner)

pedidos_pacotes <-
left_join(query_pedidos_pacotes_inner,query_compo,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) %>% 
  filter(!is.na(MATERIA_PRIMA_CHAVE)) 

pedidos_pacotes2 <- pedidos_pacotes %>% 
  select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)
   
  
  View(pedidos_pacotes2)
  

## PACOTES CONTROL ================================================

pedidos_pacotes_control <-
  left_join(query_pedidos_pacotes_inner,query_compo,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) %>% 
  filter(is.na(MATERIA_PRIMA_CHAVE)) %>%  .[,c(1,2,3,4)]


  View(pedidos_pacotes_control)
  
  query_pedidos_control <- dbGetQuery(con2, statement = read_file('MARGEM/PEDIDOS_PACOTES_CONTROL.sql'))
  
  View(query_pedidos_control)
  
  pedidos_pacotes_control2 <-  
  pedidos_pacotes_control %>% 
    left_join(.,query_pedidos_control,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) 
  
  View(pedidos_pacotes_control2)
  
  pedidos_pacotes_control3 <-
  pedidos_pacotes_control2 %>% left_join(.,query_compo,by=c("ID_PEDIDO_CONTROL"="ID_PEDIDO")) %>% 
    filter(!is.na(MATERIA_PRIMA_CHAVE)) %>% select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)
    
  
  View(pedidos_pacotes_control3)

  
## JOINS  ================================================

pedidos_mp <-    
rbind(pedidos_LA,pedidos_LP2,pedidos_prod_ext,pedidos_control2,pedidos_pacotes2,pedidos_pacotes_control3)  


margem <- query_ped %>% 
    group_by(ID_PEDIDO,
              COD_CLIENTE,
               CLIRAZSOCIAL,
                COD_GRUPO,NOME_GRUPO,PEDDTBAIXA,CHAVE,PROUN,MARCA,GRUPO1,PROTIPO) %>% summarize(VRVENDA=sum(VRVENDA),QTD=sum(QTD))


View(margem)

margem %>% summarize(v=sum(VRVENDA))








