{poules25: 20/07/2002, vijfde versie in 2002, kent gradaties anders toe...}

program Poules25;

{$APPTYPE CONSOLE}

{uses crt, dos;}
{test}

{extra text to upload to GIT}

const aa_soorten          =   6;  {soort: 1,4=ploeg, 2,5=provincie, 3,6=land}
      aa_basis_soorten    =   3;
      aa_subsoort         =  50;
      aa_sterktes         =  40;
      aa_poules           =  50;
      aa_poulespelers     =   7;
      aa_spelers          =  80;
      aa_var              =   6;
      naamlengte          =  35;
      aa_wissels          =   4;
      aa_niveaus          =   6;
      aa_vglbestanden     =   5;
      aa_verdelingen      =   4;
      aa_verbeteringen    =   3;

type poule_array = array[1..aa_poules,1..aa_poulespelers] of byte;
     spelerslijst = array[0..aa_spelers,1..aa_soorten+1] of integer;
     {1..7 : 1 : sterkte
             2 : ploeg + sterkte
             3 : provincie + sterkte
             4 : land + sterkte
             5 : ploeg
             6 : provincie
             7 : land}
     lijstA = array[1..aa_subsoort,1..aa_soorten] of string[naamlengte];
     {1..6 : 1 : naam van de ploeg + sterkte
             2 : naam van de provincie + sterkte
             3 : naam van het land + sterkte
             4 : naam van de ploeg
             5 : naam van de provincie
             6 : naam van het land}
     lijstB = array[0..aa_subsoort,1..aa_soorten*2] of integer;
     {1..12 : 1 : nummer ploeg + sterkte
              2 : aa_spelers van deze ploeg + sterkte
              3 : nummer provincie + sterkte
              4 : aa_spelers van deze provincie + sterkte
              5 : nummer land + sterkte
              6 : aa_spelers van dit land + sterkte
              7 : nummer ploeg
              8 : aa_spelers van deze ploeg
              9 : nummer provincie
              10: aa_spelers van deze provincie
              11: nummer land
              12: aa_spelers van dit land}
     lijstC = array[1..aa_subsoort] of integer;
     sterktelijst = array[1..aa_sterktes] of string[10];
     spelersgegevens = array[1..aa_spelers,1..aa_var] of string[naamlengte];
     {1..6 : 1 : naam
             2 : voornaam
             3 : sterkte
             4 : ploeg
             5 : provincie
             6 : land }
    poulelist = array[1..aa_poules] of integer;
    poulelijst = record
      lijst : poulelist;
      aantal : integer;
    end;
    tabellijst = record
      lijst : poulelist;
      aantal, macht2 : integer;
    end;
    wissels = array[1..aa_wissels] of integer;
    pouleplaatsen = array[1..2] of wissels;
    lijstD = record
      a : array[1..aa_subsoort,2..aa_soorten] of boolean;
      b : array[1..aa_subsoort,2..aa_soorten] of integer;
    end;
    lijstE = array[1..aa_subsoort,1..aa_soorten*(aa_niveaus+2)] of boolean;

var poule, vglpoule : poule_array;
    tmppoule : array[1..aa_verdelingen] of poule_array;
    tmpconflicten : array[1..4,1..aa_verdelingen] of integer;
    conflicten : array[1..4] of integer;
    spelers : spelerslijst;
    soortnamen : lijstA;
    soorten : lijstB;
    sterktes : sterktelijst;
    n_verdeling, n_spelers, n_poules, n_poulespelers, n_sterktes,
    n_vglpoules, n_vglpoulespelers, n_vglbestanden, start_soort, einde_soort, beste_verdeling : integer;
    n_soort : array[1..aa_soorten] of integer;
    n_reekshoofden_soort : array[1..aa_basis_soorten] of integer;
    n_tab_problems : array[1..aa_soorten] of integer;
    vgl_bestand : array[1..aa_vglbestanden] of string[20];
    gegevenstabel, vglgegevenstabel : spelersgegevens;
    alle_poules : poulelijst;
    tabel: tabellijst;
    verdeling_ok : lijstE;
    tmpverdeling_ok : array[1..aa_verdelingen] of lijstE;
    reeksen_correct, basis_kleiner, land1_reeksh : boolean;

function cijfer_begin(zin : string) : integer;
var i, cijfer, einde : word;
    letter : char;
    code: Integer;
