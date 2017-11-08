%%%-------------------------------------------------------------------
%%% @author roeland
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Nov 2017 20:14
%%%-------------------------------------------------------------------
-author("roeland").
-record(betaling,{datum, kamerNr, bedrag}).
-record(aanpassing,{datum, kamerNr, bedrag, reden}). %% positieve aanpassing = toeslag, negatieve aanpassing is korting
-record(energieKosten,{datum, kamerNr, bedrag}).
-record(contract,{kamerNr, eigenaar, huurder, huur, voorschotEnergie, aanvangDatum, huurMaanden}).
