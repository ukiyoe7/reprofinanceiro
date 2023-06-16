## EXTRACAO DE BASE PARA CALCULO DE MARGEM
## SANDRO JAKOSKA
## 06.2023


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

query_ped %>% summarize(v=sum(VRVENDA_LIQUIDA))


## promo
query_promo <- dbGetQuery(con2, statement = read_file('MARGEM/PROMO.sql')) %>% 
                 mutate(PAR_PROMO=1)


## preco medio
query_preco_medio <- dbGetQuery(con2, statement = read_file('MARGEM/PREMP.sql'))



##control
query_control <- dbGetQuery(con2, statement = read_file('MARGEM/CONTROL.sql'))


#produto

query_produto <- dbGetQuery(con2, statement = read_file('MARGEM/PRODUTO.sql'))


## LENTES ACABADAS  ================================================

corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  

pedidos_LA <- 
  query_ped %>% 
   filter(GRUPO1=="LENTES ACABADAS") %>% 
    select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
     left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN 
       rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
        group_by(ID_PEDIDO,CHAVE) %>% 
         summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
          mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>%  
           rename(MP_QTD=QTD) %>% .[,corder]

View(pedidos_LA)

## LENTES PRODUZIDAS  ================================================


pedidos_LP <- dbGetQuery(con2, statement = read_file('MARGEM/COMPOSICAO.sql'))
View(pedidos_lentes_fabricadas)

corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  


pedidos_LP2 <- 
inner_join(pedidos_LP,query_ped %>% filter(PROTIPO %in% c('P','F','E')) %>% ## JOIN
             distinct(ID_PEDIDO,CHAVE),by="ID_PEDIDO") %>%  .[,corder]

View(pedidos_LP2)


## PRODUCAO EXTERNA ================================================

corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  

pedidos_prod_ext <- 
  query_ped %>% mutate(GRUPO1=str_trim(GRUPO1)) %>% 
   filter(GRUPO1=="LT PROD. EXTERNA") %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN
      rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
       select(ID_PEDIDO,CHAVE,CUSTO_MEDIO,QTD) %>% 
        mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>% 
         rename(MP_QTD=QTD) %>%  .[,corder]
   

 View(pedidos_prod_ext)
 
 ## BLOCOS ================================================
 
 corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  
 
 pedidos_blocos <- 
   query_ped %>% mutate(GRUPO1=str_trim(GRUPO1)) %>% 
    filter(GRUPO1=="BLOCOS") %>% 
     left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN
       rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
        group_by(ID_PEDIDO,CHAVE) %>% summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
         select(ID_PEDIDO,CHAVE,CUSTO_MEDIO,QTD) %>% 
          mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>% 
           rename(MP_QTD=QTD) %>%  .[,corder]
 
 
 View(pedidos_blocos)
 

## CONTROL ================================================

pedidos_control <- 
  left_join(query_control,query_compo,by=c("PCONTROL"="ID_PEDIDO")) 


View(pedidos_control)

pedidos_control2 <- pedidos_control %>% 
  select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)

View(pedidos_control2)

corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  


pedidos_control3 <- 
  left_join(pedidos_control2,query_ped %>% ## JOIN
              filter(PROTIPO %in% c('P','F','E')) %>% 
              distinct(ID_PEDIDO,CHAVE),by="ID_PEDIDO") %>%  ## JOIN
               filter(!str_detect(CHAVE,"LA")) %>% 
                filter(!is.na(MATERIA_PRIMA_CHAVE)) %>% 
                .[,corder]


View(pedidos_control3)

pedidos_control3 %>% .[duplicated(.$ID_PEDIDO),]

## PACOTES ================================================


query_pedidos_pacotes <- dbGetQuery(con2, statement = read_file('MARGEM/PEDIDOS_PACOTES.sql'))

View(query_pedidos_pacotes)

