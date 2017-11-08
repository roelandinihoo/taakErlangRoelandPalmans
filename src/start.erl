%%%-------------------------------------------------------------------
%%% @author roeland
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Nov 2017 11:47
%%%-------------------------------------------------------------------
-module(start).
-author("roeland").
-include("records.hrl").
%% API
-compile(export_all).

start()->
  database:createBetalingTable(),
  database:createContractTable(),
  createStandardData().
%%(contract,{kamerNr, eigenaar, huurder, huur, voorschotEnergie, aanvangDatum, huurMaanden}).
createStandardData()->
  database:insertContract(1,"baas1", "student1", 300, 50, {2016,09,02}, 10),
  database:insertContract(2,"baas1", "student2", 350, 40, {2016,09,20}, 24),
  database:insertContract(3,"baas1", "student3", 250, 45, {2016,09,14}, 24),
  database:insertContract(4,"baas2", "student4", 315, 55, {2016,09,16}, 12),
  database:insertContract(5,"baas2", "student5", 325, 60, {2016,01,11}, 6),
  database:insertContract(6,"baas2", "student6", 330, 55, {2016,09,02}, 10),
  database:insertContract(7,"baas3", "student7", 290, 40, {2016,08,25}, 12),
  database:insertContract(8,"baas3", "student8", 260, 45, {2016,09,06}, 6),
  database:insertContract(9,"baas3", "student9", 280, 50, {2016,09,01}, 10),

  KamerNummers = ets:select(contracten,[{ #contract{kamerNr ='$1',
    eigenaar ='_', huurder ='_',
    huur = '_', voorschotEnergie = '_',
    aanvangDatum = '_', huurMaanden = '_'}, [], ['$1']}]),
  HuurPrijzen = ets:select(contracten,[{ #contract{kamerNr ='_',
    eigenaar ='_', huurder ='_',
    huur = '$1', voorschotEnergie = '_',
    aanvangDatum = '_', huurMaanden = '_'}, [], ['$1']}]),
  Datums = ets:select(contracten,[{ #contract{kamerNr ='_',
    eigenaar ='_', huurder ='_',
    huur = '_', voorschotEnergie = '_',
    aanvangDatum = '$1', huurMaanden = '_'}, [], ['$1']}]),
  AantalMaanden = ets:select(contracten,[{ #contract{kamerNr ='_',
    eigenaar ='_', huurder ='_',
    huur = '_', voorschotEnergie = '_',
    aanvangDatum = '_', huurMaanden = '$1'}, [], ['$1']}]),
  createBetalingen(KamerNummers,HuurPrijzen,Datums,AantalMaanden).


%%Maakt betalingen van een student afhankelijk van het aantal maanden, de huurprijs en de datum van aanhef
createBetalingen([Nr],[Pr],[Dat],[Maanden]) ->
  Datum = database:daysToDate(Dat),
  case Maanden > 0 of
    true ->
      %%We laten random toeslagen en kortingen genereren met een kans van 1 op 10 en een bedrag tussen -50 en 50
      case rand:uniform(10) == 10 of
          true -> database:insertAanpassing(Datum, Nr, rand:uniform(100)-50, "reden");
          false -> []
      end,
      %%we genereren een random energieprijs tussen 5 en 15 euro per maand
      database:insertEnergieKosten(Datum, Nr, rand:uniform(10)+5),
      database:insertBetaling(Datum, Nr, Pr),
      Dat2 = database:dateToDays(edate:shift(Datum, 1, months)),
      createBetalingen([Nr],[Pr],[Dat2],[Maanden-1]);
    false -> []
  end;
createBetalingen([Nr|NrS], [Pr|PrS], [Dat|DatS], [Maanden|MaandenS]) ->
  Datum = database:daysToDate(Dat),
  case Maanden > 0 of
      true ->
        case rand:uniform(10) == 10 of
          true -> database:insertAanpassing(Datum, Nr, rand:uniform(100)-50, "reden");
          false -> []
        end,
        database:insertEnergieKosten(Datum, Nr, rand:uniform(10)+5),
        database:insertBetaling(Datum, Nr, Pr),
        Dat2 = database:dateToDays(edate:shift(Datum, 1, months)),
        createBetalingen([Nr|NrS], [Pr|PrS], [Dat2|DatS], [Maanden - 1|MaandenS]);
      false -> createBetalingen(NrS, PrS,DatS, MaandenS)
  end.