begin
  i := 0;
  repeat
    inc(i);
    letter := zin[i];
  until (letter = #32) or (i > 10);
  einde := length(zin);
  delete(zin,i,einde);
  val(zin,cijfer,code);
  cijfer_begin := cijfer;
end;

function cijfer_einde(zin : string) : integer;
var i, cijfer : word;
    letter : char;
    code: Integer;
begin
  i := length(zin) + 1;
  repeat
    dec(i);
    letter := zin[i];
  until (letter = #32) or (i = 0);
  delete(zin,1,i);
  val(zin,cijfer,code);
  cijfer_einde := cijfer;
end;

procedure spelers_inlezen;
var gegevens : string;
    letter : char;
    test : text;
    i, j, k, oude_k : word;
begin
  assign(test,'c:\Poules\test.txt');
  reset(test);
  readln(test,gegevens);

  readln(test,gegevens);
  n_spelers := cijfer_begin(gegevens);

  n_poules := 0;
  n_poulespelers := 0;
  n_vglbestanden := 0;
  readln(test,gegevens);
  while gegevens <> '' do
    begin
      if cijfer_begin(gegevens) <> 0 then
        begin
          n_poules := n_poules + cijfer_begin(gegevens);
          if cijfer_einde(gegevens) > n_poulespelers then
            n_poulespelers := cijfer_einde(gegevens);
        end
      else
        begin
          k := 0;
          while k <= length(gegevens) do
            begin
              oude_k := k;
              repeat
                inc(k);
                letter := gegevens[k];
              until ((letter = ',') or (k > length(gegevens)));
              inc(n_vglbestanden);
              vgl_bestand[n_vglbestanden] := copy(gegevens,oude_k+1,k-oude_k-1);
            end;
        end;
      readln(test,gegevens);
    end;

  for i := 1 to n_spelers do
    begin
      readln(test,gegevens);
      k := 0;
      for j := 1 to aa_var do
        begin
          oude_k := k;
          repeat
            inc(k);
            letter := gegevens[k];
          until (letter = ',') or (k > naamlengte + oude_k);
          gegevenstabel[i,j] := copy(gegevens,oude_k+1,k-oude_k-1);
        end;
    end;
  close(test);
end;

procedure sorteersterktes;
var gewisseld : boolean;
    j, i, volgende_i, waarde1, waarde2, code : integer;
    wissel : string;
begin
  for j := 2 downto 1 do
    repeat
      gewisseld := false;
      for i := 1 to n_sterktes-1 do
        begin
          volgende_i := i+1;
          if j = 1 then
            begin
              waarde1 := ord(sterktes[i][j]);
              waarde2 := ord(sterktes[volgende_i][j]);
            end
          else
            begin
              val(copy(sterktes[i],2,length(sterktes[i])-1),waarde1,code);
              val(copy(sterktes[volgende_i],2,length(sterktes[volgende_i])-1),waarde2,code);
            end;
          if waarde1 > waarde2 then
            begin
              wissel := sterktes[i];
              sterktes[i] := sterktes[volgende_i];
              sterktes[volgende_i] := wissel;
              gewisseld := true;
            end;
        end;
    until not gewisseld;
end;

procedure sterktetabel;
var i, j : word;
    geplaatst : boolean;
begin
  fillchar(sterktes,sizeOf(sterktes),' ');
  n_sterktes := 0;
  for i := 1 to n_spelers do
    begin
      j := 0;
      geplaatst := false;
      while (j < n_sterktes) and (not geplaatst) do
        begin
          inc(j);
          if gegevenstabel[i,3] = sterktes[j] then
            geplaatst := true;
        end;
      if not geplaatst then
        begin
          inc(n_sterktes);
          sterktes[n_sterktes] := gegevenstabel[i,3];
        end;
    end;
  sorteersterktes;
end;

{procedure die de verschillende soorten sorteert op aantal spelers per soort}
procedure sorteersoorten(kleiner : boolean);
var gewisseld, wisselen : boolean;
    soort, i, volgende_i, wissel : integer;
    wissel2 : string[naamlengte];
begin
  for soort := 1 to aa_soorten do
    repeat
      gewisseld := false;
      for i := 1 to n_soort[soort]-1 do
        begin
          volgende_i := i+1;
          wisselen := false;
          if ( ((soort <= aa_basis_soorten) = kleiner) and   {!!anders dan in 22!!}
           (soortnamen[i,soort][length(soortnamen[i,soort])] = '2') and
           (soortnamen[volgende_i,soort][length(soortnamen[volgende_i,soort])] = '1')) then
            wisselen := true
          else if ((soorten[i,soort*2] < soorten[volgende_i,soort*2]) and
           ( (not ((soort <= aa_basis_soorten) = kleiner)) or
           (soortnamen[i,soort][length(soortnamen[i,soort])]
            = soortnamen[volgende_i,soort][length(soortnamen[volgende_i,soort])]))) then
            wisselen := true;
          if wisselen then
            begin
              wissel := soorten[i,soort*2];
              soorten[i,soort*2] := soorten[volgende_i,soort*2];
              soorten[volgende_i,soort*2] := wissel;
              wissel2 := soortnamen[i,soort];
              soortnamen[i,soort] := soortnamen[volgende_i,soort];
              soortnamen[volgende_i,soort] := wissel2;
              gewisseld := true;
            end;
        end;
    until not gewisseld;
end;

function reekshoofd_soort(soort : integer;kleiner : boolean) : integer;
begin
  if kleiner then
    reekshoofd_soort := soort
  else
    reekshoofd_soort := soort - aa_basis_soorten;
end;

procedure soorttabel(kleiner : boolean);
var i, soort, gegeven, subsoort, rh_soort : word;
    geplaatst, reekshoofd : boolean;
    soortgegeven : string[naamlengte];
begin
  fillchar(soortnamen,sizeOf(soortnamen),' ');
  fillchar(soorten,sizeOf(soorten),0);
  fillchar(n_reekshoofden_soort,sizeOf(n_reekshoofden_soort),0);
  for soort := 1 to aa_soorten do  {1,2=ploeg, 3,4=provincie, 5,6=land}
    begin
      rh_soort := reekshoofd_soort(soort,kleiner);
      soorten[0,soort*2] := n_poules*n_poulespelers - n_spelers; {geeft het aantal lege plaatsen weer}
      n_soort[soort] := 0;
      for i := 1 to n_spelers do
        begin
          case soort of
            1, 4 : gegeven := 4;
            2, 5 : gegeven := 5;
            3, 6 : gegeven := 6;
          end;
          if (((soort = 2) or (soort = 5)) and (gegevenstabel[i,5] = 'Onbekend')) then
            inc(gegeven);
          subsoort := 0;
          geplaatst := false; reekshoofd := false;
          if not ((soort <= aa_basis_soorten) = kleiner) then    {!!anders dan in 22!!}
            soortgegeven := gegevenstabel[i,gegeven]
          else
            if ((gegevenstabel[i,3] = sterktes[1]) {or (gegevenstabel[i,3] = sterktes[2])}) then
              begin
                soortgegeven := gegevenstabel[i,gegeven] + '1';
                reekshoofd := true;
              end
            else
              soortgegeven := gegevenstabel[i,gegeven] + '2';
          while (subsoort < n_soort[soort]) and (not geplaatst) do
            begin
              inc(subsoort);
              if soortnamen[subsoort,soort] = soortgegeven then
                begin
                  geplaatst := true;
                  inc(soorten[subsoort,soort*2]);
                end;
            end;
          if not geplaatst then
            begin
              inc(n_soort[soort]);
              if reekshoofd then
                inc(n_reekshoofden_soort[rh_soort]);  {!!anders dan in 22!!}
              soortnamen[n_soort[soort],soort] := soortgegeven;
              soorten[n_soort[soort],(soort*2)-1] := n_soort[soort];
              inc(soorten[n_soort[soort],soort*2]);
            end;
        end;
    end;
  sorteersoorten(kleiner);
end;

procedure sorteerspelers;
var gewisseld : boolean;
    aantal, j, i, volgende_i, k : integer;
    wisselspeler : array[1..aa_soorten+1] of integer;
    wisselgegeven : array[1..aa_var] of string;
begin
  aantal := aa_soorten + 1;
  for j := aantal downto 1 do
    repeat
      gewisseld := false;
      for i := 1 to n_spelers-1 do
        begin
          volgende_i := i+1;
          if spelers[i,j] > spelers[volgende_i,j] then
            begin
              for k := 1 to aantal do
                wisselspeler[k] := spelers[i,k];
              spelers[i] := spelers[volgende_i];
              for k := 1 to aantal do
                spelers[volgende_i,k] := wisselspeler[k];
              for k := 1 to aa_var do
                wisselgegeven[k] := gegevenstabel[i,k];
              gegevenstabel[i] := gegevenstabel[volgende_i];
              for k := 1 to aa_var do
                gegevenstabel[volgende_i,k] := wisselgegeven[k];
              gewisseld := true;
            end;
        end;
    until not gewisseld;
end;

procedure spelers_coderen(kleiner : boolean);
var i, soort, sterkte, sub_soort, gegeven : word;
    soortgegeven : string[naamlengte];
begin
  for i := 1 to aa_soorten+1 do
    spelers[0,i] := 0;
  for i := 1 to n_spelers do
    begin
      sterkte := 0;
      repeat
        inc(sterkte);
      until sterktes[sterkte] = gegevenstabel[i,3];
      spelers[i,1] := sterkte;

      for soort := 1 to aa_soorten do
        begin
          case soort of
            1, 4 : gegeven := 4;
            2, 5 : gegeven := 5;
            3, 6 : gegeven := 6;
          end;
          if (((soort = 2) or (soort = 5)) and (gegevenstabel[i,5] = 'Onbekend')) then
            inc(gegeven);
          sub_soort := 0;
          if not ((soort <= aa_basis_soorten) = kleiner) then    {!!anders dan in 22!!}
            soortgegeven := gegevenstabel[i,gegeven]
          else
            if ((gegevenstabel[i,3] = sterktes[1]) {or (gegevenstabel[i,3] = sterktes[2])}) then
              soortgegeven := gegevenstabel[i,gegeven] + '1'
            else
              soortgegeven := gegevenstabel[i,gegeven] + '2';
          repeat
            inc(sub_soort);
          until soortnamen[sub_soort,soort] = soortgegeven;
          spelers[i,soort+1] := sub_soort;
        end;
    end;
  sorteerspelers;
end;

procedure slang;
var i, j, aantal_spelers : word;
begin
  aantal_spelers := 0;
  for i := 1 to n_poulespelers do
    begin
      if (i mod 2) = 1 then
        begin
          for j := 1 to n_poules do
            begin
              inc(aantal_spelers);
              if aantal_spelers <= n_spelers then
                poule[j,i] := aantal_spelers
              else
                poule[j,i] := 0;
            end;
        end
      else
        begin
          for j := n_poules downto 1 do
            begin
              inc(aantal_spelers);
              if aantal_spelers <= n_spelers then
                poule[j,i] := aantal_spelers
              else
                poule[j,i] := 0;
            end;
        end;
    end;
end;

procedure inlezen_vglpoules;
var gegevens : string;
    letter : char;
    i, j, k, oude_k, l, m, n : integer;
    vgl : text;
begin
  i := 0;
  m := 0;
  n_vglpoulespelers := 0;
  for l := 1 to n_vglbestanden do
    begin
      assign(vgl,vgl_bestand[l]);
      reset(vgl);
      readln(vgl,gegevens);
      while length(gegevens) > 5 do
        begin
          readln(vgl,gegevens);
          inc(m);
          n := 0;
          while copy(gegevens,1,5) <> 'poule' do
            begin
              inc(i);
              inc(n);
              k := 0;
              for j := 1 to aa_var do
                begin
                  oude_k := k;
                  repeat
                    inc(k);
                    letter := gegevens[k];
                  until (letter = ',') or (k > naamlengte + oude_k);
                  vglgegevenstabel[i,j] := copy(gegevens,oude_k+1,k-oude_k-1);
                  vglpoule[m,n] := i;
                end;
              readln(vgl,gegevens);
            end;
          if n > n_vglpoulespelers then
            n_vglpoulespelers := n;
        end;
      close(vgl);
    end;
  n_vglpoules := m;
end;

procedure schrijf_bestand;
var i, j :integer;
    result : text;
    bestand : string;
begin
  bestand := 'Ntest.txt';
  assign(result,bestand);
  rewrite(result);
  for i := 1 to n_poules do
    begin
      writeln(result,'poule,',i);
      for j := 1 to n_poulespelers do
        begin
          if poule[i,j] <> 0 then
            begin
              write(result,gegevenstabel[poule[i,j],1],',',gegevenstabel[poule[i,j],2],',',gegevenstabel[poule[i,j],3]);
              writeln(result,',',gegevenstabel[poule[i,j],4],',',gegevenstabel[poule[i,j],5],',',gegevenstabel[poule[i,j],6]);
            end;
        end;
    end;
  write(result,'poule');
  close(result);
end;

{functie die kijkt of een ploeg, provincie of land uit de uithaal_poule kan
gehaald worden en in de inhaal_poule gestopt worden}
function soort2aan2_te_wisselen(soort : byte; insteek_poule, uithaal_poule, subsoort : integer): boolean;
var k, spelers_per_poule, soortnummer,
    aantal_in_insteek, aantal_in_uithaal : integer;
begin
  soortnummer := 0;
  repeat
    inc(soortnummer);
  until subsoort = soorten[soortnummer,(soort*2)-1];
  spelers_per_poule := soorten[soortnummer,soort*2] div n_poules;

  aantal_in_insteek := 0;
  for k := 1 to n_poulespelers do
    if (subsoort = spelers[poule[insteek_poule,k],soort+1]) then
      inc(aantal_in_insteek);

  aantal_in_uithaal := 0;
  for k := 1 to n_poulespelers do
    if (subsoort = spelers[poule[uithaal_poule,k],soort+1]) then
      inc(aantal_in_uithaal);

  if (aantal_in_insteek > spelers_per_poule) or
   ((aantal_in_insteek = spelers_per_poule) and
   (aantal_in_uithaal <= spelers_per_poule)) then
    soort2aan2_te_wisselen := false
  else
    soort2aan2_te_wisselen := true;
end;

function allen_gelijk(aantal : integer;var wisselsoort : wissels): boolean;
var i : byte;
    temp : boolean;
begin
  temp := true;
  for i := 2 to aantal do
    if wisselsoort[1] <> wisselsoort[i] then
      temp := false;
  allen_gelijk := temp;
end;

function subsoort2en3_te_wisselen(n : byte; var de_poules, wisselsoort : wissels;
                                  var soort : integer;kleiner, reekshoofden, land1 : boolean): boolean;
var i, q, rh_soort : integer;
    geldig : boolean;
begin
  rh_soort := reekshoofd_soort(soort,kleiner);
  geldig := true;
  if not allen_gelijk(n,wisselsoort) then
    begin
      i := 0;
      repeat
        inc(i);
        {!!anders dan in 22!!}
        if not ( ( ((soort <= aa_basis_soorten) = kleiner)
          and ((wisselsoort[i] > n_reekshoofden_soort[rh_soort]) or (not reekshoofden)))
         or (not land1 and ((soort mod aa_basis_soorten) = 0) and (wisselsoort[i] =1)) ) then
          begin
            q := (i mod n) + 1;
            if not soort2aan2_te_wisselen(soort,de_poules[q],de_poules[i],wisselsoort[i]) then
              geldig := false;
          end;
      until ((i = n) or (geldig = false));
    end;
  subsoort2en3_te_wisselen := geldig;
end;

function subsoort4_te_wisselen(var de_poules, wisselsoort : wissels;
                               var soort : integer;kleiner, reekshoofden, land1 : boolean): boolean;
var i, q, rh_soort : integer;
    geldig : boolean;
    wisselsoort2, de_poules2 : wissels;
begin
  rh_soort := reekshoofd_soort(soort,kleiner);
  geldig := true;
  if not allen_gelijk(4,wisselsoort) then
    begin
    i := 0;
    if ((de_poules[1] <> de_poules[3]) and (de_poules[2] <> de_poules[4])) then
      repeat
        inc(i);
        de_poules2[1] := de_poules[(i*2)-1];
        de_poules2[2] := de_poules[i*2];
        wisselsoort2[1] := wisselsoort[(i*2)-1];
        wisselsoort2[2] := wisselsoort[i*2];
        geldig := subsoort2en3_te_wisselen(2,de_poules2,wisselsoort2,soort,kleiner,reekshoofden,land1);
      until ((i=2) or (geldig = false))
    else
      repeat
        inc(i);
        {!!anders dan in 22!!}
        if not ( (((soort <= aa_basis_soorten) = kleiner)
          and ((wisselsoort[i] > n_reekshoofden_soort[rh_soort]) or (not reekshoofden)))
         or (not land1 and ((soort mod aa_basis_soorten) = 0) and (wisselsoort[i] =1)) ) then
          begin
            if ((i mod 2) = 0) then
              q := i - 1
            else
              q := i + 1;
            if (((not soort2aan2_te_wisselen(soort,de_poules[q],de_poules[i],wisselsoort[i]))
             and ((de_poules[5-i] <> de_poules[q])
              or (wisselsoort[i] <> wisselsoort[q])
              or (wisselsoort[i] = wisselsoort[5-i]))
             and ((de_poules[5-i] <> de_poules[q])
              or (wisselsoort[i] <> wisselsoort[5-i])
              or (wisselsoort[i] = wisselsoort[q])))) then
            geldig := false;
          end;
      until ((i = 4) or (geldig = false));
    end;
  subsoort4_te_wisselen := geldig;
end;

function soorten_te_wisselen(plaats : pouleplaatsen; soort, aantal : byte;kleiner, reekshoofden, land1 : boolean): boolean;
var i, j : integer;
    wisselsoort : wissels;
    geldig : boolean;
begin
  i := 0;
  geldig := true;
  while ((i < soort) and geldig) do
    begin
      inc(i);
      for j := 1 to aantal do
        wisselsoort[j] := spelers[poule[plaats[1,j],plaats[2,j]],i+1];
      case aantal of
        2, 3 : geldig := subsoort2en3_te_wisselen(aantal,plaats[1],wisselsoort,i,kleiner,reekshoofden,land1);
        4    : geldig := subsoort4_te_wisselen(plaats[1],wisselsoort,i,kleiner,reekshoofden,land1);
      end;
    end;
  soorten_te_wisselen := geldig;
end;

procedure verfijn(soort : byte;kleiner, reekshoofden, land1 : boolean);
var i, j, k, l, l1, l2, k1, k2, n_soortconflict, n_vrij, n_vrij2, teller, hoe_perfect,
    aa_spelers_soort, spelers_per_poule, verminder_na, einde, wissel : integer;
    soort_conflicten, vrije_plaatsen : poulelist;
    gewisseld, wissel_perfect, wissel_perfect2, conflict, stop, omkeren : boolean;
    plaatsen2 : pouleplaatsen;
begin
  teller := 0;
  repeat
    inc(teller);
    conflict := false;
    omkeren := false;
    wissel_perfect := true;
    wissel_perfect2 := true;
    case (teller mod 8) of
      0, 2, 5: omkeren := true;
      3: wissel_perfect := false;
      6: wissel_perfect2 := false;
    end;
    if omkeren then
      einde := 0
    else
      einde := n_poulespelers;
    if ((wissel_perfect) and (wissel_perfect2)) then
      hoe_perfect := soort
    else
      hoe_perfect := soort - 1;

    for i := 0 to n_soort[soort] do {soort 0 = de lege plaatsen}
      begin
        stop := false;
        repeat
          gewisseld := false;
          spelers_per_poule := (soorten[i,soort*2] div n_poules) + 1;
          verminder_na := (soorten[i,soort*2] mod n_poules);
          n_soortconflict := 0;
          n_vrij := 0;
          n_vrij2 := 0;
          for j := 1 to n_poules do
            begin
              aa_spelers_soort := 0;
              if verminder_na = 0 then
                begin
                  dec(verminder_na);
                  dec(spelers_per_poule);
                end;
              for k := 1 to n_poulespelers do
                begin
                  if spelers[poule[j,k],soort+1] = soorten[i,(soort*2)-1] then
                    inc(aa_spelers_soort);
                end;
              if aa_spelers_soort = spelers_per_poule then
                begin
                  dec(verminder_na)
                end;
              if aa_spelers_soort > spelers_per_poule then
                begin
                  dec(verminder_na);
                  inc(n_soortconflict);
                  soort_conflicten[n_soortconflict] := j;
                end;
              if aa_spelers_soort < spelers_per_poule then
                begin
                  if (aa_spelers_soort = 0) or (aa_spelers_soort < (soorten[i,soort*2] div n_poules)) then
                    begin
                      inc(n_vrij);
                      vrije_plaatsen[n_vrij] := j;
                    end
                  else
                    begin
                      vrije_plaatsen[n_poules-n_vrij2] := j;
                      inc(n_vrij2);
                    end;
                end;
            end;
          if n_soortconflict <> 0 then
            begin
              if n_vrij = 0 then
                begin
                  n_vrij := n_vrij2;
                  for j := 1 to n_vrij do
                    vrije_plaatsen[j] := vrije_plaatsen[j + n_poules - n_vrij];
                end;
              if not wissel_perfect then
                begin
                  n_vrij := n_poules - n_soortconflict;
                  k := 1;
                  l := 0;
                  for j := 1 to n_poules do
                    begin
                      if j <> soort_conflicten[k] then
                        begin
                          inc(l);
                          vrije_plaatsen[l] := j;
                        end
                      else
                        begin
                          inc(k);
                        end;
                    end;
                end;
              if not wissel_perfect2 then
                begin
                  n_soortconflict := n_poules - n_vrij;
                  k := 1;
                  l := 0;
                  for j := 1 to n_poules do
                    begin
                      if j <> vrije_plaatsen[k] then
                        begin
                          inc(l);
                          soort_conflicten[l] := j;
                        end
                      else
                        begin
                          inc(k);
                        end;
                    end;
                end;
              l1 := 0;
              repeat
                inc(l1);
                if not omkeren then
                  k1 := 0
                else
                  k1 := n_poulespelers;
                repeat
                  if not omkeren then
                    inc(k1);
                  if (spelers[poule[soort_conflicten[l1],k1],soort+1] = soorten[i,(soort*2)-1]) then
                    begin
                      l2 := 0;
                      repeat
                        inc(l2);
                        if not omkeren then
                          k2 := 0
                        else
                          k2 := n_poulespelers;
                        repeat
                          if not omkeren then
                            inc(k2);
                          plaatsen2[1,1] := vrije_plaatsen[l2];
                          plaatsen2[2,1] := k2;
                          plaatsen2[1,2] := soort_conflicten[l1];
                          plaatsen2[2,2] := k1;
                          {insteek = conflict, uithaal = vrij}
                          if ((spelers[poule[soort_conflicten[l1],k1],1]
                           = spelers[poule[vrije_plaatsen[l2],k2],1])
                           and (spelers[poule[soort_conflicten[l1],k1],soort+1]
                            <> spelers[poule[vrije_plaatsen[l2],k2],soort+1])
                           and (soorten_te_wisselen(plaatsen2,hoe_perfect,2,kleiner,reekshoofden,land1))) then
                            begin
                              wissel := poule[soort_conflicten[l1],k1];
                              poule[soort_conflicten[l1],k1] := poule[vrije_plaatsen[l2],k2];
                              poule[vrije_plaatsen[l2],k2] := wissel;
                              gewisseld := true;
                              if not wissel_perfect then
                                begin
                                  wissel_perfect := true;
                                  stop := true;
                                end;
                              if not wissel_perfect2 then
                                begin
                                  wissel_perfect2 := true;
                                  stop := true;
                                end;
                            end;
                          if omkeren then
                            dec(k2);
                        until gewisseld or (k2 = einde);
                      until gewisseld or (l2 = n_vrij);
                    end;
                  if omkeren then
                    dec(k1);
                until gewisseld or (k1 = einde);
              until gewisseld or (l1 = n_soortconflict);
            end;
        until (stop or (n_soortconflict = 0) or (not gewisseld and (k2 = einde)
         and (l2 = n_vrij) and (k1 = einde) and (l1 = n_soortconflict)));
        if n_soortconflict > 0 then
          begin
            conflict := true;
          end;
      end;
  until ((teller >= 32) or (not conflict));
  if conflict then
    begin
      if soort = 1 then
        writeln('Er is nog een ploegconflict!')
      else if soort = 2 then
        writeln('Er is nog een provincieconflict!')
      else if soort = 3 then
        writeln('Er is nog een landenconflict!');
    end;
end;

{functie die de n-de macht van een bepaald getal berekent}
function macht(getal, n : integer): integer;
var i, tmp_macht : integer;
begin
  tmp_macht := 1;
  if n > 0 then
    for i := 1 to n do
      tmp_macht := tmp_macht * getal;
  macht := tmp_macht;
end;

procedure genereer_tabel;
var lijst2: array[1..aa_poules div 2] of integer;
    i: integer;
begin
  tabel.aantal:= 2;
  tabel.macht2 := 1;
  tabel.lijst[1] := 1;    tabel.lijst[2] := 2;
  while tabel.aantal < n_poules do
    begin
      for i := 1 to tabel.aantal do
        lijst2[i] := tabel.lijst[i];
      for i := 1 to tabel.aantal do
        begin
          if (i mod 2) = 0 then
            begin
              tabel.lijst[(i*2)-1] := lijst2[i-1] + tabel.aantal;
              tabel.lijst[i*2] := lijst2[i];
            end
          else
            begin
              tabel.lijst[(i*2)-1] := lijst2[i];
              tabel.lijst[i*2] := lijst2[i+1] + tabel.aantal;
            end;
        end;
      tabel.aantal := tabel.aantal * 2;
      inc(tabel.macht2);
    end;
end;

function aa_soorten_in_poulelijst(soort : byte; var poules : poulelijst; subsoort:integer):integer;
var j, k, temp : integer;
begin
  temp := 0;
  for j := 1 to poules.aantal do
    begin
      for k := 1 to n_poulespelers do
        begin
          if spelers[poule[poules.lijst[j],k],soort+1] = subsoort then
            inc(temp)
        end;
    end;
  aa_soorten_in_poulelijst := temp;
end;

{kijkt of een bepaalde poule zich bevindt in een reeks poules}
function poule_in_lijst(var poules : poulelijst; poule: integer):boolean;
var i : integer;
    gevonden : boolean;
begin
  gevonden := false;
  i := 0;
  repeat
    inc(i);
    if poule = poules.lijst[i] then
      gevonden := true;
  until ((gevonden) or (i = poules.aantal));
  poule_in_lijst := gevonden;
end;

{stelt poulesA&B op vanaf poule start t.e.m. poule einde}
procedure sub_tabel(var start, einde : integer; var poulesA, poulesB: poulelijst);
var i : integer;
begin
  poulesA.aantal := 0;
  poulesB.aantal := 0;
  for i := start to einde do
    begin
      if ((i <= ((einde+start-1) div 2)) and (tabel.lijst[i] <= n_poules)) then
        begin
          inc(poulesA.aantal);
          poulesA.lijst[poulesA.aantal] := tabel.lijst[i];
        end
      else if (tabel.lijst[i] <= n_poules) then
        begin
          inc(poulesB.aantal);
          poulesB.lijst[poulesB.aantal] := tabel.lijst[i];
        end;
    end;
end;

{functie die gebruikt wordt in de functies subtabel#_te_wisselen}
function aantal_in_poulesAB(var poule, aantalA, aantalB : integer;
                            var poulesA, poulesB: poulelijst):integer;
var Agevonden, Bgevonden: boolean;
begin
  Agevonden := poule_in_lijst(poulesA,poule);
  Bgevonden := poule_in_lijst(poulesB,poule);
  if Agevonden then
    aantal_in_poulesAB := aantalA - aantalB
  else if Bgevonden then
    aantal_in_poulesAB := aantalB - aantalA
  else
    aantal_in_poulesAB := 1; {wlk. pos. getal}
end;

{als de_poules ofwel ALLEMAAL tot poulesA behoren ofwel ALLEMAAL tot poulesB,
dan is allen_in_poulesAB true, anders wordt de functie false}
function allen_in_poulesAB(aantal : integer; var poulesA, poulesB : poulelijst;
                           var de_poules : wissels) : boolean;
var i : byte;
    in_lijst : boolean;
begin
  in_lijst := true;
  for i := 1 to aantal do
    if not poule_in_lijst(poulesA,de_poules[i]) then
      in_lijst := false;
  if not in_lijst then
    begin
      in_lijst := true;
      for i := 1 to aantal do
        if not poule_in_lijst(poulesB,de_poules[i]) then
          in_lijst := false;
    end;
  allen_in_poulesAB := in_lijst;
end;

{als 1 poule uit de_poules tot ofwel poulesA behoort ofwel tot poulesB,
dan is iemand_in_poulesAB true, anders wordt de functie false}
function iemand_in_poulesAB(aantal : integer; var poulesA, poulesB : poulelijst;
                           var de_poules : wissels) : boolean;
var i : byte;
    in_lijst : boolean;
begin
  in_lijst := false;
  for i := 1 to aantal do
    if poule_in_lijst(poulesA,de_poules[i]) then
      in_lijst := true;
  if not in_lijst then
    begin
      for i := 1 to aantal do
        if poule_in_lijst(poulesB,de_poules[i]) then
          in_lijst := true;
    end;
  iemand_in_poulesAB := in_lijst;
end;

function subtabel2en3_te_wisselen(n : byte; var de_poules, wisselsoort : wissels;
                                  var soort, start, einde : integer; kleiner, reekshoofden, land1 : boolean): boolean;
{n = 2 of 3, naargelang subtabel2_te_wisselen of subtabel3_te_wisselen}
var i, q, aantalA, aantalB, aantal, rh_soort : integer;
    poulesA, poulesB : poulelijst;
    geldig : boolean;
begin
  rh_soort := reekshoofd_soort(soort,kleiner);
  geldig := true;
  sub_tabel(start,einde,poulesA,poulesB);
  {als (1) de poules ofwel ALLEMAAL tot poulesA behoren ofwel ALLEMAAL
   tot poulesB, of als (2) geen enkel poule tot ofwel poulesA, ofwel poulesB
   behoort, of als (3) alle wisselsoorten gelijk zijn, dan is er geen verdere
   controle meer nodig}
  if ((not allen_in_poulesAB(n,poulesA,poulesB,de_poules))
   and (iemand_in_poulesAB(n,poulesA,poulesB,de_poules))
   and (not allen_gelijk(n,wisselsoort))) then
    begin
      i := 0;
      repeat
        inc(i);
        {!!anders dan in 22!!}
        if not ( (((soort <= aa_basis_soorten) = kleiner)
          and ((wisselsoort[i] > n_reekshoofden_soort[rh_soort]) or (not reekshoofden)))
         or (not land1 and ((soort mod aa_basis_soorten) = 0) and (wisselsoort[i] =1)) ) then
          begin
            q := (i mod n) + 1;
            aantalA := aa_soorten_in_poulelijst(soort,poulesA,wisselsoort[i]);
            aantalB := aa_soorten_in_poulelijst(soort,poulesB,wisselsoort[i]);
            aantal := aantal_in_poulesAB(de_poules[i],aantalA,aantalB,poulesA,poulesB);
            if ((aantal = 0)
             and ( ( (poule_in_lijst(poulesA,de_poules[i]))
               and (not poule_in_lijst(poulesB,de_poules[q])) )
              or ( (poule_in_lijst(poulesB,de_poules[i]))
               and (not poule_in_lijst(poulesA,de_poules[q])) ) )) then
              begin
                aantal := 1;    {wlk. pos. getal}
              end;
            if (( (poule_in_lijst(poulesA,de_poules[q]))
              and (not poule_in_lijst(poulesA,de_poules[i]))
              and (aantalA > aantalB) )
             or ( (poule_in_lijst(poulesB,de_poules[q]))
              and (not poule_in_lijst(poulesB,de_poules[i]))
              and (aantalB > aantalA) )) then
              begin
                aantal := -1;   {wlk. neg. getal}
                aantalA := 1;   {wlk. pos. getal}
                aantalB := 1;   {wlk. pos. getal}
              end;
            if ((aantal <= 0) and (aantalA <> 0) and (aantalB <> 0)
             and (wisselsoort[i] <> wisselsoort[q])) then
              geldig := false;
          end;
      until ((not geldig) or (i = n));
    end;
  subtabel2en3_te_wisselen := geldig;
end;

function subtabel4_te_wisselen(var de_poules, wisselsoort : wissels;
                               var soort, start, einde : integer;kleiner, reekshoofden, land1 : boolean): boolean;
var i, q, aantalA, aantalB, aantal, rh_soort : integer;
    poulesA, poulesB : poulelijst;
    geldig : boolean;
begin
  rh_soort := reekshoofd_soort(soort,kleiner);
  geldig := true;
  sub_tabel(start,einde,poulesA,poulesB);
  if ((not allen_in_poulesAB(4,poulesA,poulesB,de_poules))
   and (iemand_in_poulesAB(4,poulesA,poulesB,de_poules))
   and (not allen_gelijk(4,wisselsoort))) then
    begin
      i := 0;
      repeat
        inc(i);
        {!!anders dan in 22!!}
        if not ( (((soort <= aa_basis_soorten) = kleiner)
          and ((wisselsoort[i] > n_reekshoofden_soort[rh_soort]) or (not reekshoofden)))
         or (not land1 and ((soort mod aa_basis_soorten) = 0) and (wisselsoort[i] =1)) ) then
          begin
            q := (2 * ((i-1) div 2)) + (i mod 2) + 1;
            if (poule_in_lijst(poulesA,de_poules[i]) or poule_in_lijst(poulesB,de_poules[i])) then
              begin
                aantalA := aa_soorten_in_poulelijst(soort,poulesA,wisselsoort[i]);
                aantalB := aa_soorten_in_poulelijst(soort,poulesB,wisselsoort[i]);
                aantal := aantal_in_poulesAB(de_poules[i],aantalA,aantalB,poulesA,poulesB);
                if (((aantal <= 0) and (aantalA <> 0) and (aantalB <> 0)
                   and (((de_poules[5-i] <> de_poules[q])
                       and (not poule_in_lijst(poulesA,de_poules[5-i])
                        or not poule_in_lijst(poulesA,de_poules[q]))
                       and (not poule_in_lijst(poulesB,de_poules[5-i])
                        or not poule_in_lijst(poulesB,de_poules[q])))
                     or (wisselsoort[i] <> wisselsoort[5-i])
                     or (wisselsoort[i] = wisselsoort[q])))) then
                  geldig := false;
              end;
          end;
      until ((not geldig) or (i = 4));
    end;
  subtabel4_te_wisselen := geldig;
end;

function tabel_te_wisselen(var plaats : pouleplaatsen;soort, aantal : byte;kleiner, reekshoofden, land1 : boolean): boolean;
var geldig : boolean;
    i, j, a, b, start, einde : integer;
    wisselsoort : wissels;
begin
  i := 0;
  geldig := true;
  while ((i < soort) and geldig) do
    begin
      inc(i);
      for j := 1 to aantal do
        wisselsoort[j] := spelers[poule[plaats[1,j],plaats[2,j]],i+1];
      a := 0;
      while ((geldig) and (a < tabel.macht2-1)) do
        begin
          inc(a);
          einde := 0;
          b := 0;
          while ((geldig) and (b < macht(2,a-1))) do
            begin
              inc(b);
              start := einde + 1;
              einde := (tabel.aantal div macht(2,a-1)) + einde;
          case aantal of
            2, 3 : geldig := subtabel2en3_te_wisselen(aantal,plaats[1],wisselsoort,i,start,einde,kleiner,reekshoofden,land1);
            4    : geldig := subtabel4_te_wisselen(plaats[1],wisselsoort,i,start,einde,kleiner,reekshoofden,land1);
          end;
            end;
        end;
    end;
  tabel_te_wisselen := geldig;
end;

procedure een_subsoort_in_soort(var een : lijstD; var poulesA, poulesB : poulelijst);
var i, j, k, subsoort, soort : integer;
begin
  fillchar(een.a,sizeOf(een.a),true);
  fillchar(een.b,sizeOf(een.b),0);
  for soort := 2 to aa_soorten do
    begin
      for k := 1 to n_soort[soort] do
        begin
          subsoort := 0;
          for i := 1 to poulesA.aantal do
            for j := 1 to n_poulespelers do
              if ((spelers[poule[poulesA.lijst[i],j],soort+1] = k) and (subsoort = 0)) then
                subsoort := spelers[poule[poulesA.lijst[i],j],soort];
          if subsoort = 0 then
            for i := 1 to poulesB.aantal do
              for j := 1 to n_poulespelers do
                if ((spelers[poule[poulesB.lijst[i],j],soort+1] = k) and (subsoort = 0)) then
                  subsoort := spelers[poule[poulesB.lijst[i],j],soort];
          if subsoort <> 0 then
            for i := 1 to poulesA.aantal do
              for j := 1 to n_poulespelers do
                if ((poule[poulesA.lijst[i],j] <> 0) and (spelers[poule[poulesA.lijst[i],j],soort+1] = k)
                 and (spelers[poule[poulesA.lijst[i],j],soort] <> subsoort)) then
                  een.a[k,soort] := false;
          if ((een.a[k,soort] = true) and (subsoort <> 0)) then
            for i := 1 to poulesB.aantal do
              for j := 1 to n_poulespelers do
                if ((poule[poulesB.lijst[i],j] <> 0) and (spelers[poule[poulesB.lijst[i],j],soort+1] = k)
                 and (spelers[poule[poulesB.lijst[i],j],soort] <> subsoort)) then
                  een.a[k,soort] := false;
          if subsoort = 0 then
            een.a[k,soort] := false;
          if een.a[k,soort] = true then
            een.b[k,soort] := subsoort;
        end;
    end;
end;

function werkelijk_tabelverschil(soort, subsoort : integer; var poulesA, poulesB : poulelijst) : integer;
var aantalA, aantalB : integer;
begin
  aantalA := aa_soorten_in_poulelijst(soort,poulesA,subsoort);
  aantalB := aa_soorten_in_poulelijst(soort,poulesB,subsoort);
  werkelijk_tabelverschil := abs(aantalA-aantalB);
end;

procedure tabelverschil(soort : integer; var poulesA, poulesB : poulelijst;
                        var verschil : lijstC; var een : lijstD; controle : boolean);
var i, j, aantalA, aantalB, tot_aantal_p, min_verschil, tot_verschil : integer;
    aantal_per_subsoort, subverschil, controle_verschil : lijstC;
    vast_verschil: array[1..aa_subsoort] of boolean;
begin
  fillchar(aantal_per_subsoort,sizeOf(aantal_per_subsoort),0);
  fillchar(vast_verschil,sizeOf(vast_verschil),false);
  tot_aantal_p := poulesA.aantal + poulesB.aantal;
  aantalA := 0;
  for i := 1 to poulesA.aantal do
    for j := 1 to n_poulespelers do
          begin
        if poule[poulesA.lijst[i],j] <> 0 then
          begin
            inc(aantalA);
            inc(aantal_per_subsoort[spelers[poule[poulesA.lijst[i],j],soort+1]]);
          end;
      end;
  aantalB := 0;
  for i := 1 to poulesB.aantal do
    for j := 1 to n_poulespelers do
      begin
        if poule[poulesB.lijst[i],j] <> 0 then
          begin
            inc(aantalB);
            inc(aantal_per_subsoort[spelers[poule[poulesB.lijst[i],j],soort+1]]);
          end;
      end;
  min_verschil := abs(aantalA - aantalB);
  if ((soort mod aa_basis_soorten) <> 1) then
    tabelverschil(soort-1,poulesA,poulesB,subverschil,een,controle);
  for i := 1 to n_soort[soort] do
    begin
      if aantal_per_subsoort[i] = 1 then {als iets misloopt, deze if eens weglaten...}
        begin
          verschil[i] := 1;
          controle_verschil[i] := 1;
          vast_verschil[i] := true;
        end
      else if ((aantal_per_subsoort[i] mod tot_aantal_p) = 0) then
        begin
          verschil[i] := werkelijk_tabelverschil(soort,i,poulesA,poulesB);
          controle_verschil[i] := abs((aantal_per_subsoort[i] div tot_aantal_p)*(poulesA.aantal - poulesB.aantal));
          vast_verschil[i] := true;
        end
      else if ((soort mod aa_basis_soorten) <> 1) then
        begin
          if een.a[i,soort] = true then
            begin
              verschil[i] := werkelijk_tabelverschil(soort-1,een.b[i,soort],poulesA,poulesB);
              controle_verschil[i] := subverschil[een.b[i,soort]];
              vast_verschil[i] := true;
            end;
        end;
    end;
  tot_verschil := 0;
  for i := 1 to n_soort[soort] do
    begin
      if not vast_verschil[i] then
        begin
          if (aantal_per_subsoort[i] mod 2) = 0 then
            verschil[i] := 0
          else
            verschil[i] := 1;
        end;
      tot_verschil := tot_verschil + verschil[i];
    end;
  i := 0;
  while (tot_verschil < min_verschil) do
    begin
      inc(i);
      if i > n_soort[soort] then
        i := 1;
      if (not vast_verschil[i] and (2*verschil[i] <= aantal_per_subsoort[i]-2)) then
        begin
          verschil[i] := verschil[i] + 2;
          tot_verschil := tot_verschil + 2;
        end;
    end;
  for i := 1 to n_soort[soort] - 1 do
    for j := i + 1 to n_soort[soort] do
      if ((aantal_per_subsoort[i] = aantal_per_subsoort[j])
       and (not vast_verschil[i]) and (not vast_verschil[j])
       and (verschil[i] > verschil[j])) then
        verschil[i] := verschil[j];

  if controle then
    for i := 1 to n_soort[soort] do
      if vast_verschil[i] then
        verschil[i] := controle_verschil[i];
end;

{newpoules = oldpoules zonder verboden_p, indien verboden_p = 0, dan newpoules
is volledig GELIJK aan oldpoules}
procedure poulelijst_min_1(var newpoules, oldpoules : poulelijst;verboden_p : byte);
var i : integer;
begin
  newpoules.aantal := 0;
  for i := 1 to oldpoules.aantal do
    begin
      if oldpoules.lijst[i] <> verboden_p then
        begin
          inc(newpoules.aantal);
          newpoules.lijst[newpoules.aantal] := oldpoules.lijst[i];
        end;
    end;
end;

{stopt alle poules (# = n_poules) in newpoules}
procedure alle_poules_in_lijst(var newpoules : poulelijst);
var i : integer;
begin
  newpoules.aantal := n_poules;
  for i := 1 to n_poules do
    newpoules.lijst[i] := i;
end;

procedure verfijn_tornooitabel(soort, verboden : byte; var aa_problems : integer;kleiner, reekshoofden, land1 : boolean);
var i, j, k, j1, j2, l, k2, l2, n, m, r, s , a, b, aantalA, aantalB, n_conflict, not_conflict,
    old_n_conflict, hoe_perfect, n_wissels, einde, start, wissel2 : integer;
    wisselsoort : array[1..2] of byte;
    teller, teller2, tellertje : byte;
    wissel, poulesA, poulesB, de_poules, poulesA1, poulesA2, poulesB2 : poulelijst;
    wisselbaar, gewisseld, stop, wissel_perfect, ongeldig, mogelijk,
    uitbreiding, stoppen : boolean;
    plaatsen : pouleplaatsen;
    aa_onmog_uitbr2, aa_onmog_uitbr3, aa_onmog_uitbr4 : array[1..aa_poules] of byte;
    onmog_uitbr2, onmog_uitbr3, onmog_uitbr4 : array[1..aa_subsoort,1..aa_poules] of byte;
    verschil : lijstC;
    een : lijstD;
begin
  poulelijst_min_1(de_poules,alle_poules,verboden);
  teller2 := 0;
  repeat
    stoppen := true;
    inc(teller2);
    aa_problems := 0;
    for a:= 1 to (tabel.macht2-1) do
      begin
        einde := 0;
        for b:= 1 to macht(2,a-1) do
          begin
            start := einde + 1;
            einde := (tabel.aantal div macht(2,a-1)) + einde;
            sub_tabel(start,einde,poulesA,poulesB);
            een_subsoort_in_soort(een,poulesA,poulesB);
            tabelverschil(soort,poulesA,poulesB,verschil,een,false);
            teller := 0;
            fillchar(aa_onmog_uitbr2,sizeOf(aa_onmog_uitbr2),0);
            fillchar(aa_onmog_uitbr4,sizeOf(aa_onmog_uitbr4),0);
            fillchar(aa_onmog_uitbr3,sizeOf(aa_onmog_uitbr3),0);
            repeat
              inc(teller);
              stop := false;

              case (teller mod 18) of 2, 6, 10 :
                wissel_perfect := false
              else
                wissel_perfect := true;
              end;
              case (teller mod 18) of
                4, 6, 14 : n_wissels := 4;
                8, 10, 16 : n_wissels := 3;
              else
                n_wissels := 2;
              end;
              case (teller mod 18) of 12, 14, 16 :
                begin
                  uitbreiding := true;
                  if (teller2 mod 2) = 0 then
                    wissel_perfect := false;
                end
              else
                uitbreiding := false;
              end;

              if wissel_perfect then
                hoe_perfect := soort
              else
                hoe_perfect := soort-1;

              tellertje := 0;
              repeat
                inc(tellertje);
                n_conflict := 0;
                not_conflict := 0;
                for i := 1 to n_soort[soort] do
                  begin
                    gewisseld := false;
                    aantalA := aa_soorten_in_poulelijst(soort,poulesA,i);
                    aantalB := aa_soorten_in_poulelijst(soort,poulesB,i);
                    if ((abs(aantalA-aantalB) > verschil[i])
                     and (((soort mod aa_basis_soorten) <> 0) or (i <> 1) or land1)) then
                      begin
                        inc(n_conflict);
                        if (((soort mod aa_basis_soorten) = 0) and (i = 1)) then
                          inc(not_conflict);
                        if aantalA < aantalB then
    {in poulesA komen de poules waar er teveel spelers van ploeg i inzitten}
                          begin
                            wissel := poulesA;
                            poulesA := poulesB;
                            poulesB := wissel;
                            wissel2 := aantalA;
                            aantalA := aantalB;
                            aantalB := wissel2;
                          end;
                        poulelijst_min_1(poulesA1,poulesA,verboden);
                        if not uitbreiding then
                          begin
                            poulesA2 := poulesA1;
                            poulelijst_min_1(poulesB2,poulesB,verboden);
                          end
                        else
                          begin
                            poulesA2 := de_poules;
                            poulesB2 := de_poules;
                          end;
                        k := 0;
                        while ((not gewisseld) and (k < poulesA1.aantal)) do
                          begin
                            inc(k);
                            j1 := 0;
                            repeat
                              inc(j1);
                              l := 0;
                              while ((not gewisseld) and (l < poulesB2.aantal)) do
                                begin
                                  inc(l);
                                  mogelijk := true;
                                  if uitbreiding then
                                    begin
                                      for j := 1 to poulesA.aantal do
                                        if poulesB2.lijst[l] = poulesA.lijst[j] then
                                          mogelijk := false;
                                      if n_wissels = 2 then
                                        begin
                                          for j := 1 to aa_onmog_uitbr2[i] do
                                            if poulesB2.lijst[l] = onmog_uitbr2[i,j] then
                                              mogelijk := false;
                                        end
                                      else if n_wissels = 4 then
                                        begin
                                          for j := 1 to aa_onmog_uitbr4[i] do
                                            if poulesB2.lijst[l] = onmog_uitbr4[i,j] then
                                              mogelijk := false;
                                        end
                                      else if n_wissels = 3 then
                                        begin
                                          for j := 1 to aa_onmog_uitbr3[i] do
                                            if poulesB2.lijst[l] = onmog_uitbr3[i,j] then
                                              mogelijk := false;
                                        end;
                                    end;
                                  if mogelijk then
                                    begin
                                      j2 := 0;
                                      repeat
                                        inc(j2);
                                        wisselbaar := true;
                                        wisselsoort[1] := spelers[poule[poulesA1.lijst[k],j1],soort+1];
                                        wisselsoort[2] := spelers[poule[poulesB2.lijst[l],j2],soort+1];
                                        if ((spelers[poule[poulesA1.lijst[k],j1],1]
                                           <> spelers[poule[poulesB2.lijst[l],j2],1])
                                         or (wisselsoort[1] <> i) or (wisselsoort[2] = i)) then
                                          begin
                                            wisselbaar := false;
                                          end;
                                        if wisselbaar then
                                          begin
                                            if n_wissels = 2 then
                                              begin
                                                plaatsen[1,1] := poulesA1.lijst[k];
                                                plaatsen[2,1] := j1;
                                                plaatsen[1,2] := poulesB2.lijst[l];
                                                plaatsen[2,2] := j2;
                                            if ( (soorten_te_wisselen(plaatsen,aa_soorten,2,kleiner,reekshoofden,land1))
                                             and (tabel_te_wisselen(plaatsen,hoe_perfect,2,kleiner,reekshoofden,land1)) ) then
                                                  begin
                                                    wissel2 := poule[poulesA1.lijst[k],j1];
                                                    poule[poulesA1.lijst[k],j1] := poule[poulesB2.lijst[l],j2];
                                                    poule[poulesB2.lijst[l],j2] := wissel2;
                                                    gewisseld := true;
                                                    een_subsoort_in_soort(een,poulesA,poulesB);
                                                    tabelverschil(soort,poulesA,poulesB,verschil,een,false);
                                                    writeln('2');
                                                    if uitbreiding then
                                                      begin
                                                        inc(aa_onmog_uitbr2[i]);
                                                        onmog_uitbr2[i,aa_onmog_uitbr2[i]] := poulesB2.lijst[l];
                                                      end;
                                                    if not wissel_perfect then
                                                      begin
                                                        stop := true;
                                                        if uitbreiding then
                                                          stoppen := false;
                                                      end;
                                                  end
                                              end
                                            else if n_wissels = 4 then
                                              begin
                                                ongeldig := true;
                                                m := 0;
                                                repeat
                                                  inc(m);
                                                  if (m <> j1) then
                                                    begin
                                                      n := 0;
                                                      repeat
                                                        inc(n);
                                                        if (n <> j2) then
                                                          begin
                                                            plaatsen[1,1] := poulesA1.lijst[k];
                                                            plaatsen[2,1] := j1;
                                                            plaatsen[1,2] := poulesB2.lijst[l];
                                                            plaatsen[2,2] := j2;
                                                            plaatsen[1,3] := poulesA1.lijst[k];
                                                            plaatsen[2,3] := m;
                                                            plaatsen[1,4] := poulesB2.lijst[l];
                                                            plaatsen[2,4] := n;
                                                            if ((spelers[poule[poulesB2.lijst[l],n],1]
                                                                = spelers[poule[poulesA1.lijst[k],m],1])
                                              and (soorten_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))
                                              and (tabel_te_wisselen(plaatsen,hoe_perfect,4,kleiner,reekshoofden,land1))) then
                                                              ongeldig := false;
                                                          end;
                                                      until (not ongeldig or (n = n_poulespelers));
                                                    end;
                                                until (not ongeldig or (m = n_poulespelers));
                                                if not ongeldig then
                                                  begin
                                                    wissel2 := poule[poulesA1.lijst[k],j1];
                                                    poule[poulesA1.lijst[k],j1] := poule[poulesB2.lijst[l],j2];
                                                    poule[poulesB2.lijst[l],j2] := wissel2;
                                                    wissel2 := poule[poulesA1.lijst[k],m];
                                                    poule[poulesA1.lijst[k],m] := poule[poulesB2.lijst[l],n];
                                                    poule[poulesB2.lijst[l],n] := wissel2;
                                                    gewisseld := true;
                                                    een_subsoort_in_soort(een,poulesA,poulesB);
                                                    tabelverschil(soort,poulesA,poulesB,verschil,een,false);
                                                    writeln('4');
                                                    if uitbreiding then
                                                      begin
                                                        inc(aa_onmog_uitbr4[i]);
                                                        onmog_uitbr4[i,aa_onmog_uitbr4[i]] := poulesB2.lijst[l];
                                                      end;
                                                    if not wissel_perfect then
                                                      begin
                                                        stop := true;
                                                        if uitbreiding then
                                                          stoppen := false;
                                                      end;
                                                  end
                                                else
                                                  begin
                                                    k2 := 0;
                                                    while (ongeldig and (k2 < poulesA2.aantal)) do
                                                      begin
                                                        inc(k2);
                                                        if ((poulesA2.lijst[k2] <> poulesA1.lijst[k])
                                                         and (poulesA2.lijst[k2] <> poulesB2.lijst[l])) then
                                                          begin
                                                            m := 0;
                                                            repeat
                                                              inc(m);
                                                              l2 := 0;
                                                              while (ongeldig and (l2 < poulesB2.aantal)) do
                                                                begin
                                                                  inc(l2);
                                                                  if ((poulesB2.lijst[l2] <> poulesB2.lijst[l])
                                                                   and (poulesB2.lijst[l2] <> poulesA1.lijst[k])
                                                                   and (poulesB2.lijst[l2] <> poulesA2.lijst[k2])) then
                                                                    begin
                                                                      n := 0;
                                                                      repeat
                                                                        inc(n);
                                                                        plaatsen[1,1] := poulesA1.lijst[k];
                                                                        plaatsen[2,1] := j1;
                                                                        plaatsen[1,2] := poulesB2.lijst[l];
                                                                        plaatsen[2,2] := j2;
                                                                        plaatsen[1,3] := poulesA2.lijst[k2];
                                                                        plaatsen[2,3] := m;
                                                                        plaatsen[1,4] := poulesB2.lijst[l2];
                                                                        plaatsen[2,4] := n;
                                                                        if ((spelers[poule[poulesB2.lijst[l2],n],1]
                                                                            = spelers[poule[poulesA2.lijst[k2],m],1])
                                              and (soorten_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))
                                              and (tabel_te_wisselen(plaatsen,hoe_perfect,4,kleiner,reekshoofden,land1))) then
                                                                          ongeldig := false;
                                                                      until (not ongeldig or (n = n_poulespelers));
                                                                    end;
                                                                end;
                                                            until (not ongeldig or (m = n_poulespelers));
                                                          end;
                                                      end;
                                                    if not ongeldig then
                                                      begin
                                                        wissel2 := poule[poulesA1.lijst[k],j1];
                                                        poule[poulesA1.lijst[k],j1] := poule[poulesB2.lijst[l],j2];
                                                        poule[poulesB2.lijst[l],j2] := wissel2;
                                                        wissel2 := poule[poulesA2.lijst[k2],m];
                                                        poule[poulesA2.lijst[k2],m] := poule[poulesB2.lijst[l2],n];
                                                        poule[poulesB2.lijst[l2],n] := wissel2;
                                                        gewisseld := true;
                                                        een_subsoort_in_soort(een,poulesA,poulesB);
                                                        tabelverschil(soort,poulesA,poulesB,verschil,een,false);
                                                        writeln('4_twee');
                                                        if uitbreiding then
                                                          begin
                                                            inc(aa_onmog_uitbr4[i]);
                                                            onmog_uitbr4[i,aa_onmog_uitbr4[i]] := poulesA1.lijst[k];
                                                          end;
                                                        if not wissel_perfect then
                                                          begin
                                                            stop := true;
                                                            if uitbreiding then
                                                              stoppen := false;
                                                          end;
                                                      end;
                                                  end;
                                              end
                                            else if n_wissels = 3 then
                                              begin
                                                ongeldig := true;
                                                r := 0;
                                                while (ongeldig and (r < de_poules.aantal)) do
                                                  begin
                                                    inc(r);
                                                    if ((de_poules.lijst[r] <> poulesA1.lijst[k])
                                                     and (de_poules.lijst[r] <> poulesB2.lijst[l])) then
                                                      begin
                                                        s := 0;
                                                        repeat
                                                          inc(s);
                                                          if (spelers[poule[poulesB2.lijst[l],j2],1]
                                                              = spelers[poule[de_poules.lijst[r],s],1]) then
                                                            begin
                                                              {1 -> 2, 2 -> 3, 3 -> 1}
                                                              plaatsen[1,1] := poulesA1.lijst[k];
                                                              plaatsen[2,1] := j1;
                                                              plaatsen[1,2] := poulesB2.lijst[l];
                                                              plaatsen[2,2] := j2;
                                                              plaatsen[1,3] := de_poules.lijst[r];
                                                              plaatsen[2,3] := s;
                                              if ((soorten_te_wisselen(plaatsen,aa_soorten,3,kleiner,reekshoofden,land1))
                                               and (tabel_te_wisselen(plaatsen,hoe_perfect,3,kleiner,reekshoofden,land1))) then
                                                                ongeldig := false;
                                                            end;
                                                        until (not ongeldig or (s = n_poulespelers));
                                                      end;
                                                  end;
                                                if not ongeldig then
                                                  begin
                                                    wissel2 := poule[poulesA1.lijst[k],j1];
                                                    poule[poulesA1.lijst[k],j1] := poule[de_poules.lijst[r],s];
                                                    poule[de_poules.lijst[r],s] := poule[poulesB2.lijst[l],j2];
                                                    poule[poulesB2.lijst[l],j2] := wissel2;
                                                    gewisseld := true;
                                                    een_subsoort_in_soort(een,poulesA,poulesB);
                                                    tabelverschil(soort,poulesA,poulesB,verschil,een,false);
                                                    writeln('3');
                                                    if uitbreiding then
                                                      begin
                                                        inc(aa_onmog_uitbr3[i]);
                                                        onmog_uitbr3[i,aa_onmog_uitbr3[i]] := poulesB2.lijst[l];
                                                      end;
                                                    if not wissel_perfect then
                                                      begin
                                                        stop := true;
                                                        stoppen := false;
                                                      end;
                                                  end
                                              end
                                          end
                                      until (gewisseld) or (j2 = n_poulespelers);
                                    end;
                                end;
                            until (gewisseld) or (j1 = n_poulespelers);
                          end;
                      end;
                  end;
              until ((tellertje > 10) or stop or (not gewisseld) or (n_conflict = 0));
              if (teller mod 18) = 1 then
                old_n_conflict := n_conflict;
            until ((n_conflict = 0) or ((teller mod 18 = 0) and (n_conflict = old_n_conflict)) or (teller > 180));
            writeln('soort: ',soort,' aa_confl: ',n_conflict - not_conflict,'  aa_stappen: ',teller);
            aa_problems := aa_problems + n_conflict - not_conflict;
            if n_conflict <> 0 then
              begin
                stoppen := false;
              end;
          end;
      end;
  until ((teller2 > 4) or stoppen);
end;

function reekshoofd2en3_te_wisselen(var plaats : pouleplaatsen;aantal : byte) : boolean;
var i, a, q, niet_pos : integer;
    geldig : boolean;
begin
  geldig := true;
  i := 0;
  repeat
    inc(i);
    if ((i mod aa_basis_soorten) <> 0) then
      begin
        a := 0;
        repeat
          inc(a);
          q := (a mod aantal) + 1;
          if plaats[2,q] <= 2 then
            begin
              niet_pos := (plaats[2,q] mod 2) + 1;
              if (spelers[poule[plaats[1,a],plaats[2,a]],i+1] = spelers[poule[plaats[1,q],niet_pos],i+1]) then
                begin
                  geldig := false;
                end;
            end;
        until (not geldig or (a = aantal));
      end;
  until (not geldig or (i = aa_soorten));
  reekshoofd2en3_te_wisselen := geldig;
end;

function reekshoofd4_te_wisselen(var plaats : pouleplaatsen) : boolean;
var i, a, q, niet_pos : integer;
    geldig : boolean;
    plaats2 : pouleplaatsen;
begin
  geldig := true;
  i := 0;
  if ((plaats[1,1] <> plaats[1,3]) and (plaats[1,2] <> plaats[1,4])) then
    repeat
      inc(i);
      plaats2[1,1] := plaats[1,(i*2)-1];
      plaats2[2,1] := plaats[2,(i*2)-1];
      plaats2[1,2] := plaats[1,i*2];
      plaats2[2,2] := plaats[2,i*2];
      geldig := reekshoofd2en3_te_wisselen(plaats2,2);
    until (not geldig or (i = 2))
  else
    begin
      repeat
        inc(i);
        if ((i mod aa_basis_soorten) <> 0) then
          begin
            a := 0;
            repeat
              inc(a);
              q := (a mod 2) + 1;
              if ((plaats[2,q] <= 2) or (plaats[2,q+2] <= 2)) then
                begin
                  if ((plaats[2,q] <= 2) and (plaats[2,q+2] <= 2)) then
                    begin
                      if (spelers[poule[plaats[1,a],plaats[2,a]],i+1] = spelers[poule[plaats[1,a+2],plaats[2,a+2]],i+1]) then
                        geldig := false;
                    end
                  else if (plaats[2,q] <= 2) then
                    begin
                      niet_pos := (plaats[2,q] mod 2) + 1;
                      if (spelers[poule[plaats[1,a],plaats[2,a]],i+1] = spelers[poule[plaats[1,q],niet_pos],i+1]) then
                        geldig := false;
                    end
                  else
                    begin
                      niet_pos := (plaats[2,q+2] mod 2) + 1;
                      if (spelers[poule[plaats[1,a+2],plaats[2,a+2]],i+1] = spelers[poule[plaats[1,q+2],niet_pos],i+1]) then
                        geldig := false;
                    end;
                end;
            until (not geldig or (a = 2));
          end;
      until (not geldig or (i = aa_soorten));
    end;
  reekshoofd4_te_wisselen := geldig;
end;

function reekshoofden_te_wisselen(var plaats : pouleplaatsen; aantal : byte): boolean;
var geldig : boolean;
begin
  case aantal of
    2, 3 : geldig := reekshoofd2en3_te_wisselen(plaats,aantal);
    4    : geldig := reekshoofd4_te_wisselen(plaats);
  end;
  reekshoofden_te_wisselen := geldig;
end;

{Functie die de tornooitabel probeert te verbeteren indien die nog niet in
orde was. Indien de tabel verbeterd is, wordt de functie true}
function verbeter_tornooitabel(min_start, einde, aantal : integer;kleiner,reekshoofden, land1 : boolean) : boolean;
var i, start, j : integer;
    tmppoule : poule_array;
    tot_problems : array[1..aa_soorten] of integer;
    slechter, verbeterd : boolean;
begin
  {!!anders dan in 22!!}
  verbeter_tornooitabel := false;
  start := 0;
  i := min_start - 1;
  repeat
    inc(i);
    if n_tab_problems[i] > 0 then
      start := i;
  until ((start <> 0) or (i = einde{aa_soorten}));
  if start <> 0 then
    begin
      tmppoule := poule;
      slechter := false;
      verbeterd := false;
      for j := 1 to aantal do
        begin
          for i := start to einde{aa_soorten} do
            begin
              verfijn_tornooitabel(i,0,tot_problems[i],kleiner,reekshoofden,land1);
              if ((j = aantal) and (tot_problems[i] > n_tab_problems[i])) then
                slechter := true;
              if ((j = aantal) and (tot_problems[i] < n_tab_problems[i])) then
                verbeterd := true;
            end;
        end;
      if not slechter and verbeterd then
        begin
          verbeter_tornooitabel := true;
          writeln('VERBETERD! aantal = ',aantal);
          for i := start to einde{aa_soorten} do
            begin
              if tot_problems[i] < n_tab_problems[i] then
                n_tab_problems[i] := tot_problems[i];
            end;
        end
      else
        begin
          poule := tmppoule;
        end;
    end;
end;

procedure verfijn_reekshoofden(soort : byte;kleiner,reekshoofden, land1 : boolean);
var i, j, j1, j2, k, l, k2, l2, m, n, teller, wissel, n_conflict, tellertje,
    niet_j1, niet_j2, old_n_conflict : integer;
    tot_problems : array[1..aa_soorten] of integer;
    gewisseld, wisselbaar, ongeldig, wissel_perfect, stop, wissel_verkeerd,
    slechter, tabel_correct, gewisseld_reeksh : boolean;
    confl_reeksh : poulelist;
    plaatsen : pouleplaatsen;
    tmppoule : poule_array;
begin
  teller := 0;
  repeat
    gewisseld_reeksh := false;
    inc(teller);
    stop := false;
    wissel_perfect := true;
    wissel_verkeerd := false;
    if ((teller mod 2) = 0) then
      wissel_perfect := false;
    if ((teller mod 3) = 0) then
      wissel_verkeerd := true;

    tellertje := 0;
    repeat
      inc(tellertje);
      n_conflict := 0;
      gewisseld := false;
      for i := 1 to n_poules do
        begin
          if spelers[poule[i,1],soort+1] = spelers[poule[i,2],soort+1] then
            begin
              gewisseld := false;
              j := 3;
              while ((j <= n_poulespelers) and (spelers[poule[i,2],1] = spelers[poule[i,j],1])) do
                begin
                  if spelers[poule[i,2],soort+1] <> spelers[poule[i,j],soort+1] then
                    begin
                      wissel := poule[i,2];
                      poule[i,2] := poule[i,j];
                      poule[i,j] := wissel;
                      j := n_poulespelers;
                      gewisseld := true;
                    end;
                  inc(j);
                end;
              if not gewisseld then
                begin
                  inc(n_conflict);
                  confl_reeksh[n_conflict] := i;
                end;
            end;
        end;
      if n_conflict <> 0 then
        begin
          k := 0;
          repeat
            inc(k);
            j1 := 2;
            repeat
              l := 0;
              repeat
                inc(l);
                j2 := 2;
                repeat
                  wisselbaar := true;
                  if ((spelers[poule[confl_reeksh[k],j1],soort+1] = spelers[poule[l,j2],soort+1])
                   or (spelers[poule[confl_reeksh[k],j1],1] <> spelers[poule[l,j2],1])) then
                    begin
                      wisselbaar := false;
                    end;
                  if wissel_perfect then
                    begin
                      niet_j1 := (j1 mod 2) + 1;
                      niet_j2 := (j2 mod 2) + 1;
                      if ((spelers[poule[confl_reeksh[k],j1],soort+1] = spelers[poule[l,niet_j2],soort+1])
                       or (spelers[poule[confl_reeksh[k],niet_j1],soort+1] = spelers[poule[l,j2],soort+1])) then
                        begin
                          wisselbaar := false;
                        end;
                    end;
                  ongeldig := true;
                  if wisselbaar then
                    begin
                      plaatsen[1,1] := confl_reeksh[k];
                      plaatsen[2,1] := j1;
                      plaatsen[1,2] := l;
                      plaatsen[2,2] := j2;
                      if ((soorten_te_wisselen(plaatsen,aa_soorten,2,kleiner,reekshoofden,land1))
                       and (tabel_te_wisselen(plaatsen,aa_soorten,2,kleiner,reekshoofden,land1))) then
                        ongeldig := false;
                      if not ongeldig then
                        begin
                          wissel := poule[confl_reeksh[k],j1];
                          poule[confl_reeksh[k],j1] := poule[l,j2];
                          poule[l,j2] := wissel;
                          gewisseld := true;
                          gewisseld_reeksh := true;
                          if not wissel_perfect then
                            stop := true;
                        end
                      else
                        begin
                         if wissel_perfect then
                            m := 2
                          else
                            m := j1;
                          while ((m < n_poulespelers) and ongeldig) do
                            begin
                              inc(m);
                              if wissel_perfect then
                                n := 2
                              else
                                n := j2;
                              while ((n < n_poulespelers) and ongeldig) do
                                begin
                                  inc(n);
                                  if (spelers[poule[confl_reeksh[k],m],1] = spelers[poule[l,n],1]) then
                                    begin
                                      plaatsen[1,1] := confl_reeksh[k];
                                      plaatsen[2,1] := j1;
                                      plaatsen[1,2] := l;
                                      plaatsen[2,2] := j2;
                                      plaatsen[1,3] := confl_reeksh[k];
                                      plaatsen[2,3] := m;
                                      plaatsen[1,4] := l;
                                      plaatsen[2,4] := n;
                                      if not wissel_verkeerd then
                                        begin
                                          slechter := true;
                                          if ((soorten_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))
                                           and (tabel_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))) then
                                            ongeldig := false
                                        end
                                      else
                                        begin
                                          if ((soorten_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))
                                           and not (tabel_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))) then
                                            begin
                                              tmppoule := poule;
                                              wissel := poule[confl_reeksh[k],j1];
                                              poule[confl_reeksh[k],j1] := poule[l,j2];
                                              poule[l,j2] := wissel;
                                              wissel := poule[confl_reeksh[k],m];
                                              poule[confl_reeksh[k],m] := poule[l,n];
                                              poule[l,n] := wissel;
                                              slechter := false;
                                              for i := 1 to aa_soorten do
                                                begin
                                          verfijn_tornooitabel(i,confl_reeksh[k],tot_problems[i],kleiner,reekshoofden,land1);
                                                  if tot_problems[i] > n_tab_problems[i] then
                                                    slechter := true;
                                                end;
                                              writeln(tot_problems[1]);
                                              if not slechter then
                                                begin
                                                  for i := 1 to aa_soorten do
                                                    begin
                                                      if tot_problems[i] < n_tab_problems[i] then
                                                        n_tab_problems[i] := tot_problems[i];
                                                    end;
                                                  gewisseld := true;
                                                  gewisseld_reeksh := true;
                                                  if not wissel_perfect then
                                                    stop := true
                                                end
                                              else
                                                begin
                                                  poule := tmppoule;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                          if not ongeldig then
                            begin
                              wissel := poule[confl_reeksh[k],j1];
                              poule[confl_reeksh[k],j1] := poule[l,j2];
                              poule[l,j2] := wissel;
                              wissel := poule[confl_reeksh[k],m];
                              poule[confl_reeksh[k],m] := poule[l,n];
                              poule[l,n] := wissel;
                              gewisseld := true;
                              gewisseld_reeksh := true;
                              if not wissel_perfect then
                                stop := true;
                            end
                          else if slechter then
                            begin
                              k2 := 0;
                              repeat
                                inc(k2);
                                if ((k2 <> confl_reeksh[k]) and (k2 <> l)) then
                                  begin
                                    m := 0;
                                    repeat
                                      inc(m);
                                      l2 := 0;
                                      repeat
                                        inc(l2);
                                        if ((l2 <> confl_reeksh[k]) and (l2 <> l) and (l2 <> k2)) then
                                          begin
                                            n := 0;
                                            repeat
                                              inc(n);
                                              if (spelers[poule[k2,m],1] = spelers[poule[l2,n],1]) then
                                                begin
                                                  plaatsen[1,1] := confl_reeksh[k];
                                                  plaatsen[2,1] := j1;
                                                  plaatsen[1,2] := l;
                                                  plaatsen[2,2] := j2;
                                                  plaatsen[1,3] := k2;
                                                  plaatsen[2,3] := m;
                                                  plaatsen[1,4] := l2;
                                                  plaatsen[2,4] := n;
                                              if ((soorten_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))
                                               and (tabel_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))) then
                                                    ongeldig := false;
                                                end;
                                            until ((not ongeldig) or (n = n_poulespelers));
                                          end;
                                      until ((not ongeldig) or (l2 = n_poules));
                                    until ((not ongeldig) or (m = n_poulespelers));
                                  end;
                              until ((not ongeldig) or (k2 = n_poules));
                              if not ongeldig then
                                begin
                                  wissel := poule[confl_reeksh[k],j1];
                                  poule[confl_reeksh[k],j1] := poule[l,j2];
                                  poule[l,j2] := wissel;
                                  wissel := poule[k2,m];
                                  poule[k2,m] := poule[l2,n];
                                  poule[l2,n] := wissel;
                                  gewisseld := true;
                                  gewisseld_reeksh := true;
                                  if not wissel_perfect then
                                    stop := true;
                                end;
                            end;
                        end;
                    end;
                  dec(j2);
                until (gewisseld) or (j2 = 0);
              until (gewisseld) or (l = n_poules);
              dec(j1);
            until (gewisseld) or (j1 = 0);
          until (gewisseld) or (k = n_conflict);
        end;
    until ((tellertje > 10) or stop or (not gewisseld) or (n_conflict = 0));
    tabel_correct := true;
    for i := 1 to aa_soorten do
      if n_tab_problems[i] > 0 then
        tabel_correct := false;
    if (not tabel_correct and gewisseld_reeksh and (teller < 60)) then
      begin
        if verbeter_tornooitabel(1,aa_soorten,aa_verbeteringen,kleiner,reekshoofden,land1) then
          begin
            n_conflict := maxint;       {wlk. getal groot getal <> 0}
            old_n_conflict := maxint-1; {wlk. getal groot getal <> 0}
          end;
      end;
    if (teller mod 12) = 1 then
      old_n_conflict := n_conflict;
  until ((n_conflict = 0) or ((teller mod 6 = 0) and (n_conflict = old_n_conflict)) or (teller > 60));
  writeln('teller: ',teller);
  if n_conflict <> 0 then
    begin
      if n_conflict = 1 then
        write('Er is nog ',n_conflict,' reekshoofdenconflict ')
      else
        write('Er zijn nog ',n_conflict,' reekshoofdenconflicten ');
      case (soort mod aa_basis_soorten) of
        1 : writeln('op ploegniveau!');
        2 : writeln('op provincieniveau!');
        0 : writeln('op landenniveau!');
      end;
    end;