query_pedidos_min <- dbGetQuery(con2,"SELECT ID_PEDIDO ID_PEDIDO_REL,PEDCODIGO PEDIDO_REL,CLICODIGO FROM PEDID
                                           WHERE PEDDTEMIS BETWEEN '01.01.2023' AND 'TODAY'")



query_pedidos_pacotes_inner <-
   inner_join(query_pedidos_min,query_pedidos_pacotes, by=c("PEDIDO_REL","CLICODIGO")) ## JOIN


View(query_pedidos_pacotes_inner)

pedidos_pacotes <-
left_join(query_pedidos_pacotes_inner,query_compo,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) %>% ## JOIN
  filter(!is.na(MATERIA_PRIMA_CHAVE)) 

pedidos_pacotes2 <- pedidos_pacotes %>% 
  select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)
   
  
  View(pedidos_pacotes2)
  
  corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  
  

pedidos_pacotes3 <- 
left_join(pedidos_pacotes2,query_ped %>% 
            filter(PROTIPO %in% c('P','F','E')) %>% 
             distinct(ID_PEDIDO,CHAVE),by="ID_PEDIDO")  %>% .[,corder] 

  
View(pedidos_pacotes3)

## PACOTES CONTROL ================================================


pedidos_pacotes_control <-
  left_join(query_pedidos_pacotes_inner,query_compo,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) %>% ## JOIN
  filter(is.na(MATERIA_PRIMA_CHAVE)) %>%  .[,c(1,2,3,4)]


  View(pedidos_pacotes_control)
  
  query_pedidos_control <- dbGetQuery(con2, statement = read_file('MARGEM/PEDIDOS_PACOTES_CONTROL.sql'))
  
  View(query_pedidos_control)
  
  pedidos_pacotes_control2 <-  
  pedidos_pacotes_control %>% 
    left_join(.,query_pedidos_control,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) ## JOIN
  
  View(pedidos_pacotes_control2)
  
  pedidos_pacotes_control3 <-
  pedidos_pacotes_control2 %>% left_join(.,query_compo,by=c("ID_PEDIDO_CONTROL"="ID_PEDIDO")) %>% ## JOIN
    filter(!is.na(MATERIA_PRIMA_CHAVE)) %>% select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)
    
  
  View(pedidos_pacotes_control3)
  
  corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  
  
  pedidos_pacotes_control4 <- 
    left_join(pedidos_pacotes_control3,query_ped %>% ## JOIN
                filter(PROTIPO %in% c('P','F','E')) %>% 
                 distinct(ID_PEDIDO,CHAVE),by="ID_PEDIDO") %>% .[,corder]
  
  
  View(pedidos_pacotes_control4)
  


  
## JOINS  ================================================

pedidos_mp <-    
rbind(pedidos_LA,
       pedidos_LP2,
        pedidos_prod_ext,
         pedidos_blocos,
         pedidos_control3,
          pedidos_pacotes3,
           pedidos_pacotes_control4)  

View(pedidos_mp)  


  pedidos_mp %>% .[duplicated(.$ID_PEDIDO),]
  

pedidos <- query_ped %>% 
            group_by(ID_PEDIDO,
             CFOP,
              COD_CLIENTE,
                CLIRAZSOCIAL,
                 COD_GRUPO,
                   NOME_GRUPO,
                    PEDDTBAIXA,
                     CHAVE,
                      PROUN,
                       MARCA,
                        GRUPO1,
                         PROTIPO) %>% 
                          summarize(ICMS=sum(PDPVRICMS),
                                     PIS=sum(PDPVRPIS),
                                      COFINS=sum(PDPVRCOFINS),
                                       VRVENDA_LIQUIDA=sum(VRVENDA_LIQUIDA), 
                                        VRVENDA=sum(VRVENDA),
                                         QTD=sum(QTD))

view(pedidos)
  

pedidos2 <-  
left_join(pedidos,pedidos_mp,by=c("ID_PEDIDO","CHAVE")) ## JOIN

