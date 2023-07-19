## EXTRACAO DE BASE PARA CALCULO DE MARGEM
## SANDRO JAKOSKA
## VERSAO SOMENTE SQL
## 06.2023


## LOAD =============================================================

library(DBI)
library(tidyverse)
library(readr)
library(lubridate)
library(stringr)

con2 <- dbConnect(odbc::odbc(), "reproreplica",encoding = "latin1")


## VIEWS ================================================

query_margem <- dbGetQuery(con2, statement = read_file('MARGEMv2/MARGEMv1.sql'))

View(query_margem )