end;

procedure zoek_vglplaatsen(var vglplaats, plaats : pouleplaatsen;aantal : byte);
var a, i, j, z : integer;
begin
  fillchar(vglplaats,sizeOf(vglplaats),0);
  for a := 1 to aantal do
    begin
      i := 0;
      while ((vglplaats[1,a] = 0) and (i < n_vglpoules)) do
        begin
          inc(i);
          j := 0;
          while ((vglplaats[1,a] = 0) and (j < n_vglpoulespelers)) do
            begin
              inc(j);
              z := 1;
              while ((gegevenstabel[poule[plaats[1,a],plaats[2,a]],z] = vglgegevenstabel[vglpoule[i,j],z])
               and (z <= aa_var)) do
                begin
                  inc(z);
                end;
              if z = 7 then
                begin
                  vglplaats[1,a] := i;
                  vglplaats[2,a] := j;
                end;
            end;
        end;
    end;
end;

function reeks2en3_te_wisselen(var plaats : pouleplaatsen;aantal : byte): boolean;
var a, i, j, z, q : integer;
    vglplaats : pouleplaatsen;
    geldig : boolean;
begin
  zoek_vglplaatsen(vglplaats,plaats,aantal);
  geldig := true;
  a := 0;
  repeat
    inc(a);
    if vglplaats[1,a] <> 0 then
      begin
        q := (a mod aantal) + 1;
        for i := 1 to n_poulespelers do
          begin
            if (i <> plaats[2,q]) then
              begin
                for j := 1 to n_vglpoulespelers do
                  begin
                    if (j <> vglplaats[2,a]) then
                      begin
                        z := 1;
                        while ((gegevenstabel[poule[plaats[1,q],i],z] = vglgegevenstabel[vglpoule[vglplaats[1,a],j],z])
                         and (z <= aa_var)) do
                          begin
                            inc(z);
                          end;
                        if z = 7 then
                          geldig := false;
                      end;
                  end;
              end;
          end;
      end;
  until (not geldig or (a = aantal));
  reeks2en3_te_wisselen := geldig;