aantalKamersVanEigenaar(Eigenaar) ->
  length(ets:select(contracten,[{ #contract{kamerNr ='$1',
    eigenaar =Eigenaar, huurder ='_',
    huur = '_', voorschotEnergie = '_',
    aanvangDatum = '_', huurMaanden = '_'}, [], ['$1']}])).

%%Totaal inkomen van een eigenaar over alle contracten
totaalInkomenVanEigenaar(Eigenaar)->
  Kamernummers = ets:select(contracten,[{ #contract{kamerNr ='$1',
    eigenaar =Eigenaar, huurder ='_',
    huur = '_', voorschotEnergie = '_',
    aanvangDatum = '_', huurMaanden = '_'}, [], ['$1']}]),
  lists:sum(alleBetalingenPerKamers(Kamernummers)).

alleBetalingenPerKamers([Kamernummer]) ->
  lists:append([
    ets:select(betalingen, [{#betaling{kamerNr = Kamernummer,datum = '_',bedrag = '$1'}, [], ['$1']}]),
    ets:select(betalingen, [{#aanpassing{kamerNr = Kamernummer,datum = '_',bedrag = '$1', reden = '_'}, [], ['$1']}]),
    ets:select(betalingen, [{#energieKosten{kamerNr = Kamernummer,datum = '_',bedrag = '$1'}, [], ['$1']}])]);
alleBetalingenPerKamers([Kamernummer|KamernummerS]) ->
  lists:append([
    ets:select(betalingen, [{#betaling{kamerNr = Kamernummer,datum = '_',bedrag = '$1'}, [], ['$1']}]),
    ets:select(betalingen, [{#aanpassing{kamerNr = Kamernummer,datum = '_',bedrag = '$1', reden = '_'}, [], ['$1']}]),
    ets:select(betalingen, [{#energieKosten{kamerNr = Kamernummer,datum = '_',bedrag = '$1'}, [], ['$1']}]),
  alleBetalingenPerKamers(KamernummerS)]).

%%toont de datum vanaf wanneer de kamer terug beschikbaar is
wanneerIsKamerBeschikbaar(KamerNr)->
  AanvangDatum = ets:select(contracten,[{ #contract{kamerNr =KamerNr,
    eigenaar ='_', huurder ='_',
    huur = '_', voorschotEnergie = '_',
    aanvangDatum = '$1', huurMaanden = '_'}, [], ['$1']}]),
  [Huurmaanden] = ets:select(contracten,[{ #contract{kamerNr =KamerNr,
    eigenaar ='_', huurder ='_',
    huur = '_', voorschotEnergie = '_',
    aanvangDatum = '_', huurMaanden = '$1'}, [], ['$1']}]),
  edate:shift(database:daysToDate(AanvangDatum), Huurmaanden, months).

%%Toont de totale kosten van energie over 1 jaar van het hele kot
energieKostenOver1Jaar(Jaartal)->
  BeginDat = database:dateToDays({Jaartal,01,01}),
  EindDat = database:dateToDays({Jaartal,12,31}),
  lists:sum(
  ets:select(betalingen, [{#energieKosten{datum = '$1',kamerNr = '_',bedrag = '$2'},
    [{'=<','$1',{const,EindDat}},{'>=','$1',{const,BeginDat}}],
    ['$2']}])).

energieKostenOver1JaarVan1Kot(Jaartal, KamerNr)->
  BeginDat = database:dateToDays({Jaartal,01,01}),
  EindDat = database:dateToDays({Jaartal,12,31}),
  lists:sum(
  ets:select(betalingen, [{#energieKosten{datum = '$1',kamerNr = '_',bedrag = '$2'},
  [{'=<','$1',{const,EindDat}},{'>=','$1',{const,BeginDat}}],
  ['$2']}])).

jaarprijs1Kot(KamerNr)->
  lists:map(fun(X) -> 12*X end, ets:select(contracten,[{#contract{kamerNr = KamerNr, huur = '$1',
    eigenaar ='_', huurder ='_', voorschotEnergie = '_', aanvangDatum = '_', huurMaanden = '_'}, [], ['$1']}])).
%%  io:fwrite("~w~n",  [Lijst]).