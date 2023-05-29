execute block
returns(
 Procodigo varchar(14)
 ,Prodescricao varchar(50)
,ProUn varchar(3)
 ,Saldo numeric(15,6)
 ,CustoMedio numeric(15,7)
,CustoMedioNovo numeric(15,7)
)
as
 declare variable sProcodigo varchar(14);
 declare variable sProdescricao varchar(50);
 declare variable nSaldo numeric(15,6);
 declare variable nCustoMedio numeric(15,7);
 declare variable nSaldoCustoMedio numeric(15,6);
 declare variable nQtd integer;
 declare variable sProUn varchar(3);
begin
 for
 select p.procodigo, substring(p.prodescricao from 1 for 50), p.proun from produ p
 where p.procodigo is not null
and p.ProSituacao = 'A'
 and p.ProTipo <> 'R'
 and p.ProCodigo IN  ('BOG70250')
 and p.proctrest = 'S'
 order by p.procodigo
 into :sprocodigo, :sprodescricao, :sproun do
 begin
 execute procedure apuracustomedioestoque('[1]',1,:sprocodigo, '05/18/2023', 'N')
 returning_values :ncustomedio, :nsaldocustomedio;
 if ( :nsaldocustomedio > 0 ) then
 begin
 procodigo = :sprocodigo;
 prodescricao = :sprodescricao;
 proun = :sproun;
 saldo = :nsaldocustomedio;
 customedio = :ncustomedio;
 customedionovo = 0;
 suspend;
end
 end
end