end;

function reeks4_te_wisselen(var plaats : pouleplaatsen) : boolean;
var i, a, p, q, r, j, z : integer;
    geldig : boolean;
    vglplaats : pouleplaatsen;
begin
  geldig := true;
  i := 0;
  if ((plaats[1,1] <> plaats[1,3]) and (plaats[1,2] <> plaats[1,4])) then
    repeat
      inc(i);
      vglplaats[1,1] := plaats[1,(i*2)-1];
      vglplaats[2,1] := plaats[2,(i*2)-1];
      vglplaats[1,2] := plaats[1,i*2];
      vglplaats[2,2] := plaats[2,i*2];
      geldig := reeks2en3_te_wisselen(vglplaats,2);
    until ((i=2) or (geldig = false))
  else
    begin
      zoek_vglplaatsen(vglplaats,plaats,4);
      a := 0;
      repeat
        inc(a);
        q := (2 * ((a-1) div 2)) + (a mod 2) + 1;
        if a <= 2 then
          p := a + 2
        else
          p := a - 2;
        r := (2 * ((p-1) div 2)) + (p mod 2) + 1;
        if ((vglplaats[1,a] <> 0) or (vglplaats[1,p] <> 0)) then
          begin
            for i := 1 to n_poulespelers do
              begin
                if ((i <> plaats[2,q]) and (i <> plaats[2,r])) then
                  begin
                    for j := 1 to n_vglpoulespelers do
                      begin
                        if (j <> vglplaats[2,a]) then
                          begin
                            z := 1;
                            while ((gegevenstabel[poule[plaats[1,q],i],z]
                                  = vglgegevenstabel[vglpoule[vglplaats[1,a],j],z])
                             and (z <= aa_var)) do
                              begin
                                inc(z);
                              end;
                            if z = 7 then
                              geldig := false;
                          end;
                      end;
                  end;
              end;
          end;
      until (not geldig or (a = 4));
    end;
  reeks4_te_wisselen := geldig;
