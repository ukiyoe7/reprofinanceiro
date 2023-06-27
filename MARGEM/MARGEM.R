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



## preco medio
query_preco_medio <- dbGetQuery(con2, statement = read_file('MARGEM/PREMP.sql'))



##control
query_control <- dbGetQuery(con2, statement = read_file('MARGEM/CONTROL.sql'))


#produto

query_produto <- dbGetQuery(con2, statement = read_file('MARGEM/PRODUTO.sql'))

## PROMO  ================================================

query_promo2 <- dbGetQuery(con2, statement = read_file('MARGEM/PROMO2.sql')) %>% 
  mutate(CUPOM = str_extract(CUPOM, "\\b\\d\\w{9}\\b"))

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


## LENTES PRODUZIDAS  ================================================


pedidos_LP <- dbGetQuery(con2, statement = read_file('MARGEM/COMPOSICAO.sql'))


corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  


pedidos_LP2 <- 
inner_join(pedidos_LP,query_ped %>% filter(PROTIPO %in% c('P','F','E')) %>% ## JOIN
             distinct(ID_PEDIDO,CHAVE),by="ID_PEDIDO") %>%  .[,corder]


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


## CONTROL ================================================

pedidos_control <- 
  left_join(query_control,query_compo,by=c("PCONTROL"="ID_PEDIDO")) 




pedidos_control2 <- pedidos_control %>% 
  select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)



corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  


pedidos_control3 <- 
  left_join(pedidos_control2,query_ped %>% ## JOIN
              filter(PROTIPO %in% c('P','F','E')) %>% 
              distinct(ID_PEDIDO,CHAVE),by="ID_PEDIDO") %>%  ## JOIN
               filter(!str_detect(CHAVE,"LA")) %>% 
                filter(!is.na(MATERIA_PRIMA_CHAVE)) %>% 
                .[,corder]




pedidos_control3 %>% .[duplicated(.$ID_PEDIDO),]

## PACOTES ================================================


query_pedidos_pacotes <- dbGetQuery(con2, statement = read_file('MARGEM/PEDIDOS_PACOTES.sql'))



query_pedidos_min <- dbGetQuery(con2,"SELECT ID_PEDIDO ID_PEDIDO_REL,PEDCODIGO PEDIDO_REL,CLICODIGO FROM PEDID
                                           WHERE PEDDTEMIS BETWEEN '01.01.2023' AND 'TODAY'")



query_pedidos_pacotes_inner <-
   inner_join(query_pedidos_min,query_pedidos_pacotes, by=c("PEDIDO_REL","CLICODIGO")) ## JOIN




pedidos_pacotes <-
left_join(query_pedidos_pacotes_inner,query_compo,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) %>% ## JOIN
  filter(!is.na(MATERIA_PRIMA_CHAVE)) 

pedidos_pacotes2 <- pedidos_pacotes %>% 
  select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)
   
  

  
  corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  
  

pedidos_pacotes3 <- 
left_join(pedidos_pacotes2,query_ped %>% 
            filter(PROTIPO %in% c('P','F','E')) %>% 
             distinct(ID_PEDIDO,CHAVE),by="ID_PEDIDO")  %>% .[,corder] 

  


## PACOTES CONTROL ================================================


pedidos_pacotes_control <-
  left_join(query_pedidos_pacotes_inner,query_compo,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) %>% ## JOIN
  filter(is.na(MATERIA_PRIMA_CHAVE)) %>%  .[,c(1,2,3,4)]



  
  query_pedidos_control <- dbGetQuery(con2, statement = read_file('MARGEM/PEDIDOS_PACOTES_CONTROL.sql'))
  

  
  pedidos_pacotes_control2 <-  
  pedidos_pacotes_control %>% 
    left_join(.,query_pedidos_control,by=c("ID_PEDIDO_REL"="ID_PEDIDO")) ## JOIN
  

  
  pedidos_pacotes_control3 <-
  pedidos_pacotes_control2 %>% left_join(.,query_compo,by=c("ID_PEDIDO_CONTROL"="ID_PEDIDO")) %>% ## JOIN
    filter(!is.na(MATERIA_PRIMA_CHAVE)) %>% select(ID_PEDIDO,MATERIA_PRIMA_CHAVE,CUSTO_MEDIO,MP_QTD)
    
  

  
  corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  
  
  pedidos_pacotes_control4 <- 
    left_join(pedidos_pacotes_control3,query_ped %>% ## JOIN
                filter(PROTIPO %in% c('P','F','E')) %>% 
                 distinct(ID_PEDIDO,CHAVE),by="ID_PEDIDO") %>% .[,corder]
  
  
## PROFOG EXTERNO ================================================
  
  corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")  
  
  pedidos_profog <- 
    query_ped %>% filter(substr(CHAVE,1,4)=='TROP') %>% select(ID_PEDIDO)
  
  View(pedidos_profog)
  
  pedidos_profog2 <-  
   query_ped %>% inner_join(.,pedidos_profog,by="ID_PEDIDO") %>% 
    filter(PROTIPO %in% c('P','F','E')) %>% 
     left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN
      rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
       select(ID_PEDIDO,CHAVE,CUSTO_MEDIO,QTD) %>% 
        mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>% 
         rename(MP_QTD=QTD) %>%  .[,corder] 
  
  View(pedidos_profog2)

## SERVICOS ===========================================================    


  
## TRATAMENTOS ================================================

  
corder <- c("ID_PEDIDO","CHAVE","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO")      
    
pedidos_trat <-  
query_ped %>% filter(PROTIPO=='T') %>% 
  select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
  left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN 
  rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
  group_by(ID_PEDIDO,CHAVE) %>% 
  summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
  mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>%  
  rename(MP_QTD=QTD) %>% .[,corder] 
  
  
  View(pedidos_trat)
  
  
