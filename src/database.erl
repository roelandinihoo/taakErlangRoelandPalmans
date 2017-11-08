%%%-------------------------------------------------------------------
%%% @author roeland
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Nov 2017 10:29
%%%-------------------------------------------------------------------
-module(database).
-author("roeland").
-include("records.hrl").

%% API
-compile(export_all).
%%{keypos,#betaling.kamerNr},


createBetalingTable() ->
  ets:new(betalingen, [bag, private, named_table]).


insertBetaling({Jaar, Maand,Dag}, KamerNr, Bedrag) ->
  case checkDate(Jaar, Maand, Dag) of
    true ->
      Datum = dateToDays({Jaar,Maand,Dag}),
      ets:insert(betalingen, [#betaling{datum = Datum, kamerNr = KamerNr, bedrag = Bedrag}]);
    false -> io:fwrite("The date is incorrect ~n")
  end.
deleteBetaling(Datum, KamerNr, Bedrag) ->
  ets:select_delete(betalingen, ets:fun2ms(fun(N = #betaling{datum=Datum, kamerNr = KamerNr, bedrag = Bedrag}) -> N end)).
insertAanpassing({Jaar, Maand,Dag}, KamerNr, Bedrag, Reden) ->
  case checkDate(Jaar, Maand, Dag) of
    true ->
      Datum = dateToDays({Jaar,Maand,Dag}),
      ets:insert(betalingen, [#aanpassing{datum = Datum, kamerNr = KamerNr, bedrag = Bedrag, reden = Reden}]);
    false -> io:fwrite("The date is incorrect ~n")
  end.

insertEnergieKosten({Jaar, Maand,Dag}, KamerNr, Bedrag) ->
  case checkDate(Jaar, Maand, Dag) of
    true ->
      Datum = dateToDays({Jaar,Maand,Dag}),
      ets:insert(betalingen, [#energieKosten{datum = Datum, kamerNr = KamerNr, bedrag = Bedrag}]);
    false -> io:fwrite("The date is incorrect ~n")
  end.


createContractTable() ->
  ets:new(contracten, [bag, private, named_table]).

insertContract(KamerNr, Eigenaar, Huurder, Huur, VoorschotEnergie, {AanvangJaar, AanvangMaand,AanvangDag}, Huurmaanden)->
  case checkDate(AanvangJaar, AanvangMaand, AanvangDag) of
    true ->
      AanvangDatum = dateToDays({AanvangJaar, AanvangMaand, AanvangDag}),
      ets:insert(contracten, [#contract{kamerNr = KamerNr, eigenaar = Eigenaar, huurder = Huurder, huur = Huur,
        voorschotEnergie = VoorschotEnergie, aanvangDatum = AanvangDatum, huurMaanden = Huurmaanden}]);
    false -> io:fwrite("The date is incorrect ~n")
  end.


checkDate(Year, Month, Day) -> calendar:valid_date({Year,Month,Day}).
dateToDays({Year, Month, Day}) -> calendar:date_to_gregorian_days({Year, Month,Day}).
daysToDate([Days]) -> calendar:gregorian_days_to_date(Days);
daysToDate(Days) -> calendar:gregorian_days_to_date(Days).