end;

function reeksen_te_wisselen(var plaats : pouleplaatsen;aantal : byte) : boolean;
var geldig : boolean;
begin
  case aantal of
    2, 3 : geldig := reeks2en3_te_wisselen(plaats,aantal);
    4    : geldig := reeks4_te_wisselen(plaats);
  end;
  reeksen_te_wisselen := geldig;
end;

procedure vergelijk_reeksen(kleiner, reekshoofden, land1 : boolean);
var i, j, k, l, z, a, b, j2, c, d, m, n, r, s, wissel, teller, n_conflict,
    n_wissels, old_n_conflict : integer;
    gewisseld, wissel_perfect : boolean;
    plaatsen : pouleplaatsen;
begin
  teller := 0;
  repeat
    inc(teller);
    n_conflict := 0;

    case (teller mod 15) of
      2, 5, 11, 14 : wissel_perfect := false
    else wissel_perfect := true;
    end;
    case (teller mod 15) of
      4, 5, 7 : n_wissels := 4;
      10, 11, 13 : n_wissels := 3
    else n_wissels := 2;
    end;

    for i := 1 to n_poules do
      begin
        for j := 1 to n_poulespelers do
          begin
            for k := 1 to n_vglpoules do
              begin
                for l := 1 to n_vglpoulespelers do
                  begin
                    z := 1;
                    while ((gegevenstabel[poule[i,j],z] = vglgegevenstabel[vglpoule[k,l],z]) and (z <= aa_var)) do
                      begin
                        inc(z);
                      end;
                    if z = 7 then
                      begin
                        for a := 1 to n_poulespelers do
                          begin
                            if (a <> j) then
                              begin
                                for b := 1 to n_vglpoulespelers do
                                  begin
                                    if (b <> l) then
                                      begin
                                        z := 1;
                                        while ((gegevenstabel[poule[i,a],z] = vglgegevenstabel[vglpoule[k,b],z])
                                         and (z <= aa_var)) do
                                          begin
                                            inc(z);
                                          end;
                                        if z = 7 then
                                          begin
                                            writeln(gegevenstabel[poule[i,j],1],gegevenstabel[poule[i,a],1]);
                                            inc(n_conflict);
                                            gewisseld := false;
                                            z := 0;
                                            repeat
                                              inc(z);
                                              case z of
                                                1 : j2 := j;
                                                2 : j2 := a;
                                              end;
                                              c := 0;
                                              repeat
                                                inc(c);
                                                if (c <> i) then
                                                  begin
                                                    d := 0;
                                                    repeat
                                                      inc(d);
                                                      if spelers[poule[i,j2],1] = spelers[poule[c,d],1] then
                                                        begin
                                                          if n_wissels = 2 then
                                                            begin
                                                              plaatsen[1,1] := i;
                                                              plaatsen[2,1] := j2;
                                                              plaatsen[1,2] := c;
                                                              plaatsen[2,2] := d;
                                                    if ((soorten_te_wisselen(plaatsen,aa_soorten,2,kleiner,reekshoofden,land1))
                                                     and (tabel_te_wisselen(plaatsen,aa_soorten,2,kleiner,reekshoofden,land1))
                                                     and (reekshoofden_te_wisselen(plaatsen,2))
                                                     and ( (reeksen_te_wisselen(plaatsen,2) )
                                                      or ( not wissel_perfect ) )) then
                                                                begin
                                                                  wissel := poule[i,j2];
                                                                  poule[i,j2] := poule[c,d];
                                                                  poule[c,d] := wissel;
                                                                  gewisseld := true;
                                                                end;
                                                            end
                                                          else if n_wissels = 4 then
                                                            begin
                                                              m := 0;
                                                              while ((m < n_poulespelers) and not gewisseld) do
                                                                begin
                                                                  inc(m);
                                                                  if m <> j2 then
                                                                    begin
                                                                      n := 0;
                                                                      while ((n < n_poulespelers) and not gewisseld) do
                                                                        begin
                                                                          inc(n);
                                                                          if ( (n <> d)
                                                                           and (spelers[poule[i,m],1]
                                                                               = spelers[poule[c,n],1])) then
                                                                            begin
                                                                              plaatsen[1,1] := i;
                                                                              plaatsen[2,1] := j2;
                                                                              plaatsen[1,2] := c;
                                                                              plaatsen[2,2] := d;
                                                                              plaatsen[1,3] := i;
                                                                              plaatsen[2,3] := m;
                                                                              plaatsen[1,4] := c;
                                                                              plaatsen[2,4] := n;
                                                    if ((soorten_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))
                                                     and (tabel_te_wisselen(plaatsen,aa_soorten,4,kleiner,reekshoofden,land1))
                                                     and (reekshoofden_te_wisselen(plaatsen,4))
                                                     and ( (reeksen_te_wisselen(plaatsen,4) )
                                                      or ( not wissel_perfect ) )) then
                                                                                begin
                                                                                  wissel := poule[i,j2];
                                                                                  poule[i,j2] := poule[c,d];
                                                                                  poule[c,d] := wissel;
                                                                                  wissel := poule[i,m];
                                                                                  poule[i,m] := poule[c,n];
                                                                                  poule[c,n] := wissel;
                                                                                  gewisseld := true;
                                                                                end;
                                                                            end;
                                                                        end;
                                                                    end;
                                                                end;
                                                            end
                                                          else if n_wissels = 3 then
                                                            begin
                                                              r := 0;
                                                              while ((r < n_poules) and not gewisseld) do
                                                                begin
                                                                  inc(r);
                                                                  if ((r <> i) and (r <> c)) then
                                                                    begin
                                                                      s := 0;
                                                                      repeat
                                                                        inc(s);
                                                                        if (spelers[poule[i,j2],1]
                                                                         = spelers[poule[r,s],1]) then
                                                                          begin
                                                                            {1 -> 2, 2 -> 3, 3 -> 1}
                                                                            plaatsen[1,1] := i;
                                                                            plaatsen[2,1] := j2;
                                                                            plaatsen[1,2] := c;
                                                                            plaatsen[2,2] := d;
                                                                            plaatsen[1,3] := r;
                                                                            plaatsen[2,3] := s;
                                                    if ((soorten_te_wisselen(plaatsen,aa_soorten,3,kleiner,reekshoofden,land1))
                                                     and (tabel_te_wisselen(plaatsen,aa_soorten,3,kleiner,reekshoofden,land1))
                                                     and (reekshoofden_te_wisselen(plaatsen,3))
                                                     and ( (reeksen_te_wisselen(plaatsen,3) )
                                                      or ( not wissel_perfect ) )) then
                                                                              begin
                                                                                wissel := poule[i,j2];
                                                                                poule[i,j2] := poule[r,s];
                                                                                poule[r,s] := poule[c,d];
                                                                                poule[c,d] := wissel;
                                                                                gewisseld := true;
                                                                              end;
                                                                          end;
                                                                      until (gewisseld or (s = n_poulespelers));
                                                                    end;
                                                                end;
                                                            end;
                                                        end;
                                                    until (gewisseld or (d = n_poulespelers));
                                                  end;
                                              until (gewisseld or (c = n_poules));
                                            until (gewisseld or (z = 2));
                                          end;
                                      end;
                                  end;
                              end;
                          end;
                      end;
                  end;
              end;
          end;
      end;
    if (teller mod 15) = 1 then
      old_n_conflict := n_conflict;
  until ((n_conflict = 0) or ((teller mod 15 = 0) and (n_conflict = old_n_conflict)) or (teller > 150));
  writeln(teller);
  if n_conflict <> 0 then
    reeksen_correct := false;