View(pedidos2)

pedidos_lentes <-
  pedidos2 %>% filter(PROTIPO %in% c('F','E','P')) %>% 
                filter(GRUPO1!='ACESSORIOS') %>% 
                 left_join(.,query_promo,by="ID_PEDIDO") %>% ## JOIN
                   left_join(.,query_produto,by=c("CHAVE"="PROCODIGO")) ## JOIN
                 

pedidos_lentes %>% as.data.frame() %>% filter(!is.na(MATERIA_PRIMA_CHAVE)) %>% summarize(v=sum(VRVENDA))

View(pedidos_lentes)

query_ped %>% mutate(GRUPO1 = as.factor(GRUPO1)) %>%
  pull(GRUPO1) %>%
  levels()


pedidos_lentes %>% .[duplicated(.$ID_PEDIDO),] %>% View()

View(pedidos_lentes %>% filter(is.na(MATERIA_PRIMA_CHAVE))) 

## servicos

pedidos_servicos <- query_ped %>% 
              filter(GRUPO1 %in% c('SERVI\xc7OS','ACESSORIOS','DIVERSOS','INSUMOS','SERV. DIVERSOS','SERV. DIVERSOS')) %>% 
               group_by(ID_PEDIDO,
                CFOP,        
                COD_CLIENTE,
                 CLIRAZSOCIAL,
                  COD_GRUPO,
                   NOME_GRUPO,
                    PEDDTBAIXA,
                     CHAVE,
                      PROUN,
                       MARCA,
                        GRUPO1,
                         PROTIPO) %>% 
                          summarize(ICMS=sum(PDPVRICMS),
                           PIS=sum(PDPVRPIS),
                            COFINS=sum(PDPVRCOFINS),
                             VRVENDA_LIQUIDA=sum(VRVENDA_LIQUIDA), 
                              VRVENDA=sum(VRVENDA),
                               QTD=sum(QTD)) %>% 
                           
mutate(MATERIA_PRIMA_CHAVE='',MP_QTD=as.numeric(''),CUSTO_MEDIO=as.numeric('')) %>% left_join(.,query_promo,by="ID_PEDIDO") %>% 
  left_join(.,query_produto,by=c("CHAVE"="PROCODIGO")) 
                            


## ordem das colunas

col_order <-
  c("ID_PEDIDO","CFOP","COD_CLIENTE","CLIRAZSOCIAL","COD_GRUPO","NOME_GRUPO","PEDDTBAIXA","CHAVE","DESCRICAO_CHAVE","PROUN","MARCA","GRUPO1","PROTIPO","VRVENDA","QTD","ICMS","PIS","COFINS","VRVENDA_LIQUIDA","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO","PAR_PROMO")

pedidos_lentes2 <- pedidos_lentes %>% .[,col_order]

pedidos_servicos2 <- pedidos_servicos %>% .[,col_order]


## union

pedidos_union <- union_all(pedidos_lentes2,pedidos_servicos2) %>% ## JOIN
  mutate(CHAVE=str_trim(CHAVE),MATERIA_PRIMA_CHAVE=str_trim(MATERIA_PRIMA_CHAVE))

View(pedidos_union)

pedidos_union %>% 
   as.data.frame() %>%  
    summarize(VRVENDA=sum(VRVENDA),VRVENDA=sum(VRVENDA_LIQUIDA))

## write csv

write.csv2(pedidos_union
             ,file = "C:\\Users\\Repro\\Documents\\FINANCEIRO\\MARGEM\\pedidos.csv",row.names = FALSE)

## summary

query_ped %>%  
  filter(PROTIPO %in% c('F','E','P')) %>% 
   filter(GRUPO1!='ACESSORIOS') %>%  
     summarize(VRVENDA=sum(VRVENDA),QTD=sum(QTD))


query_ped %>%  
  summarize(VRVENDA=sum(VRVENDA))





