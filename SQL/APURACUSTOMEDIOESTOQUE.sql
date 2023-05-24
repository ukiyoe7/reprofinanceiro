begin
   SaldoEstoque  = 0; /* Saldo do estoque para apurar o custo     */
   SaldoEstoqueE = 0; /* Saldo do estoque das empresas informadas */
   VrEstoque     = 0;
   VrTotal       = 0;
   CustoMedio    = 0;
   CustoMedioForcado = 0; /* Ira registrar o custo medio anterior antes que ele seja zerado */

   --Tarefa 60700
   select produ.protipo, iif (premp.precustoreal = 0 or premp.precustoreal is null, premp.prepcocusto, premp.precustoreal)
   from produ
   left join premp on (premp.procodigo = produ.procodigo and premp.empcodigo = :nemprecusto)
   where produ.procodigo = :sprodu
   into :stipo, :ncustopremp;

   select trim(p.parvalor) from param p
   where p.parnome = 'TPPRODUCUSMEDIOPRE'
   into :tp_produ;

   if ( (tp_produ is not null) and (tp_produ containing stipo) ) then
   begin
    ncusmed = :NCUSTOPREMP;
    nsldest = 0;
   end
   else
   begin
      if ( sorigens = ('[PB][EB]') ) then
       begin

       /* Select que busca o ultimo custo apurado */
            for select c.camdata, c.camcusto, c.camsaldo
            from custoacumuladomovtop c
            where c.camdata < :dData and c.empcodigo = :nemprecusto and
            c.procodigo = :sprodu and camsomachave = :somachave
            order by c.camdata asc
            into :ddatareg, :customedio, saldoestoque do
            begin
                /* Linha apenas para o for Select nao ficar sem instrucao  */
                SaldoEstoqueE = SaldoEstoque;
            end

       end

       if ( sorigens = ('[NS][NE][RQ][TE][PB][EB][EP]') ) then
       begin

       /* Select que busca o ultimo custo apurado */
            for select c.camdata, c.camcusto, c.camsaldo
            from custoacumuladomovtocomb c
            where c.camdata < :dData and c.empcodigo = :nemprecusto and
            c.procodigo = :sprodu and camsomachave = :somachave
            order by c.camdata asc
            into :ddatareg, :customedio, saldoestoque do
            begin
                /* Linha apenas para o for Select nao ficar sem instrucao  */
                SaldoEstoqueE = SaldoEstoque;
            end

       end

       if ( sorigens = ('[NS][NE][RQ][TE][EP]') ) then
       begin

       /* Select que busca o ultimo custo apurado */
            for select c.camdata, c.camcusto, c.camsaldo
            from custoacumuladomovto c
            where c.camdata < :dData and c.empcodigo = :nemprecusto and
            c.procodigo = :sprodu and camsomachave = :somachave
            order by c.camdata asc
            into :ddatareg, :customedio, saldoestoque do
            begin
                /* Linha apenas para o for Select nao ficar sem instrucao  */
                SaldoEstoqueE = SaldoEstoque;
            end

       end
    
                   /* Tarefa 56562 */
       if (CustoMedio > 0) then
         CustoMedioForcado = CustoMedio;
                
                
     /* Select que busca o valor do parametro "CONSIDERADOACAOCUSTO" */
       for select param.parvalor from param
           where param.parnome = 'CONSIDERADOACAOCUSTO'
           into :sConsideraDoacaoCusto do
       begin
         /* Linha apenas para o for Select nao ficar sem instrucao  */
         SaldoEstoqueE = SaldoEstoque;
         if(sConsideraDoacaoCusto = 'S') then
            sfistpnatopdoacao = 'A';
         else
            sfistpnatopdoacao = 'C'; --insere compra so para passar no if abaixo
       end
    
       /* Inicializa o "SaldoEstoqueE" */
       SaldoEstoqueE = SaldoEstoque;
    
       /* Se nao for encontrado nenhum custo apurado gravado, inicializa a data para o inicio da pesquisa de movimento de estoque */
       if ( :ddatareg is null ) then
         ddatareg = '01.01.1900';
    
       if (SomaChave = 'S') then
       begin
                  -- DEFINIR AS ORIGENS
        FOR

          SELECT DISTINCT CAST(O.VALUE_VARCHAR AS VARCHAR(4)) FROM PARSE_VARCHAR(:SORIGENS) O
          INTO :ORIGEM00

        DO
        BEGIN

          IF (:ORIGEM00 NOT IN (:ORIGEM01,:ORIGEM02,:ORIGEM03,:ORIGEM04,:ORIGEM05,:ORIGEM06,:ORIGEM07,:ORIGEM08,:ORIGEM09,:ORIGEM10)) THEN
          BEGIN

            IF (:ORIGEM01 = '????') THEN
              ORIGEM01 = :ORIGEM00;
            ELSE IF (:ORIGEM02 = '????') THEN
              ORIGEM02 = :ORIGEM00;
            ELSE IF (:ORIGEM03 = '????') THEN
              ORIGEM03 = :ORIGEM00;
            ELSE IF (:ORIGEM04 = '????') THEN
              ORIGEM04 = :ORIGEM00;
            ELSE IF (:ORIGEM05 = '????') THEN
              ORIGEM05 = :ORIGEM00;
            ELSE IF (:ORIGEM06 = '????') THEN
              ORIGEM06 = :ORIGEM00;
            ELSE IF (:ORIGEM07 = '????') THEN
              ORIGEM07 = :ORIGEM00;
            ELSE IF (:ORIGEM08 = '????') THEN
              ORIGEM08 = :ORIGEM00;
            ELSE IF (:ORIGEM09 = '????') THEN
              ORIGEM09 = :ORIGEM00;
            ELSE IF (:ORIGEM10 = '????') THEN
              ORIGEM10 = :ORIGEM00;

            QTDORIGEM = :QTDORIGEM -1;

          END

        END

        IF (:QTDORIGEM < 0) THEN
          EXCEPTION FK_PADRAO 'QUANTIDADE DE ORIGENS SUPERIOR AO PERMITIDO PARA APURACAO DO CUSTO MEDIO!';

         -- DEFINIR AS EMPRESAS
        FOR

          SELECT DISTINCT O.VALUE_SMALLINT FROM PARSE_SMALLINT(:SEMPRE) O
          INTO :EMPCODIGO00 DO

        BEGIN

          IF (:EMPCODIGO00 NOT IN (:EMPCODIGO01,:EMPCODIGO02,:EMPCODIGO03,:EMPCODIGO04,:EMPCODIGO05,:EMPCODIGO06,:EMPCODIGO07,:EMPCODIGO08,:EMPCODIGO09,:EMPCODIGO10)) THEN
          BEGIN

            IF (:EMPCODIGO01 = -1) THEN
              EMPCODIGO01 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO02 = -1) THEN
            EMPCODIGO02 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO03 = -1) THEN
            EMPCODIGO03 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO04 = -1) THEN
            EMPCODIGO04 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO05 = -1) THEN
            EMPCODIGO05 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO06 = -1) THEN
            EMPCODIGO06 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO07 = -1) THEN
            EMPCODIGO07 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO08 = -1) THEN
            EMPCODIGO08 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO09 = -1) THEN
            EMPCODIGO09 = :EMPCODIGO00;
          ELSE IF (:EMPCODIGO10 = -1) THEN
            EMPCODIGO10 = :EMPCODIGO00;

          QTDEMPCODIGO = :QTDEMPCODIGO -1;

        END

      END

      IF (:QTDEMPCODIGO < 0) THEN
        EXCEPTION FK_PADRAO 'QUANTIDADE DE EMPRESAS SUPERIOR AO PERMITIDO PARA APURACAO DO CUSTO MEDIO!';

      FOR SELECT MV.DATA, MV.TIPO, MV.QUANTIDADE, coalesce(mv.custoreal,0) CustoReal, MV.EMPCODIGO, MV.FISTPNATOP
          FROM PRODU PR LEFT JOIN MOVIMENTACAO MV ON PR.PROCODIGO = MV.PROCODIGO
          WHERE (PR.PROCODIGO2 =:SPRODU OR PR.PROCODIGO = :SPRODU)
            AND MV.DATA+0 <=:DDATA
            AND MV.LCEST = 'S'
            AND MV.DATA+0 > :DDATAREG
            AND MV.LC_ESTORNO IS NULL
            AND MV.FISTPNATOP NOT IN ('REB', 'EB', 'RB', 'RRB', 'RC', 'RRC', 'REC', 'EC')
            and mv.empcodigo in (:EMPCODIGO01,:EMPCODIGO02,:EMPCODIGO03,:EMPCODIGO04,:EMPCODIGO05,:EMPCODIGO06,:EMPCODIGO07,:EMPCODIGO08,:EMPCODIGO09,:EMPCODIGO10)
            and mv.origem in (:ORIGEM01,:ORIGEM02,:ORIGEM03,:ORIGEM04,:ORIGEM05,:ORIGEM06,:ORIGEM07,:ORIGEM08,:ORIGEM09,:ORIGEM10)
          ORDER BY 1, 2, MV.ID_MOVIMENTACAO
          INTO  DATA, ENTSAI, QTDADE, CUSTO, NEMPCUSTO, SFISTPNATOP DO
      BEGIN
    
         if ( :nEmpCusto = nEmpreCusto ) then
         begin
  
          if (not Qtdade is null) then
          begin
            if (EntSai = 'C') then
            begin
              VrEstoque = cast(SaldoEstoque * CustoMedio as numeric(13,2));
  
              /* Se for natureza de operacao de Doacao e o parametro estiver configurado, zera o custo*/
              if ((sConsideraDoacaoCusto = 'S') and (trim(sfistpnatop) = 'A')) then
              begin
                VrTotal = 0;
              end else
              begin
                VrTotal = cast(Qtdade * Custo as numeric(13,2));
              end  
    
              SaldoEstoque = SaldoEstoque + Qtdade;
              SaldoEstoqueE = SaldoEstoqueE + Qtdade;
              if ( ( trim(sfistpnatop) = 'C' ) or
                   ( trim(sfistpnatop) = 'I' ) or
                   ( trim(sfistpnatop) = 'T' ) or
                   ( trim(sfistpnatop) = sfistpnatopdoacao ) or   /*Doacao ou nao*/
                   ( trim(sfistpnatop) = ''  ) ) then
              begin
                if ((VrEstoque > 0) and (CustoMedio <> 0)) then
                  begin
                    if (((VrEstoque + VrTotal) <> 0)  and (SaldoEstoque <> 0)) then
                      CustoMedio = cast( ((VrEstoque + VrTotal) / SaldoEstoque) as numeric(15,7) );
                  end
                else
                  begin
                    CustoMedio = cast(Custo as numeric(15,7));
                  end
              end
              else
                begin
  
                  CustoMedio = CUSTOMEDIOFORCADO;
  
                end
  
            end
            else if (EntSai = 'D') then
            begin
              SaldoEstoque = SaldoEstoque - Qtdade;
              SaldoEstoqueE = SaldoEstoqueE - Qtdade;
            end
  
            if (CustoMedio > 0) then
              CustoMedioForcado = CustoMedio;
  
            if ( SaldoEstoque <= 0 ) then
              begin
  
                CustoMedio = 0;
  
              end
  
            nCusMed = CustoMedio;
           end
         end else
         begin
  
          if (not Qtdade is null) then
          begin
            if (EntSai = 'C') then
            begin
              SaldoEstoqueE = SaldoEstoqueE + Qtdade;
            end
            else if ( entsai = 'D' ) then
              SaldoEstoqueE = SaldoEstoqueE - Qtdade;
            end
  
         end
  
     end
     nSldEst = SaldoEstoqueE;
     nCusMed = CustoMedio;
    
     if ((nCusMed <= 0.0001) and (nSldEst <= 0.0001)) then
     begin
      nCusMed = CustoMedioForcado;
     end
    
   end
    
   else
   begin
    
     -- DEFINIR AS ORIGENS
     for select distinct
                cast(O.VALUE_VARCHAR as varchar(4))
           from PARSE_VARCHAR(:SORIGENS) O
           into :ORIGEM00 do
     begin

       if (:ORIGEM00 not in (:ORIGEM01,:ORIGEM02,:ORIGEM03,:ORIGEM04,:ORIGEM05,:ORIGEM06,:ORIGEM07,:ORIGEM08,:ORIGEM09,:ORIGEM10)) then
       begin

         if (:ORIGEM01 = '????') then
           ORIGEM01 = :ORIGEM00;
         else if (:ORIGEM02 = '????') then
           ORIGEM02 = :ORIGEM00;
         else if (:ORIGEM03 = '????') then
           ORIGEM03 = :ORIGEM00;
         else if (:ORIGEM04 = '????') then
           ORIGEM04 = :ORIGEM00;
         else if (:ORIGEM05 = '????') then
           ORIGEM05 = :ORIGEM00;
         else if (:ORIGEM06 = '????') then
           ORIGEM06 = :ORIGEM00;
         else if (:ORIGEM07 = '????') then
           ORIGEM07 = :ORIGEM00;
         else if (:ORIGEM08 = '????') then
           ORIGEM08 = :ORIGEM00;
         else if (:ORIGEM09 = '????') then
           ORIGEM09 = :ORIGEM00;
         else if (:ORIGEM10 = '????') then
           ORIGEM10 = :ORIGEM00;

         QTDORIGEM = :QTDORIGEM -1;

       end

     end
     if (:QTDORIGEM < 0) then
       exception FK_PADRAO 'QUANTIDADE DE ORIGENS SUPERIOR AO PERMITIDO PARA APURACAO DO CUSTO MEDIO!';

     -- DEFINIR AS EMPRESAS
     for select distinct
                O.VALUE_SMALLINT
           from PARSE_SMALLINT(:SEMPRE) O
           into :EMPCODIGO00 do
     begin

       if (:EMPCODIGO00 not in (:EMPCODIGO01,:EMPCODIGO02,:EMPCODIGO03,:EMPCODIGO04,:EMPCODIGO05,:EMPCODIGO06,:EMPCODIGO07,:EMPCODIGO08,:EMPCODIGO09,:EMPCODIGO10)) then
       begin

         if (:EMPCODIGO01 = -1) then
           EMPCODIGO01 = :EMPCODIGO00;
         else if (:EMPCODIGO02 = -1) then
           EMPCODIGO02 = :EMPCODIGO00;
         else if (:EMPCODIGO03 = -1) then
           EMPCODIGO03 = :EMPCODIGO00;
         else if (:EMPCODIGO04 = -1) then
           EMPCODIGO04 = :EMPCODIGO00;
         else if (:EMPCODIGO05 = -1) then
           EMPCODIGO05 = :EMPCODIGO00;
         else if (:EMPCODIGO06 = -1) then
           EMPCODIGO06 = :EMPCODIGO00;
         else if (:EMPCODIGO07 = -1) then
           EMPCODIGO07 = :EMPCODIGO00;
         else if (:EMPCODIGO08 = -1) then
           EMPCODIGO08 = :EMPCODIGO00;
         else if (:EMPCODIGO09 = -1) then
           EMPCODIGO09 = :EMPCODIGO00;
         else if (:EMPCODIGO10 = -1) then
           EMPCODIGO10 = :EMPCODIGO00;

         QTDEMPCODIGO = :QTDEMPCODIGO -1;

       end

     end
     if (:QTDEMPCODIGO < 0) then
       exception FK_PADRAO 'QUANTIDADE DE EMPRESAS SUPERIOR AO PERMITIDO PARA APURACAO DO CUSTO MEDIO!';


     for
         select mv.data, mv.Tipo, mv.Quantidade, coalesce(mv.custoreal,0) CustoReal, mv.EmpCodigo, mv.FisTpNatOp
           from MOVIMENTACAO MV
          where mv.ProCodigo =:sProdu
            and mv.data+0 <=:dData
            and mv.data+0 > :ddatareg
            and mv.LcEst = 'S'
            and mv.lc_estorno is null
            and mv.fistpnatop not in ('REB', 'EB', 'RB', 'RRB', 'RC', 'RRC', 'REC', 'EC')
            and mv.empcodigo in (:EMPCODIGO01,:EMPCODIGO02,:EMPCODIGO03,:EMPCODIGO04,:EMPCODIGO05,:EMPCODIGO06,:EMPCODIGO07,:EMPCODIGO08,:EMPCODIGO09,:EMPCODIGO10)
            and mv.origem in (:ORIGEM01,:ORIGEM02,:ORIGEM03,:ORIGEM04,:ORIGEM05,:ORIGEM06,:ORIGEM07,:ORIGEM08,:ORIGEM09,:ORIGEM10)
         order by 1, 2, mv.ID_MOVIMENTACAO
         into  Data, EntSai, Qtdade, Custo, nEmpCusto, sFisTpNatOp do
     begin
       if (:nEmpCusto = nEmpreCusto ) then
       begin

        if (not Qtdade is null) then
        begin
          if (EntSai = 'C') then
          begin
            VrEstoque = cast(saldoestoque * CustoMedio as numeric(13,2));

            /* Se for natureza de operacao de Doacao e o parametro estiver configurado, zera o custo*/
            if ((sConsideraDoacaoCusto = 'S') and (trim(sfistpnatop) = 'A')) then
            begin
              VrTotal = 0;
            end else
            begin
              VrTotal = cast(Qtdade * Custo as numeric(13,2));
            end  
   
            SaldoEstoque = SaldoEstoque + Qtdade;
            SaldoEstoqueE = SaldoEstoqueE + Qtdade;
            if ( ( trim(sfistpnatop) = 'C' ) or
                 ( trim(sfistpnatop) = 'I' ) or
                 ( trim(sfistpnatop) = 'T' ) or
                 ( trim(sfistpnatop) = sfistpnatopdoacao ) or   /*Doacao ou nao*/
                 ( trim(sfistpnatop) = ''  ) ) then
            begin

              if ((VrEstoque > 0)  and (CustoMedio <> 0)) then
                begin
                  if (((VrEstoque + VrTotal) <> 0)  and (SaldoEstoque <> 0)) then
                    CustoMedio = cast( ((VrEstoque + VrTotal) / SaldoEstoque) as numeric(15,7) );
                end
              else
                begin
                  CustoMedio = cast(Custo as numeric(15,7));
                end

            end
            else
              begin

                CustoMedio = CUSTOMEDIOFORCADO;

              end

          end
          else if (EntSai = 'D') then
          begin
            SaldoEstoque = SaldoEstoque - Qtdade;
            SaldoEstoqueE = SaldoEstoqueE - Qtdade;
          end

          if (CustoMedio > 0) then
            CustoMedioForcado = CustoMedio;

          if ( SaldoEstoque <= 0 ) then
            begin

              CustoMedio = 0;

            end

          nCusMed = CustoMedio;

        end

       end
       else
       begin

        if (not Qtdade is null) then
        begin
          if (EntSai = 'C') then
          begin
            SaldoEstoqueE = SaldoEstoqueE + Qtdade;
          end
          else if ( entsai = 'D' ) then
            SaldoEstoqueE = SaldoEstoqueE - Qtdade;
          end

       end

   end
   nSldEst = SaldoEstoqueE;
   nCusMed = CustoMedio;

   if ((nCusMed <= 0.0001) and (nSldEst <= 0.0001)) then
     begin
       nCusMed = CustoMedioForcado;
     end

   end

  end

  suspend;

end