end;

function n_soort_reekshoofden(soort, rh_soort : integer;kleiner : boolean) : integer;
begin
  if (soort <= aa_basis_soorten) = kleiner then
    n_soort_reekshoofden := n_reekshoofden_soort[rh_soort]
  else
    n_soort_reekshoofden := n_soort[soort];
end;

procedure maak_verdeling_ok_poules(soort : byte;kleiner : boolean);
var i, j, k, aa_spelers_soort, spelers_per_poule, rh_soort : integer;
begin
  rh_soort := reekshoofd_soort(soort,kleiner);
  for i := 1 to n_soort[soort] do
    begin
      spelers_per_poule := (soorten[i,soort*2] div n_poules);
      for j := 1 to n_poules do
        begin
          aa_spelers_soort := 0;
          for k := 1 to n_poulespelers do
            begin
              if spelers[poule[j,k],soort+1] = soorten[i,(soort*2)-1] then
                inc(aa_spelers_soort);
            end;
          if ((aa_spelers_soort < spelers_per_poule) or (aa_spelers_soort > spelers_per_poule + 1)) then
            begin
              verdeling_ok[i,((soort-1)*(aa_niveaus+2))+1] := false;
              if not ( (((soort <= aa_basis_soorten) = kleiner)
                and (i > n_reekshoofden_soort[rh_soort]))
               or (((soort mod aa_basis_soorten) = 0) and (i =1)) ) then
                inc(conflicten[2]);
            end;
        end;
    end;