## MONTAGENS ================================================
  
  pedidos_mont <-  
    query_ped %>% filter(PROTIPO=='M') %>% 
    select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN 
    rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
    group_by(ID_PEDIDO,CHAVE) %>% 
    summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
    mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>%  
    rename(MP_QTD=QTD) %>% .[,corder] 
  
  View(pedidos_mont)  
  

## SERVICOS DIVERSOS ================================================


  pedidos_serv_div <-  
    query_ped %>% filter(PROTIPO=='X') %>% 
    select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN 
    rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
    group_by(ID_PEDIDO,CHAVE) %>% 
    summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
    mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>%  
    rename(MP_QTD=QTD) %>% .[,corder] 
  
  View(pedidos_serv_div)    

  
## SERVICOS INSUMO ================================================
  
  
  
  pedidos_insumos <-  
    query_ped %>% filter(PROTIPO=='W') %>% 
  select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN 
    rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
    group_by(ID_PEDIDO,CHAVE) %>% 
    summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
    mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>%  
    rename(MP_QTD=QTD) %>% .[,corder] 
  
  View(pedidos_insumos)   
  
  
## COLORACAO ================================================


  pedidos_color <-  
    query_ped %>% filter(PROTIPO=='C') %>% 
    select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN 
    rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
    group_by(ID_PEDIDO,CHAVE) %>% 
    summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
    mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>%  
    rename(MP_QTD=QTD) %>% .[,corder] 
  
  View(pedidos_color)  
  

## SERVICOS ================================================
  
  pedidos_serv <-  
    query_ped %>% filter(PROTIPO=='S') %>% 
    select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN 
    rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
    group_by(ID_PEDIDO,CHAVE) %>% 
    summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
    mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>%  
    rename(MP_QTD=QTD) %>% .[,corder] 
  
  View(pedidos_serv)    
  
## DIVERSOS ================================================

  pedidos_div <-  
    query_ped %>% filter(PROTIPO=='K') %>% 
    select(ID_PEDIDO,PROCODIGO,CHAVE,QTD) %>% 
    left_join(.,query_preco_medio,by="PROCODIGO") %>% ## JOIN 
    rename(CUSTO_MEDIO=PREPCOMEDIO) %>% 
    group_by(ID_PEDIDO,CHAVE) %>% 
    summarize(QTD=sum(QTD),CUSTO_MEDIO=mean(CUSTO_MEDIO)) %>% 
    mutate(MATERIA_PRIMA_CHAVE=CHAVE) %>%  
    rename(MP_QTD=QTD) %>% .[,corder] 
  
  View(pedidos_div) 
  
## JOIN LENTES ================================================

pedidos_mp <-    
 rbind(pedidos_LA,
       pedidos_LP2,
        pedidos_prod_ext,
         pedidos_blocos,
         pedidos_control3,
          pedidos_pacotes3,
           pedidos_pacotes_control4,
            pedidos_profog2)  
  

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


pedidos2 <-  
left_join(pedidos,pedidos_mp,by=c("ID_PEDIDO","CHAVE")) ## JOIN


pedidos_lentes <-
  pedidos2 %>% filter(PROTIPO %in% c('F','E','P')) %>% 
                 filter(GRUPO1!='ACESSORIOS') %>% 
                     left_join(.,query_promo2,by="ID_PEDIDO") %>% ## JOIN PROMO
                       left_join(.,query_produto,by=c("CHAVE"="PROCODIGO")) ## JOIN
        


pedidos_lentes %>% .[duplicated(.$ID_PEDIDO),] %>% View()


View(pedidos_lentes %>% filter(is.na(MATERIA_PRIMA_CHAVE))) 

## JOIN SERVIÇOS ==========================================

## merge all
servicos_preco_med <-    
               rbind(pedidos_trat,
                  pedidos_mont,
                     pedidos_serv_div,
                         pedidos_insumos,
                            pedidos_color,
                               pedidos_serv,
                                   pedidos_div) 

View(servicos_preco_med)

# join pedidos
servicos_insumos <-
inner_join(pedidos,servicos_preco_med,by=c("ID_PEDIDO","CHAVE")) %>% 
  left_join(.,query_produto,by=c("CHAVE"="PROCODIGO")) ## JOIN

View(servicos_insumos)
                            

## union FINAL ======================================================

pedidos_union <- union_all(pedidos_lentes,servicos_insumos) %>% ## JOIN
  mutate(CHAVE=str_trim(CHAVE),MATERIA_PRIMA_CHAVE=str_trim(MATERIA_PRIMA_CHAVE))

## ordem das colunas

col_order <-
  c("COD_CLIENTE","CLIRAZSOCIAL","COD_GRUPO","NOME_GRUPO","ID_PEDIDO","CFOP","PEDDTBAIXA","CHAVE","DESCRICAO_CHAVE","PROUN","MARCA","GRUPO1","PROTIPO","QTD","VRVENDA","ICMS","PIS","COFINS","VRVENDA_LIQUIDA","MATERIA_PRIMA_CHAVE","MP_QTD","CUSTO_MEDIO","DESCRICAO_PROMO","CUPOM")

pedidos_union2 <- pedidos_union %>% .[,col_order]


View(pedidos_union2)


pedidos_union2 %>% 
   as.data.frame() %>%  
    summarize(VRVENDA=sum(VRVENDA))



## write csv ==================================================

write.csv2(pedidos_union2,file = "C:\\Users\\Repro\\Documents\\FINANCEIRO\\MARGEM\\pedidos.csv",row.names = FALSE)







