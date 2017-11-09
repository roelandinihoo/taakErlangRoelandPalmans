%%%-------------------------------------------------------------------
%%% @author roeland
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Nov 2017 14:42
%%%-------------------------------------------------------------------
-module(simulatie).
-author("roeland").

%% API
-compile(export_all).

voerFunctiesUit()->
%%Maak de ETS-tabellen en vul deze met random data
  start:start(),

%%  Berekent het aantal kamers van een eigenaar
  AantalKamersBaas1 = start:aantalKamersVanEigenaar("baas1"),
%%  Berekent het totaal inkomen van een eigenaar over alle contracten
  TotInkEig = start:totaalInkomenVanEigenaar("baas2"),
%%  Berekent het totaal inkomen van een eigenaar over 1 gegeven jaar
  TotInkEig1Jaar = start:totaalInkomenVanEigenaarOpJaar("baas3", 2016),
%%  Lijst met bedragen van alle betaling van een gegeven kamernummer/kamernummers
  AlleBet1Kamer = start:alleBetalingenPerKamers([1]),
  AlleBetMeerKamers = start:alleBetalingenPerKamers([1,2]),
%%  Lijst met bedragen van alle betaling van een gegeven kamernummer/kamernummers over een jaar
  AlleBet1Kamer1J = start:alleBetalingenPerKamersPerJaar([1],2016),
  AlleBetMeerKamers1J = start:alleBetalingenPerKamersPerJaar([1,2],2017),
%%  Toont de eerst volgende datum wanneer een kamer terug beschikbaar is
  Beschikbaar = start:wanneerIsKamerBeschikbaar(3),
%%  Toont de totale energiekosten van het hele gebouw over 1 jaar
  EnergieKosten1Jaar = start:energieKostenOver1Jaar(2016),
%%  Toont de energiekosten van 1 kot over 1 jaar
  EnergieKosten1Jaar1Kot = start:energieKostenOver1JaarVan1Kot(2016,3),
%%  Berekent de prijs van een kot voor 1 jaar te huren
  PrijsKot1Jaar = start:jaarprijs1Kot(5),
%%  Berekent het jaarlijks inkomen van een eigenaar als alle koten vol zitten
  JaarlijksInkomen1Eigenaar = start:jaarlijksInkomenVolKotEigenaar("baas2"),
%%  Berekent het gemiddelde inkomen van alle eigenaars
  GemInkom = start:gemiddeldInkomenEigenaars(),
%%  Berekent de gemiddelde huur van alle koten
  GemHuur = start:gemiddeldHuur(),
%%  Berekent het goedkoopste kot
  GoedkoopstKot = start:goedkoopsteKot(),
%%  Berekent het duurste kot
  DuursteKot = start:duursteKot(),

%%  Zet al deze data mooi in een textfile (testData.txt)
  file:write_file("testData.txt", io_lib:fwrite("
Erlang testdata:\n
Het aantal kamers van baas1 = ~p.
Het totale inkomen van baas2 over alle contracten = ~p.
Het totale inkomen van baas3 over 1 jaar = ~p.
De lijst van alle bedragen die kamer 1 heeft betaald = \n~p\n
De lijst van alle bedragen die meerdere kamers betaald hebben = \n~p\n
De lijst met betaling van kamer 1 in het jaar 2016 = \n~p\n
De lijst van alle bedragen die meerdere kamers betaald hebben in 2016 = \n~p\n
Kamer 3 is beschikbaar op ~p.
De energiekosten van het jaar 2016 van het hele huis = ~p.
De energiekosten van kamer 3 in 2016 = ~p.
De prijs voor kot 5 1 jaar te huren = ~p.
Het jaarlijks inkomen van baas2 = ~p.
Het jaarlijks inkomen van baas2 en baas3 = ~p.
De gemiddelde huur van alle koten = ~p.
Het goedkoopste kot = kot nr~p.
Het duurste kot = kot nr~p.",
    [AantalKamersBaas1,TotInkEig, TotInkEig1Jaar,
    AlleBet1Kamer, AlleBetMeerKamers, AlleBet1Kamer1J, AlleBetMeerKamers1J, Beschikbaar,
    EnergieKosten1Jaar, EnergieKosten1Jaar1Kot, PrijsKot1Jaar, JaarlijksInkomen1Eigenaar,
    GemInkom, GemHuur, GoedkoopstKot, DuursteKot])).