end;

procedure maak_verdeling_ok_tabel(soort : byte;kleiner : boolean);
var i, a, b, einde, start, aantalA, aantalB, rh_soort : integer;
    poulesA, poulesB : poulelijst;
    verschil : lijstC;
    een : lijstD;
begin
  rh_soort := reekshoofd_soort(soort,kleiner);
  for a:= 1 to (tabel.macht2-1) do
    begin
      einde := 0;
      for b:= 1 to macht(2,a-1) do
        begin
          start := einde + 1;
          einde := (tabel.aantal div macht(2,a-1)) + einde;
          sub_tabel(start,einde,poulesA,poulesB);
          een_subsoort_in_soort(een,poulesA,poulesB);
          tabelverschil(soort,poulesA,poulesB,verschil,een,true);
          for i := 1 to n_soort[soort] do
            begin
              aantalA := aa_soorten_in_poulelijst(soort,poulesA,i);
              aantalB := aa_soorten_in_poulelijst(soort,poulesB,i);
              if abs(aantalA-aantalB) > verschil[i] then
                begin
                  verdeling_ok[i,((soort-1)*(aa_niveaus+2))+a+1] := false;
                  if not ( (((soort <= aa_basis_soorten) = kleiner)
                    and (i > n_reekshoofden_soort[rh_soort]))
                   or (((soort mod aa_basis_soorten) = 0) and (i =1)) ) then
                    inc(conflicten[4]);
                end;
            end;
        end;
    end;
end;

procedure maak_verdeling_ok_reeksh(soort : byte;kleiner : boolean);
var i, subsoort, rh_soort : integer;
begin
  rh_soort := reekshoofd_soort(soort,kleiner);
  for i := 1 to n_poules do
    begin
      if spelers[poule[i,1],soort+1] = spelers[poule[i,2],soort+1] then
        begin
          subsoort := spelers[poule[i,1],soort+1];
          verdeling_ok[subsoort,((soort-1)*(aa_niveaus+2))+tabel.macht2+1] := false;
          if not ( (((soort <= aa_basis_soorten) = kleiner)
            and (i > n_reekshoofden_soort[rh_soort]))
           or (((soort mod aa_basis_soorten) = 0) and (i =1)) ) then
            inc(conflicten[3]);
        end;
    end;
end;

function min_conflicten : integer;
var i, volgende_i, j, tmpnr : byte;
    nr : array[1..aa_verdelingen] of byte;
    gewisseld : boolean;
begin
  for i := 1 to aa_verdelingen do
    nr[i] := i;
  for j := 4 downto 1 do
    begin
      repeat
        gewisseld := false;
        for i := 1 to aa_verdelingen-1 do
          begin
            volgende_i := i+1;
            if tmpconflicten[j,nr[i]] > tmpconflicten[j,nr[volgende_i]] then
              begin
                tmpnr := nr[i];
                nr[i] := nr[volgende_i];
                nr[volgende_i] := tmpnr;
                gewisseld := true;
              end
          end;
      until not gewisseld;
    end;
  min_conflicten := nr[1];
end;

procedure soorten_alfabetisch(kleiner : boolean);
var i, volgende_i, soort, j, aantal, rh_soort : byte;
    wissel : integer;
    wissel2 : string[naamlengte];
    gewisseld, wissel3 : boolean;
begin
  for soort := 1 to aa_soorten do
    repeat
      gewisseld := false;
      rh_soort := reekshoofd_soort(soort,kleiner);
      aantal := n_soort_reekshoofden(soort,rh_soort,kleiner);
      for i := 1 to aantal-1 do
        begin
          volgende_i := i+1;
          if soortnamen[i,soort] > soortnamen[volgende_i,soort] then
            begin
              wissel := soorten[i,soort*2];
              soorten[i,soort*2] := soorten[volgende_i,soort*2];
              soorten[volgende_i,soort*2] := wissel;
              wissel2 := soortnamen[i,soort];
              soortnamen[i,soort] := soortnamen[volgende_i,soort];
              soortnamen[volgende_i,soort] := wissel2;
              for j := 1 to tabel.macht2+1 do
                begin
                  wissel3 := verdeling_ok[i,((soort-1)*(aa_niveaus+2))+j];
                  verdeling_ok[i,((soort-1)*(aa_niveaus+2))+j] := verdeling_ok[volgende_i,((soort-1)*(aa_niveaus+2))+j];
                  verdeling_ok[volgende_i,((soort-1)*(aa_niveaus+2))+j] := wissel3;
                end;
              gewisseld := true;
            end;
        end;
    until not gewisseld;
end;

procedure schrijf_reeks_conflicten(var bestand : text);
var i, j, k, l, z, a, b : byte;
    eerste_fout : boolean;
begin
  write(bestand,'Spelers in verschillende reeksen,');
  eerste_fout := true;
  for i := 1 to n_poules do
    begin
      for j := 1 to n_poulespelers do
        begin
          for k := 1 to n_vglpoules do
            begin
              for l := 1 to n_vglpoulespelers do
                begin
                  z := 1;
                  while ((gegevenstabel[poule[i,j],z] = vglgegevenstabel[vglpoule[k,l],z]) and (z <= aa_var)) do
                    begin
                      inc(z);
                    end;
                  if z = 7 then
                    begin
                      for a := 1 to n_poulespelers do
                        begin
                          if (a <> j) then
                            begin
                              for b := 1 to n_vglpoulespelers do
                                begin
                                  if (b <> l) then
                                    begin
                                      z := 1;
                                      while ((gegevenstabel[poule[i,a],z] = vglgegevenstabel[vglpoule[k,b],z])
                                       and (z <= aa_var)) do
                                        begin
                                          inc(z);
                                        end;
                                      if z = 7 then
                                        begin
                                          if eerste_fout then
                                            begin
                                              writeln(bestand,'NOK');
                                              eerste_fout := false;
                                            end;
                                          write(bestand,gegevenstabel[poule[i,j],1],',',gegevenstabel[poule[i,j],2]);
                                          write(bestand,',',gegevenstabel[poule[i,j],3],',',gegevenstabel[poule[i,j],4]);
                                          writeln(bestand,',',gegevenstabel[poule[i,j],5],',',gegevenstabel[poule[i,j],6]);
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
  if eerste_fout then
    writeln(bestand,'OK');
end;

procedure schrijf_summary(kleiner : boolean);
var summary : text;
    i, j, soort, aantal, basis, start, einde, rh_soort : byte;
    ok, naam : string;
begin
  assign(summary,'summary.txt');
  rewrite(summary);
  soorten_alfabetisch(kleiner);
  for basis := 1 to 2 do
    begin
      if (((kleiner) and (basis = 1)) or ((not kleiner) and (basis = 2))) then
        begin
          start := aa_basis_soorten + 1;
          einde := aa_soorten;
        end
      else
        begin
          start := 1;
          einde := aa_basis_soorten;
        end;
      if basis = 2 then
        writeln(summary,'');
      for soort := start to einde do
        begin
          case (soort mod aa_basis_soorten) of
            1 : writeln(summary,'Club');
            2 : writeln(summary,'Provincie');
            0 : writeln(summary,'Land');
          end;
          rh_soort := reekshoofd_soort(soort,kleiner);
          aantal := n_soort_reekshoofden(soort,rh_soort,kleiner);
          for i := 1 to aantal do
            begin
              naam := soortnamen[i,soort];
              if basis = 2 then
                delete(naam,length(naam),1);
              write(summary,naam,',',soorten[i,2*soort]);
              for j := 1 to tabel.macht2+1 do
                begin
                  if verdeling_ok[i,((soort-1)*(aa_niveaus+2))+j] then
                    ok := 'OK'
                  else
                    ok := 'NOK';
                  write(summary,',',ok);
                end;
              writeln(summary,'');
            end;
        end;
    end;
  writeln(summary,'');
  schrijf_reeks_conflicten(summary);
  close(summary);
end;

var i, j : byte;

var h, m, s, hund, h_old, m_old, s_old, hund_old : word;

function LeadingZero(w : word) : string;
var s : string;
begin
  str(w:0,s);
  if length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;

begin
  for j := 1 to 4 do
    for i := 1 to aa_verdelingen do
      tmpconflicten[j,i] := maxint;
  {gettime(h_old,m_old,s_old,hund_old);}
  n_verdeling := 0;
  repeat
    for j := 1 to 4 do
      conflicten[j] := 0;
    inc(n_verdeling);
    case (n_verdeling mod 2) of
      1: land1_reeksh := true;
      0: land1_reeksh := false;
    end;
    if n_verdeling <= 2 then
      begin
        basis_kleiner := true;
        start_soort := aa_basis_soorten + 1;
        einde_soort := aa_soorten;
      end
    else
      begin
        basis_kleiner := false;
        start_soort := 1;
        einde_soort := aa_basis_soorten;
      end;
    spelers_inlezen;
    inlezen_vglpoules;
    sterktetabel;
    soorttabel(basis_kleiner);
    spelers_coderen(basis_kleiner);
    slang;
    alle_poules_in_lijst(alle_poules);
    genereer_tabel;

    for i := 1 to aa_soorten do  {1=ploeg, 2=provincie, 3=land}
      verfijn(i,basis_kleiner,true,land1_reeksh);

    for i := 1 to aa_soorten do
      verfijn_tornooitabel(i,0,n_tab_problems[i],basis_kleiner,true,land1_reeksh);

    for i := 1 to aa_verbeteringen do
      repeat until not verbeter_tornooitabel(start_soort,einde_soort,i,basis_kleiner,true,land1_reeksh);

    writeln('Hier begint de reekshoofdenwissel');
    for i := 1 to aa_soorten do
      if ((i mod aa_basis_soorten) <> 0) then
        verfijn_reekshoofden(i,basis_kleiner,true,land1_reeksh);

    reeksen_correct := true;
    if n_vglpoules > 0 then
      vergelijk_reeksen(basis_kleiner,true,land1_reeksh);
    writeln('einde der reeksvergelijking');

    fillchar(verdeling_ok,sizeOf(verdeling_ok),true);
    for i := 1 to aa_soorten do
      maak_verdeling_ok_poules(i,basis_kleiner);
    for i := 1 to aa_soorten do
      maak_verdeling_ok_tabel(i,basis_kleiner);
    for i := 1 to aa_soorten do
      if ((i mod aa_basis_soorten) <> 0) then
        maak_verdeling_ok_reeksh(i,basis_kleiner);
    conflicten[1] := conflicten[2] + conflicten[3] + conflicten[4];
    if not reeksen_correct then
      inc(conflicten[1]);
    for j := 1 to 4 do
      tmpconflicten[j,n_verdeling] := conflicten[j];

    tmppoule[n_verdeling] := poule;
    tmpverdeling_ok[n_verdeling] := verdeling_ok;
{    schrijf_bestand;
    schrijf_summary(basis_kleiner);
    writeln(n_verdeling,' gedaan');
    readkey;}
  until ((tmpconflicten[1,n_verdeling] = 0) or (n_verdeling = aa_verdelingen));

  beste_verdeling := min_conflicten;
  if beste_verdeling <= 2 then
    basis_kleiner := true
  else
    basis_kleiner := false;

  spelers_inlezen;
  inlezen_vglpoules;
  sterktetabel;
  soorttabel(basis_kleiner);
  spelers_coderen(basis_kleiner);

  poule := tmppoule[beste_verdeling];
  verdeling_ok := tmpverdeling_ok[beste_verdeling];
  writeln('Verdeling ',beste_verdeling,'!');
  for i := 1 to aa_verdelingen do
    writeln('verdeling ',i,': ',tmpconflicten[1,i],' ',tmpconflicten[2,i],' ',tmpconflicten[3,i],' ',tmpconflicten[4,i]);
  schrijf_bestand;
  schrijf_summary(basis_kleiner);


  writeln('It is now ',LeadingZero(h_old),':',LeadingZero(m_old),':',
          LeadingZero(s_old),'.',LeadingZero(hund_old));
  {gettime(h,m,s,hund);}
  writeln('It is now ',LeadingZero(h),':',LeadingZero(m),':',
          LeadingZero(s),'.',LeadingZero(hund));
  read(i);


end.
