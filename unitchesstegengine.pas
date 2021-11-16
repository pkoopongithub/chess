unit UnitChesstegEngine;
(****************************************************************)
(* (c) 1994 1995 Paul Koop chessteg didaktisches Schachprogramm *)
(* das didaktische Schachprogramm chessteg wurde                *)
(* urspruenglisch im rahmen der entwicklung der                 *)
(* Algorithmisch Rekursive Sequenzanalyse                       *)
(* zur ueberpruefung der verwendbarkeit von                     *)
(* spielbaeumen und alpha beta suche entwickelt                 *)
(* nicht als spielstarkes programm beabsichtigt                 *)
(* liegt seine staerke in der didaktischen verwendbarkeit       *)
(*                                                              *)
(* mit enpassant als bewerterer Zug innerhalb Suchbaum          *)
(* Bauernumwandlung in Dame, Turm, Springer oder Laeufer        *)
(* nach umwandlungsfaehigem Bauernzug wird separat bewertet und *)
(* umgewandelt in Dame, Turm, Springer oder Laeufer             *)
(* Rochade als Figurenumstellung an Stelle von bewertetem Zug   *)
(* fuer dos (derivate) unix (derivate) turbo-pascal free-pascal *)
(* das programm darf mit copyright paul koop kostenfrei zu      *)
(* nicht kommerziellen zwecken verwendet werden                 *)
(****************************************************************)

{$mode objfpc}{$H+}

interface

uses
  Dialogs, Classes, SysUtils, crt;

CONST cweiss       =      1;
      cschwarz     =     -1;
      c0           =      0;
      c119         =    119;
      cb           =      1;
      cl           =      4;
      cs           =      3;
      ct           =      5;
      cd           =     45;
      ck           =     99;
      dumy         =    100;
      leer         =      0;
      ctiefe       =      4;
      c1000        =   1000;

      A1=21;
      A2=31;
      A3=41;
      A4=51;
      A5=61;
      A6=71;
      A7=81;
      A8=91;
      B1=22;
      B2=32;
      B3=42;
      B4=52;
      B5=62;
      B6=72;
      B7=82;
      B8=92;
      C1=23;
      C2=33;
      C3=43;
      C4=53;
      C5=63;
      C6=73;
      C7=83;
      C8=93;
      D1=24;
      D2=34;
      D3=44;
      D4=54;
      D5=64;
      D6=74;
      D7=84;
      D8=94;
      E1=25;
      E2=35;
      E3=45;
      E4=55;
      E5=65;
      E6=75;
      E7=85;
      E8=95;
      F1=26;
      F2=36;
      F3=46;
      F4=56;
      F5=66;
      F6=76;
      F7=86;
      F8=96;
      G1=27;
      G2=37;
      G3=47;
      G4=57;
      G5=67;
      G6=77;
      G7=87;
      G8=97;
      H1=28;
      H2=38;
      H3=48;
      H4=58;
      H5=68;
      H6=78;
      H7=88;
      H8=98;

      cmaxInteger =  32767;
      cminInteger = -32768;

TYPE  Tfigurenliste = ^Tfigur;
      Tfigur = RECORD
                art:SHORTINT;
                farbe:SHORTINT;
                pos:c0..c119;
                geschlagen:BOOLEAN;
                vor,nach:Tfigurenliste;
               END;



      Tzugliste = ^Tzug;
      Tzug = RECORD
              vonpos,nachpos,art: SHORTINT;
	      farbe:SHORTINT;
              geschlagen:Tfigurenliste;
              vor,nach:Tzugliste;
             END;


      Tbrett= ARRAY[c0..c119] OF SHORTINT;

      Tziehe = RECORD
                vonpos,nachpos,art:SHORTINT;
                farbe:SHORTINT;
                geschlagen:Tfigurenliste;
               END;

CONST brett:Tbrett = (
                      dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,
                      dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,
                      dumy,leer,leer,leer,leer,leer,leer,leer,leer,dumy,
                      dumy,leer,leer,leer,leer,leer,leer,leer,leer,dumy,
                      dumy,leer,leer,leer,leer,leer,leer,leer,leer,dumy,
                      dumy,leer,leer,leer,leer,leer,leer,leer,leer,dumy,
                      dumy,leer,leer,leer,leer,leer,leer,leer,leer,dumy,
                      dumy,leer,leer,leer,leer,leer,leer,leer,leer,dumy,
                      dumy,leer,leer,leer,leer,leer,leer,leer,leer,dumy,
                      dumy,leer,leer,leer,leer,leer,leer,leer,leer,dumy,
                      dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,
                      dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy,dumy
                     );

VAR
     bewertung:INTEGER;
     figurenliste         :Tfigurenliste;
     endmatt,patt,rochiertweiss,rochiertschwarz:BOOLEAN;
     Spielerzug:Tziehe;

PROCEDURE schreibeBrettFigur(f:SHORTINT);
PROCEDURE zeigebrett2(VAR brett:Tbrett);
PROCEDURE zeigebrett(VAR brett:Tbrett);
PROCEDURE schreibePosition (pos:INTEGER);
PROCEDURE schreibeFigur (art:INTEGER);
FUNCTION figurenListeGenerieren():Tfigurenliste;
PROCEDURE abbauFigurenListe(VAR figurenliste:Tfigurenliste);
FUNCTION generiereTurmzuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
FUNCTION generiereLaeuferzuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
FUNCTION generiereDamezuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
FUNCTION attakiert(feld:SHORTINT; VAR aktuellefigur:Tfigurenliste):BOOLEAN;
FUNCTION generiereKoenigszuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
FUNCTION generiereSpringerzuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
FUNCTION generiereBauernzuege(farbe:SHORTINT;VAR aktuellefigur:Tfigurenliste;letzterzug:Tziehe):Tzugliste;
FUNCTION zuggenerator (farbe:INTEGER;letzterzug:Tziehe):Tzugliste;
PROCEDURE zugAbbau(linie:STRING;farbe:SHORTINT; VAR zugliste:Tzugliste);
PROCEDURE figuren(figurenliste:Tfigurenliste);
FUNCTION bewerteZug ():INTEGER;
PROCEDURE ComputerZugSetzen(VAR brett:Tbrett; VAR ziehe:Tziehe);
PROCEDURE brettZugSetzen (VAR brett:Tbrett;VAR ziehe:Tziehe);
PROCEDURE brettZugZuruecknehmen (VAR brett:Tbrett; VAR ziehe:Tziehe);
FUNCTION matt (linie:STRING;farbe:SHORTINT; VAR figurenliste:Tfigurenliste):BOOLEAN;
FUNCTION zaehleZugliste(zugliste:Tzugliste):INTEGER;
FUNCTION schach(farbe:SHORTINT):BOOLEAN;
FUNCTION alphabeta (farbe, alpha, beta, tiefe, maxTiefe: INTEGER;linie:STRING;letzterzug:Tziehe): INTEGER;
PROCEDURE bauernumwandlung(farbe:SHORTINT;VAR figurenliste:Tfigurenliste;letzterBauernzug:Tziehe);
FUNCTION computerzug (farbe, alpha, beta, tiefe, maxTiefe: INTEGER;linie:STRING): INTEGER;
FUNCTION spielerzieht (farbe, alpha, beta, tiefe, maxTiefe: INTEGER;linie:STRING): BOOLEAN;
PROCEDURE kleinerochade(figurenliste:Tfigurenliste;farbe:SHORTINT);
FUNCTION kleinerochademoeglich(figurenliste:Tfigurenliste;farbe:SHORTINT):BOOLEAN;
PROCEDURE grosserochade(figurenliste:Tfigurenliste;farbe:SHORTINT);
FUNCTION grosserochademoeglich(figurenliste:Tfigurenliste;farbe:SHORTINT):BOOLEAN;

implementation


PROCEDURE schreibeBrettFigur(f:SHORTINT);
BEGIN
 CASE f OF
    cb: write('^');
    cl: write('&');
    cs: write('#');
    ct: write('T');
    cd: write('§');
    ck: write('$');
  ELSE write('.');
 END;
END;

PROCEDURE zeigebrett2(VAR brett:Tbrett);
VAR i:INTEGER;
BEGIN
textcolor(white);
writeln('_ABCDEFGH_');

write('8'); for i:=91 TO 98 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); schreibeBrettFigur(abs(brett(.i.))); textcolor (white); END; write('8');writeln;
write('7'); for i:=81 TO 88 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); schreibeBrettFigur(abs(brett(.i.))); textcolor (white); END; write('7');writeln;
write('6'); for i:=71 TO 78 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); schreibeBrettFigur(abs(brett(.i.))); textcolor (white); END; write('6');writeln;
write('5'); for i:=61 TO 68 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); schreibeBrettFigur(abs(brett(.i.))); textcolor (white); END; write('5');writeln;
write('4'); for i:=51 TO 58 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); schreibeBrettFigur(abs(brett(.i.))); textcolor (white); END; write('4');writeln;
write('3'); for i:=41 TO 48 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); schreibeBrettFigur(abs(brett(.i.))); textcolor (white); END; write('3');writeln;
write('2'); for i:=31 TO 38 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); schreibeBrettFigur(abs(brett(.i.))); textcolor (white); END; write('2');writeln;
write('1'); for i:=21 TO 28 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); schreibeBrettFigur(abs(brett(.i.))); textcolor (white); END; write('1');writeln;


writeln('_ABCDEFGH_');
END;

PROCEDURE zeigebrett(VAR brett:Tbrett);
VAR i:INTEGER;
BEGIN
textcolor(white);
writeln('______A__B__C__D__E__F__G__H');
write('_'); for i:=110 TO 119 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.))); textcolor (white); END; writeln;
write('_'); for i:=100 TO 109 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.))); textcolor (white); END; writeln;

write('8'); for i:=90 TO 99 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.)):3); textcolor (white); END; writeln;
write('7'); for i:=80 TO 89 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.)):3); textcolor (white); END; writeln;
write('6'); for i:=70 TO 79 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.)):3); textcolor (white); END; writeln;
write('5'); for i:=60 TO 69 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.)):3); textcolor (white); END; writeln;
write('4'); for i:=50 TO 59 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.)):3); textcolor (white); END; writeln;
write('3'); for i:=40 TO 49 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.)):3); textcolor (white); END; writeln;
write('2'); for i:=30 TO 39 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.)):3); textcolor (white); END; writeln;
write('1'); for i:=20 TO 29 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.)):3); textcolor (white); END; writeln;


write('_'); for i:=10 TO 19 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.))); textcolor (white); END; writeln;
write('_'); for i:=0 TO 9 DO
  BEGIN IF (brett(.i.)<c0) THEN textcolor (red); write(abs(brett(.i.))); textcolor (white); END; writeln;

writeln('______A__B__C__D__E__F__G__H');
END;

PROCEDURE schreibePosition (pos:INTEGER);
BEGIN
 CASE pos OF

      A1:write('A1');
      A2:write('A2');
      A3:write('A3');
      A4:write('A4');
      A5:write('A5');
      A6:write('A6');
      A7:write('A7');
      A8:write('A8');
      B1:write('B1');
      B2:write('B2');
      B3:write('B3');
      B4:write('B4');
      B5:write('B5');
      B6:write('B6');
      B7:write('B7');
      B8:write('B8');
      C1:write('C1');
      C2:write('C2');
      C3:write('C3');
      C4:write('C4');
      C5:write('C5');
      C6:write('C6');
      C7:write('C7');
      C8:write('C8');
      D1:write('D1');
      D2:write('D2');
      D3:write('D3');
      D4:write('D4');
      D5:write('D5');
      D6:write('D6');
      D7:write('D7');
      D8:write('D8');
      E1:write('E1');
      E2:write('E2');
      E3:write('E3');
      E4:write('E4');
      E5:write('E5');
      E6:write('E6');
      E7:write('E7');
      E8:write('E8');
      F1:write('F1');
      F2:write('F2');
      F3:write('F3');
      F4:write('F4');
      F5:write('F5');
      F6:write('F6');
      F7:write('F7');
      F8:write('F8');
      G1:write('G1');
      G2:write('G2');
      G3:write('G3');
      G4:write('G4');
      G5:write('G5');
      G6:write('G6');
      G7:write('G7');
      G8:write('G8');
      H1:write('H1');
      H2:write('H2');
      H3:write('H3');
      H4:write('H4');
      H5:write('H5');
      H6:write('H6');
      H7:write('H7');
      H8:write('H8');

 ELSE
      write('fehler bei position');
 END;
END;

PROCEDURE schreibeFigur (art:INTEGER);
BEGIN
 CASE art OF
       cb:write('Weisser   Bauer');
       cl:write('Weisser   Laeufer');
       cs:write('Weisser   Springer');
       ct:write('Weisser   Turm   ');
       cd:write('Weisse    Dame   ');
       ck:write('Weisser   Koenig ');
      -cb:write('Schwarzer Bauer');
      -cl:write('Schwarzer Laeufer');
      -cs:write('Schwarzer Springer');
      -ct:write('Schwarzer Turm   ');
      -cd:write('Schwarze  Dame   ');
      -ck:write('Schwarzer Koenig ');

 ELSE
         write('fehler bei art   ');
 END;
END;

FUNCTION figurenListeGenerieren():Tfigurenliste;
 VAR neuefigur,aktuell,wurzel:Tfigurenliste;
 BEGIN

  (*Die beiden Koenige immer verwenden und nie veraendern oder ersetzen auch Reihenfolge nicht*)
  (*niemals Koenige als Vorlage kopieren   *)

  new(neuefigur);aktuell:=neuefigur;wurzel:=aktuell;
  neuefigur^.art:=ck;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=E8;brett(.E8.):=ck*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.vor:=NIL;

  new(neuefigur);
  neuefigur^.art:=ck;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=E1;brett(.E1.):=ck*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (* hier folgen alle anderen Figuren *)


 (*-------------------------------------------------------------------*)
 (* -------------------DAMEN----------------------------------------- *)
 (* schwarz ----------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=cd;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=D8;brett(.D8.):=cd*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (* weiss ------------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=cd;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=D1;brett(.D1.):=cd*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;
 (*-------------------------------------------------------------------*)



 (* -------------------TUERME---------------------------------------- *)
 (* schwarz ----------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=ct;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=A8;brett(.A8.):=ct*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=ct;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=H8;brett(.H8.):=ct*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (* weiss ------------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=ct;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=H1;brett(.H1.):=ct*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=ct;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=A1;brett(.A1.):=ct*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (*-------------------------------------------------------------------*)



 (* -------------------SPRINGER-------------------------------------- *)
 (* schwarz ----------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=cs;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=B8;brett(.B8.):=cs*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cs;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=G8;brett(.G8.):=cs*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (* weiss ------------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=cs;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=B1;brett(.B1.):=cs*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cs;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=G1;brett(.G1.):=cs*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (*-------------------------------------------------------------------*)



 (*-------------------------------------------------------------------*)
 (* --------------------LAEUFER-------------------------------------- *)
 (* schwarz ----------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=cl;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=C8;brett(.C8.):=cl*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cl;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=F8;brett(.F8.):=cl*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (* weiss ------------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=cl;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=C1;brett(.C1.):=cl*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cl;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=F1;brett(.F1.):=cl*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (*-------------------------------------------------------------------*)



 (* -------------------BAUERN---------------------------mm----------- *)
 (* schwarz ----------------------------------------------------------*)

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=A7;brett(.A7.):=cb*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=B7;brett(.B7.):=cb*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=C7;brett(.C7.):=cb*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=D7;brett(.D7.):=cb*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=E7;brett(.E7.):=cb*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=F7;brett(.F7.):=cb*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=G7;brett(.G7.):=cb*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cschwarz;
  neuefigur^.pos:=H7;brett(.H7.):=cb*cschwarz;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;



 (* weiss ------------------------------------------------------------*)
  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=A2;brett(.A2.):=cb*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=B2;brett(.B2.):=cb*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=C2;brett(.C2.):=cb*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=D2;brett(.D2.):=cb*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=E2;brett(.E2.):=cb*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=F2;brett(.F2.):=cb*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=G2;brett(.G2.):=cb*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

  new(neuefigur);
  neuefigur^.art:=cb;neuefigur^.farbe:=cweiss;
  neuefigur^.pos:=H2;brett(.H2.):=cb*cweiss;
  neuefigur^.geschlagen:=false;
  neuefigur^.nach:=nil;
  neuefigur^.vor:=aktuell;
  aktuell^.nach:=neuefigur;
  aktuell:= neuefigur;

 (*-------------------------------------------------------------------*)


(*   RUECKGABE der Liste nie veraendern --------------------mmmmm---- *)

  figurenListeGenerieren:=wurzel;

 END;

PROCEDURE abbauFigurenListe(VAR figurenliste:Tfigurenliste);
BEGIN
  (*writeln('abbau figurenliste'); *)
  IF (figurenliste^.nach<>nil) THEN abbauFigurenListe(figurenliste^.nach);
  dispose(figurenliste);figurenliste:=NIL;
END;

FUNCTION geschlagenefigur(feld:Byte):Tfigurenliste;
 VAR aktuell:Tfigurenliste;
 BEGIN
  aktuell:=figurenliste;
  WHILE (aktuell<>nil)
   DO
   BEGIN
    IF ((aktuell^.pos=feld)AND(aktuell^.geschlagen=false))
     THEN BEGIN geschlagenefigur:=aktuell;exit; END;
    aktuell:=aktuell^.nach;
   END;
   geschlagenefigur:=aktuell;
 END;

FUNCTION generiereTurmzuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
 CONST
      auf   = 10;
      ab    =-10;
      links = -1;
      rechts= +1;
 VAR feld:BYTE;
     neu,wurzel,aktuell:Tzugliste;
     PROCEDURE zieheNach(auf:SHORTINT);
     VAR suchende:BOOLEAN;
     BEGIN
         suchende:=false;
         feld:=aktuellefigur^.pos+auf;
         IF (
               ((aktuellefigur^.farbe=cweiss  )AND(brett(.feld.)>c0)
                AND(brett(.feld.)<>dumy))
               OR
               ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
               OR
               (brett(.feld.)=dumy)
            )
            THEN suchende:=true;

         WHILE ((brett(.feld.)<>dumy)AND(NOT(suchende)))
         DO
          BEGIN
           IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
             new(neu);
             neu^.geschlagen:=NIL;
             neu^.nach:=nil;neu^.vor:=aktuell;
             aktuell^.nach:= neu;
             aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=ct;
           IF (
               ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)<c0))
               OR
               ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)>c0)
                 AND(brett(.feld.)<>dumy))
              )
           THEN
            BEGIN
             neu^.geschlagen:=geschlagenefigur(feld);
             suchende:=true;
            END;
            feld:=feld+auf;
           IF (
               ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)>c0))
               OR((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
               OR(brett(.feld.)=dumy)
              ) THEN suchende:=true;
          END;

     END;


  BEGIN
     neu:=nil;aktuell:=nil;wurzel:=nil;

     zieheNach(auf);
     zieheNach(ab);

     zieheNach(links);
     zieheNach(rechts);

     generiereTurmzuege:= wurzel;
 END;

FUNCTION generiereLaeuferzuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
 CONST
      auf   = 10;
      ab    =-10;
      links = -1;
      rechts= +1;
 VAR feld:BYTE;
     neu,wurzel,aktuell:Tzugliste;
     PROCEDURE zieheNach(auf:SHORTINT);
     VAR suchende:BOOLEAN;
     BEGIN
         suchende:=false;
         feld:=aktuellefigur^.pos+auf;
         IF (
               ((aktuellefigur^.farbe=cweiss  )AND(brett(.feld.)>c0)
                AND(brett(.feld.)<>dumy))
               OR
               ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
               OR
               (brett(.feld.)=dumy)
            )
            THEN suchende:=true;

         WHILE ((brett(.feld.)<>dumy)AND(NOT(suchende)))
         DO
          BEGIN
           IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
             new(neu);
             neu^.geschlagen:=NIL;
             neu^.nach:=nil;neu^.vor:=aktuell;
             aktuell^.nach:= neu;
             aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=cl;
           IF (
               ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)<c0))
               OR
               ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)>c0)
                 AND(brett(.feld.)<>dumy))
              )
           THEN
            BEGIN
             neu^.geschlagen:=geschlagenefigur(feld);
             suchende:=true;
            END;
            feld:=feld+auf;
           IF (
               ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)>c0))
               OR((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
               OR(brett(.feld.)=dumy)
              ) THEN suchende:=true;
          END;

     END;
  BEGIN
     neu:=nil;aktuell:=nil;wurzel:=nil;

     zieheNach(auf+links);
     zieheNach(ab+links);

     zieheNach(auf+rechts);
     zieheNach(ab+rechts);

     generiereLaeuferzuege:= wurzel;
 END;


FUNCTION generiereDamezuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
 CONST
      auf   = 10;
      ab    =-10;
      links = -1;
      rechts= +1;
 VAR feld:BYTE;
     neu,wurzel,aktuell:Tzugliste;
     PROCEDURE zieheNach(auf:SHORTINT);
     VAR suchende:BOOLEAN;
     BEGIN
         suchende:=false;
         feld:=aktuellefigur^.pos+auf;
         IF (
               ((aktuellefigur^.farbe=cweiss  )AND(brett(.feld.)>c0)
                AND(brett(.feld.)<>dumy))
               OR
               ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
               OR
               (brett(.feld.)=dumy)
            )
            THEN suchende:=true;

         WHILE ((brett(.feld.)<>dumy)AND(NOT(suchende)))
         DO
          BEGIN
           IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
             new(neu);
             neu^.geschlagen:=NIL;
             neu^.nach:=nil;neu^.vor:=aktuell;
             aktuell^.nach:= neu;
             aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=cd;
           IF (
               ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)<c0))
               OR
               ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)>c0)
                 AND(brett(.feld.)<>dumy))
              )
           THEN
            BEGIN
             neu^.geschlagen:=geschlagenefigur(feld);
             suchende:=true;
            END;
            feld:=feld+auf;
           IF (
               ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)>c0))
               OR((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
               OR(brett(.feld.)=dumy)
              ) THEN suchende:=true;
          END;

     END;
  BEGIN
     neu:=nil;aktuell:=nil;wurzel:=nil;

     zieheNach(auf+links);
     zieheNach(ab+links);

     zieheNach(auf+rechts);
     zieheNach(ab+rechts);

     zieheNach(auf);
     zieheNach(ab);

     zieheNach(links);
     zieheNach(rechts);


     generiereDamezuege:= wurzel;
 END;

FUNCTION attakiert(feld:SHORTINT; VAR aktuellefigur:Tfigurenliste):BOOLEAN;
CONST
      auf   = 10;
      ab    =-10;
      links = -1;
      rechts= +1;
VAR attacke:BOOLEAN;


FUNCTION vonTurmBedroht(feld,richtung:SHORTINT):BOOLEAN;
VAR attacke,suchende:BOOLEAN;
    testfeld:SHORTINT;

 BEGIN
  attacke:= false;suchende:=false;
  testfeld:=feld+richtung;
  WHILE ((brett(.testfeld.)<>dumy)AND(NOT(suchende)))
  DO
  BEGIN
   IF (brett(.testfeld.)<>(aktuellefigur^.farbe*aktuellefigur^.art))
   THEN
   IF (
       (aktuellefigur^.farbe<c0)AND(brett(.testfeld.)=ct)
       OR
       (aktuellefigur^.farbe>c0)AND(brett(.testfeld.)=-ct)
      )
      THEN BEGIN attacke:=true;suchende:=true;END;
      IF (brett(.testfeld.)<>leer) THEN suchende:=true;
   testfeld:=testfeld+richtung;
  END;
  vonTurmBedroht:=attacke;
 END;


FUNCTION vonLaeuferBedroht(feld,richtung:SHORTINT):BOOLEAN;
VAR attacke,suchende:BOOLEAN;
    testfeld:SHORTINT;

 BEGIN
  attacke:= false;suchende:=false;
  Testfeld:=feld+richtung;
  WHILE ((brett(.testfeld.)<>dumy)AND(NOT(suchende)))
  DO
  BEGIN
   IF (brett(.testfeld.)<>(aktuellefigur^.farbe*aktuellefigur^.art))
   THEN
   IF (
       (aktuellefigur^.farbe<c0)AND(brett(.testfeld.)=cl)
       OR
       (aktuellefigur^.farbe>c0)AND(brett(.testfeld.)=-cl)
      )
      THEN BEGIN attacke:=true;suchende:=true;END;
      IF (brett(.testfeld.)<>leer)THEN suchende:=true;
   testfeld:=testfeld+richtung;
  END;
  vonLaeuferBedroht:=attacke;
 END;

FUNCTION vonDameBedroht(feld,richtung:SHORTINT):BOOLEAN;
VAR attacke,suchende:BOOLEAN;
    testfeld:SHORTINT;

 BEGIN
  attacke:= false;suchende:=false;
  Testfeld:=feld+richtung;
  WHILE ((brett(.testfeld.)<>dumy)AND(NOT(suchende)))
  DO
  BEGIN
   IF (brett(.testfeld.)<>(aktuellefigur^.farbe*aktuellefigur^.art))
   THEN
   IF (
       (aktuellefigur^.farbe<c0)AND(brett(.testfeld.)=cd)
       OR
       (aktuellefigur^.farbe>c0)AND(brett(.testfeld.)=-cd)
      )
      THEN BEGIN attacke:=true;suchende:=true;END;
      IF (brett(.testfeld.)<>leer)THEN suchende:=true;
   testfeld:=testfeld+richtung;
  END;
  vonDameBedroht:=attacke;
 END;


FUNCTION vonKoenigBedroht(feld,richtung:SHORTINT):BOOLEAN;
VAR attacke:BOOLEAN;
    testfeld:SHORTINT;

BEGIN
 attacke:=false;
 testfeld:=feld+richtung;
 if (
     (aktuellefigur^.farbe<c0)AND(brett(.testfeld.)=ck)
     OR
     (aktuellefigur^.farbe>c0)AND(brett(.testfeld.)=-ck)
    )
    THEN BEGIN attacke:=true;END;
 vonKoenigBedroht:=attacke;

END;

FUNCTION vonBauerBedroht(feld,richtung:SHORTINT):BOOLEAN;
VAR attacke:BOOLEAN;
    testfeld:SHORTINT;

BEGIN
 attacke:=false;
 testfeld:=feld+richtung;
 if (
     (aktuellefigur^.farbe<c0)AND(brett(.testfeld.)=cb)
     OR
     (aktuellefigur^.farbe>c0)AND(brett(.testfeld.)=-cb)
    )
    THEN BEGIN attacke:=true;END;
 vonBauerBedroht:=attacke;

END;

FUNCTION vonSpringerBedroht(feld,richtung:SHORTINT):BOOLEAN;
VAR attacke:BOOLEAN;
    testfeld:SHORTINT;

BEGIN
 attacke:=false;
 testfeld:=feld+richtung;
 if (
     (aktuellefigur^.farbe<c0)AND(brett(.testfeld.)=cs)
     OR
     (aktuellefigur^.farbe>c0)AND(brett(.testfeld.)=-cs)
    )
    THEN BEGIN attacke:=true;END;
 vonSpringerBedroht:=attacke;

END;

BEGIN
  attacke:=false;
  attacke:=vonTurmBedroht(feld,auf);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonTurmBedroht(feld,links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonTurmBedroht(feld,rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonTurmBedroht(feld,ab);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;

  attacke:=vonLaeuferBedroht(feld,auf+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonLaeuferBedroht(feld,ab+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonLaeuferBedroht(feld,auf+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonLaeuferBedroht(feld,ab+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;


  attacke:=vonDameBedroht(feld,auf);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonDameBedroht(feld,links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonDameBedroht(feld,rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonDameBedroht(feld,ab);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;

  attacke:=vonDameBedroht(feld,auf+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonDameBedroht(feld,ab+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonDameBedroht(feld,auf+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonDameBedroht(feld,ab+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;




  attacke:=vonKoenigBedroht(feld,auf+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonKoenigBedroht(feld,auf+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonKoenigBedroht(feld,ab+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonKoenigBedroht(feld,ab+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonKoenigBedroht(feld,auf);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonKoenigBedroht(feld,ab);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonKoenigBedroht(feld,rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonKoenigBedroht(feld,links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;


  attacke:=vonSpringerBedroht(feld,auf+auf+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonSpringerBedroht(feld,auf+auf+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonSpringerBedroht(feld,ab+ab+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonSpringerBedroht(feld,ab+ab+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonSpringerBedroht(feld,links+links+auf);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonSpringerBedroht(feld,links+links+ab);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonSpringerBedroht(feld,rechts+rechts+auf);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
  attacke:=vonSpringerBedroht(feld,rechts+rechts+ab);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;



  attacke:=vonBauerBedroht(feld,auf*aktuellefigur^.farbe+links);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;
    attacke:=vonBauerBedroht(feld,auf*aktuellefigur^.farbe+rechts);
  IF attacke THEN BEGIN attakiert:=attacke; exit; END;



  attakiert:=attacke;
END;

FUNCTION generiereKoenigszuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
 CONST
      auf   = 10;
      ab    =-10;
      links = -1;
      rechts= +1;
 VAR feld:BYTE;
     neu,wurzel,aktuell:Tzugliste;

     PROCEDURE zieheNach(auf:SHORTINT);



     BEGIN (* generiegrekoenigszuege() *)
         feld:=aktuellefigur^.pos+auf;
         IF (
             NOT
                (
                 ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)>c0))
                 OR
                 ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
                 OR
                 (brett(.feld.)=dumy)
                )
            )
            AND
            (NOT(attakiert(feld,aktuellefigur)))
          THEN
           BEGIN
           IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=aktuell;
              aktuell^.nach:= neu;
              aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=ck;
           IF (
               (
                (aktuellefigur^.farbe=cweiss)AND(brett(.feld.)<c0)
               )
                OR
               (
                (aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)>c0)
                 AND
                 (brett(.feld.)<>dumy)
               )
              )
           THEN
            BEGIN
             neu^.geschlagen:=geschlagenefigur(feld);
            END;
           END;(* ENDE zieheNach*)
     END;
  BEGIN
     neu:=nil;aktuell:=nil;wurzel:=nil;

     zieheNach(auf+links);
     zieheNach(auf);
     zieheNach(auf+rechts);
     zieheNach(links);
     zieheNach(rechts);
     zieheNach(ab+links);
     zieheNach(ab);
     zieheNach(ab+rechts);

     generiereKoenigszuege:= wurzel;
 END;


FUNCTION generiereSpringerzuege(VAR aktuellefigur:Tfigurenliste):Tzugliste;
 CONST
      auf   = 10;
      ab    =-10;
      links = -1;
      rechts= +1;
 VAR feld:BYTE;
     neu,wurzel,aktuell:Tzugliste;

     PROCEDURE zieheNach(auf:SHORTINT);



     BEGIN (* generiegrespringerzuege() *)
         feld:=aktuellefigur^.pos+auf;
         IF (
             NOT
                (
                 ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)>c0))
                 OR
                 ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
                 OR
                 (brett(.feld.)=dumy)
                )
            )

          THEN
           BEGIN
           IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=aktuell;
              aktuell^.nach:= neu;
              aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=cs;
           IF (
               (
                (aktuellefigur^.farbe=cweiss)AND(brett(.feld.)<c0)
               )
                OR
               (
                (aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)>c0)
                 AND
                 (brett(.feld.)<>dumy)
               )
              )
           THEN
            BEGIN
             neu^.geschlagen:=geschlagenefigur(feld);
            END;
           END;(* ENDE zieheNach*)
     END;
  BEGIN
     neu:=nil;aktuell:=nil;wurzel:=nil;

     zieheNach(auf+auf+links);
     zieheNach(auf+auf+rechts);
     zieheNach(ab+ab+rechts);
     zieheNach(ab+ab+links);
     zieheNach(links+links+ab);
     zieheNach(links+links+auf);
     zieheNach(rechts+rechts+auf);
     zieheNach(rechts+rechts+ab);

     generiereSpringerzuege:= wurzel;
 END;


FUNCTION generiereBauernzuege(farbe:SHORTINT;VAR aktuellefigur:Tfigurenliste;letzterzug:Tziehe):Tzugliste;
 CONST
      auf   = 10;
      links = -1;
      rechts= +1;
 VAR feld:BYTE;
     neu,wurzel,aktuell:Tzugliste;

     PROCEDURE schlageNach(neupos:SHORTINT);
      BEGIN (* generierebauerenzuege() *)
         feld:=aktuellefigur^.pos+neupos;
          IF (
             NOT
                (
                 ((aktuellefigur^.farbe=cweiss)AND(brett(.feld.)>c0))
                 OR
                 ((aktuellefigur^.farbe=cschwarz)AND(brett(.feld.)<c0))
                 OR
                 (brett(.feld.)=leer)
                 OR
                 (brett(.feld.)=dumy)
                )
             )(*Ende Not*)

          THEN
           BEGIN
           IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=aktuell;
              aktuell^.nach:= neu;
              aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=cb;
           neu^.geschlagen:=geschlagenefigur(feld);
           END;(*Ende IF NOT THEN normaler Schlag*)


           IF (
               (feld+(auf*-farbe)=letzterzug.nachpos)
               AND
               (letzterzug.art=cb)
               AND
               (letzterzug.farbe=-farbe)
               AND
               (brett(.feld.)=leer)
               AND
               (brett(.feld+(auf*-farbe).)=(cb*farbe))
              )
            THEN
            BEGIN
            IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=aktuell;
              aktuell^.nach:= neu;
              aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=cb;
           neu^.geschlagen:=geschlagenefigur(letzterzug.nachpos);
           END;(*Ende IF NOT THEN enpassant Schlag*)

      END;(* ENDE schlageNach*)



     PROCEDURE zieheEinFeldNach(neupos:SHORTINT);
      BEGIN (* generierebauerenzuege() *)
         feld:=aktuellefigur^.pos+neupos;
         IF(brett(.feld.)=leer)
          THEN
           BEGIN
           IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=aktuell;
              aktuell^.nach:= neu;
              aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=cb;

           END;(* ENDE zieheEinFeldNach*)
     END;


     PROCEDURE zieheEinfachUndDoppelt(neupos:SHORTINT);
     VAR suchende:BOOLEAN; zaehler:BYTE;
     BEGIN
         suchende:=false; zaehler:=c0;
         feld:=aktuellefigur^.pos+neupos;
         IF (
               ( (brett(.feld.)<>leer))
               OR (brett(.feld.)=dumy)
               )
         THEN suchende:=true;
         WHILE ((brett(.feld.)=leer)AND(NOT(suchende))AND (zaehler<2))
         DO
          BEGIN
            IF (neu=NIL)
            THEN
             BEGIN
              new(neu);
              neu^.geschlagen:=NIL;
              neu^.nach:=nil;neu^.vor:=nil;
              wurzel:=neu;
              aktuell:=neu;
             END
            ELSE
             BEGIN
             new(neu);
             neu^.geschlagen:=NIL;
             neu^.nach:=nil;neu^.vor:=aktuell;
             aktuell^.nach:= neu;
             aktuell:=neu;
             END;
           neu^.vonpos:=aktuellefigur^.pos;
           neu^.nachpos:=feld;
           neu^.farbe:=aktuellefigur^.farbe;
           neu^.art:=cb;



          zaehler:=zaehler+1;
          feld:=feld+neupos;
          IF (
               ( (brett(.feld.)<>leer))
               OR(brett(.feld.)=dumy)
               ) THEN suchende:=true;
          END; (*WHILE*)
     END; (*zieheEinfachUndDoppelt*)
 BEGIN (*Ausfuehrung generiereBauernzuege*)
     neu:=nil;aktuell:=nil;wurzel:=nil;


      IF (
          (
           (farbe=cweiss)
           AND
           (aktuellefigur^.pos<=H2)
          )
          OR
          (
           (aktuellefigur^.pos>=A7)AND(aktuellefigur^.pos<=H7)
           AND
           (farbe=cschwarz)
          )
         )
      THEN
      zieheEinfachUndDoppelt(auf*farbe)
      ELSE zieheEinFeldNach(auf*farbe);


      schlageNach((auf*farbe)+rechts);
      schlageNach((auf*farbe)+links);

      generiereBauernzuege:= wurzel;
 END; (*generiereBauernzuege*)

FUNCTION zuggenerator (farbe:INTEGER;letzterzug:Tziehe):Tzugliste;

VAR neugeneriert,neu,wurzel:Tzugliste;
    aktuell:Tfigurenliste;
BEGIN
 neugeneriert:=nil;neu:=nil;wurzel:=nil;aktuell:=figurenliste;
 WHILE aktuell <> nil
 DO
 BEGIN
  IF ((aktuell^.farbe = farbe) AND (Not(aktuell^.geschlagen)))
  THEN
  BEGIN
   CASE aktuell^.art OF
    cb:
       BEGIN
       neugeneriert:=generiereBauernzuege(farbe,aktuell,letzterzug);
       IF(neugeneriert<>nil) THEN
       IF (neu=nil)
       THEN
       BEGIN
        neu := neugeneriert;
        wurzel := neu;
       END
       ELSE
       BEGIN
        neu^.nach := neugeneriert;
        neu^.nach^.vor := neu;
       END;
       END;
    cl:
       BEGIN
       neugeneriert:=generiereLaeuferzuege(aktuell);
       IF(neugeneriert<>nil) THEN
       IF (neu=nil)
       THEN
       BEGIN
        neu := neugeneriert;
        wurzel := neu;
       END
       ELSE
       BEGIN
        neu^.nach := neugeneriert;
        neu^.nach^.vor := neu
       END;
       END;
    cs:
       BEGIN
       neugeneriert:=generiereSpringerzuege(aktuell);
       IF(neugeneriert<>nil) THEN
       IF (neu=nil)
       THEN
       BEGIN
        neu := neugeneriert;
        wurzel := neu;
       END
       ELSE
       BEGIN
        neu^.nach := neugeneriert;
        neu^.nach^.vor := neu
       END;
       END;

    ct:
       BEGIN
       neugeneriert:=generiereTurmzuege(aktuell);;
       IF(neugeneriert<>nil) THEN
       IF (neu=nil)
       THEN
       BEGIN
        neu :=  neugeneriert;
        wurzel := neu;
       END
       ELSE
       BEGIN
        neu^.nach := neugeneriert;
        neu^.nach^.vor := neu
       END;
       END;
    cd:
       BEGIN
       neugeneriert:=generiereDamezuege(aktuell);
       IF(neugeneriert<>nil) THEN
       IF (neu=nil)
       THEN
       BEGIN
        neu := neugeneriert;
        wurzel := neu;
       END
       ELSE
       BEGIN
        neu^.nach := neugeneriert;
        neu^.nach^.vor := neu
       END;
       END;
    ck:
       BEGIN
       neugeneriert:=generiereKoenigszuege(aktuell);
       IF(neugeneriert<>nil) THEN
       IF (neu=nil)
       THEN
       BEGIN
        neu := neugeneriert;
        wurzel := neu;
       END
       ELSE
       BEGIN
        neu^.nach := neugeneriert;
        neu^.nach^.vor := neu
       END;
       END;
   ELSE
    BEGIN writeln ('zuggeneratorFehler aktuell^.art ',aktuell^.art,' aktuell^.farbe ',aktuell^.farbe,' aktuell^.pos',aktuell^.pos); readln;  END
   END
  END;
  IF neu <> nil THEN WHILE (neu^.nach <> nil) DO neu := neu^.nach;
  aktuell := aktuell^.nach;
 END;
 zuggenerator := wurzel;
END;

PROCEDURE zugAbbau(linie:STRING;farbe:SHORTINT; VAR zugliste:Tzugliste);

BEGIN
 IF(zugliste^.nach<>nil) THEN zugAbbau(linie,farbe,zugliste^.nach);
 dispose(zugliste); zugliste:=NIL;
END;

PROCEDURE figuren(figurenliste:Tfigurenliste);
VAR aktuell:Tfigurenliste;
BEGIN
 aktuell:=figurenliste;
 WHILE (aktuell<>NIL)
  DO
   BEGIN
    schreibeFigur(aktuell^.art*aktuell^.farbe);write(' ');
    schreibeposition(aktuell^.pos);write;
    IF aktuell^.geschlagen THEN write(' geschlagen ');
     writeln;
     aktuell:=aktuell^.nach;
   END
END;

FUNCTION bewerteZug ():INTEGER;
Var wert:INTEGER;
    feld:BYTE;
    aktuell:Tfigurenliste;
    suchende:BOOLEAN;

CONST auf   = 10;
      ab    =-10;
      links = -1;
      rechts= +1;

FUNCTION zaehleFigurenliste(figurenliste:Tfigurenliste):INTEGER;
VAR aktuell:Tfigurenliste;zaehler:INTEGER;
BEGIN
 aktuell:=figurenliste;zaehler:=c0;
 WHILE aktuell<>nil
 DO
 BEGIN
  IF NOT aktuell^.geschlagen THEN zaehler:=zaehler+c1;
  aktuell:=aktuell^.nach;
 END;
 zaehleFigurenliste:=zaehler;
END;


BEGIN (* BEWERTUNG ZUG mit bewerteZUG() *)
 wert:=0;
 aktuell:=figurenliste;
 WHILE (aktuell<>nil)
  DO
   BEGIN
    IF (NOT(aktuell^.geschlagen)AND(aktuell^.art=ct))
     THEN
         BEGIN
         wert:= wert+(aktuell^.art*aktuell^.farbe);
         suchende:=false;
         feld:=aktuell^.pos+auf;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+auf;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
         suchende:=false;
         feld:=aktuell^.pos+ab;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+ab;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
          suchende:=false;
         feld:=aktuell^.pos+links;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+links;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
          suchende:=false;
         feld:=aktuell^.pos+rechts;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
          wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
          IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+rechts;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
         END;(*if not geschlagen und turm*)

    IF (NOT(aktuell^.geschlagen)AND(aktuell^.art=cl))
     THEN
         BEGIN
         wert:= wert+(aktuell^.art*aktuell^.farbe);
         suchende:=false;
         feld:=aktuell^.pos+auf+rechts;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+auf+rechts;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
         suchende:=false;
         feld:=aktuell^.pos+ab+rechts;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+ab+rechts;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
          suchende:=false;
         feld:=aktuell^.pos+auf+links;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+auf+links;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
          suchende:=false;
         feld:=aktuell^.pos+ab+links;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+ab+links;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
         END;(*if not geschlagen und laeufer*)

    IF (NOT(aktuell^.geschlagen)AND(aktuell^.art=cd))
     THEN
         BEGIN
         wert:= wert+(aktuell^.art*aktuell^.farbe);
         suchende:=false;
         feld:=aktuell^.pos+auf+rechts;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+auf+rechts;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
         suchende:=false;
         feld:=aktuell^.pos+ab+rechts;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+ab+rechts;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
          suchende:=false;
         feld:=aktuell^.pos+auf+links;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+auf+links;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
          suchende:=false;
         feld:=aktuell^.pos+ab+links;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+ab+links;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
         suchende:=false;
         feld:=aktuell^.pos+auf;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+auf;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
         suchende:=false;
         feld:=aktuell^.pos+ab;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+ab;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
          suchende:=false;
         feld:=aktuell^.pos+links;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+links;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;
          suchende:=false;
         feld:=aktuell^.pos+rechts;
         IF(brett(.feld.)=dumy) THEN suchende:=true;
         WHILE(
               (
                (brett(.feld.)<>dumy)
               )
               AND(NOT(suchende))

              )
         DO
          BEGIN
           wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
           IF(brett(.feld.)<>c0) THEN suchende:=true;
           feld:=feld+rechts;
           IF(brett(.feld.)=dumy) THEN suchende:=true;
          END;

         END;(*if not geschlagen und dame*)


    IF ((NOT(aktuell^.geschlagen))AND(aktuell^.art=ck))
     THEN
      BEGIN (*KOENIGSBEWERTUNG*)
       wert:= wert+(aktuell^.art*aktuell^.farbe);


      IF (
                ((brett(.feld+auf.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+auf.)<>dumy))
                OR
                ((brett(.feld+auf.)>c0)AND(aktuell^.farbe<c0))
                OR
                (brett(.feld+auf.)=leer)
          )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (
                 ((brett(.feld+auf+rechts.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+auf+rechts.)<>dumy))
                 OR
                 ((brett(.feld+auf+rechts.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+auf+rechts.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (
                 ((brett(.feld+auf+links.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+auf+links.)<>dumy))
                 OR
                 ((brett(.feld+auf+links.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+auf+links.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (
                 ((brett(.feld+links.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+links.)<>dumy))
                 OR
                 ((brett(.feld+links.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+links.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
       IF (
                 ((brett(.feld+rechts.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+rechts.)<>dumy))
                 OR
                 ((brett(.feld+rechts.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+rechts.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);


       IF (
                 ((brett(.feld+ab+links.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+ab+links.)<>dumy))
                 OR
                 ((brett(.feld+ab+links.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+ab+links.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);


       IF (
                 ((brett(.feld+ab+rechts.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+ab+rechts.)<>dumy))
                 OR
                 ((brett(.feld+ab+rechts.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+ab+rechts.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (
                 ((brett(.feld+ab.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+ab.)<>dumy))
                 OR
                 ((brett(.feld+ab.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+ab.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF((attakiert(feld+auf       ,aktuell))OR(brett(.feld+auf.)=dumy       ))THEN wert:=wert-(1*aktuell^.farbe);
       IF((attakiert(feld+auf+rechts,aktuell))OR(brett(.feld+auf+rechts.)=dumy))THEN wert:=wert-(1*aktuell^.farbe);
       IF((attakiert(feld+links     ,aktuell))OR(brett(.feld+links.)=dumy     ))THEN wert:=wert-(1*aktuell^.farbe);
       IF((attakiert(feld+rechts    ,aktuell))OR(brett(.feld+rechts.)=dumy    ))THEN wert:=wert-(1*aktuell^.farbe);
       IF((attakiert(feld+ab+links  ,aktuell))OR(brett(.feld+ab+links.)=dumy  ))THEN wert:=wert-(1*aktuell^.farbe);
       IF((attakiert(feld+ab        ,aktuell))OR(brett(.feld+ab.)=dumy        ))THEN wert:=wert-(1*aktuell^.farbe);
       IF((attakiert(feld+auf+links ,aktuell))OR(brett(.feld+auf+links.)=dumy ))THEN wert:=wert-(1*aktuell^.farbe);
       IF((attakiert(feld+ab+rechts ,aktuell))OR(brett(.feld+ab+rechts.)=dumy ))THEN wert:=wert-(1*aktuell^.farbe);
       IF((attakiert(feld           ,aktuell)))                                 THEN wert:=wert-(1*aktuell^.farbe);

      END;(*Koenigsbewertung*)

     IF ((NOT(aktuell^.geschlagen))AND(aktuell^.art=cs))
     THEN
      BEGIN (*SPRINGERBEWERTUNG*)
       wert:= wert+(aktuell^.art*aktuell^.farbe);


       (* umgebung Springer *)

       IF (
                 ((brett(.feld+auf+auf+rechts.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+auf+auf+rechts.)<>dumy))
                 OR
                 ((brett(.feld+auf+auf+rechts.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+auf+auf+rechts.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe); //3 irrational 1 besser

       IF (
                 ((brett(.feld+auf+auf+links.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+auf+auf+links.)<>dumy))
                 OR
                 ((brett(.feld+auf+auf+links.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+auf+auf+links.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (
                 ((brett(.feld+ab+ab+rechts.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+ab+ab+rechts.)<>dumy))
                 OR
                 ((brett(.feld+ab+ab+rechts.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+ab+ab+rechts.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);
       IF (
                 ((brett(.feld+ab+ab+links.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+ab+ab+links.)<>dumy))
                 OR
                 ((brett(.feld+ab+ab+links.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+ab+ab+links.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (
                 ((brett(.feld+links+links+auf.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+links+links+auf.)<>dumy))
                 OR
                 ((brett(.feld+links+links+auf.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+links+links+auf.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (
                 ((brett(.feld+links+links+ab.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+links+links+ab.)<>dumy))
                 OR
                 ((brett(.feld+links+links+ab.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+links+links+ab.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);


       IF (
                 ((brett(.feld+rechts+rechts+auf.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+rechts+rechts+auf.)<>dumy))
                 OR
                 ((brett(.feld+rechts+rechts+auf.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+rechts+rechts+auf.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);


       IF (
                 ((brett(.feld+rechts+rechts+ab.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+rechts+rechts+ab.)<>dumy))
                 OR
                 ((brett(.feld+rechts+rechts+ab.)>c0)AND(aktuell^.farbe<c0))
                 OR
                 (brett(.feld+rechts+rechts+ab.)=leer)
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);




      END;(*Springerbewertung*)





   IF ((NOT(aktuell^.geschlagen))AND(aktuell^.art=cb))
     THEN
      BEGIN (*BauernBEWERTUNG*)
       wert:= wert+(aktuell^.art*aktuell^.farbe);
       IF (
                (brett(.feld+auf*aktuell^.farbe.)=leer)
           )
           THEN
                BEGIN
                 wert:=wert+(1*aktuell^.farbe);
                 IF (brett(.feld.)>=A7) AND (brett(.feld.)<=H7) AND (brett(.feld+(auf+auf)*aktuell^.farbe.)=leer)  AND (aktuell^.farbe=cschwarz)   THEN  wert:= wert+(aktuell^.art*aktuell^.farbe);
                 IF (brett(.feld.)<=H2) AND (brett(.feld+(auf+auf)*aktuell^.farbe.)=leer)                          AND (aktuell^.farbe=cweiss  )   THEN  wert:= wert+(aktuell^.art*aktuell^.farbe);
                END;

       IF (
                 ((brett(.feld+auf*aktuell^.farbe+rechts.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+auf*aktuell^.farbe+rechts.)<>dumy))
                 OR
                 ((brett(.feld+auf*aktuell^.farbe+rechts.)>c0)AND(aktuell^.farbe<c0))
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (
                 ((brett(.feld+auf*aktuell^.farbe+links.)<c0)AND(aktuell^.farbe>c0)AND(brett(.feld+auf*aktuell^.farbe+links.)<>dumy))
                 OR
                 ((brett(.feld+auf*aktuell^.farbe+links.)>c0)AND(aktuell^.farbe<c0))
           )
                THEN wert:=wert+(1*aktuell^.farbe)+ABS(brett(.feld.))*1*(aktuell^.farbe);

       IF (brett(.feld+(10*aktuell^.farbe).)=dumy)THEN wert:=wert+((cd+cs+cl)*aktuell^.farbe);
       IF (aktuell^.farbe = cweiss)
        THEN wert:=wert+(aktuell^.pos DIV 10)
        ELSE wert:=wert+(-1*(10-(aktuell^.pos DIV 10)));


      END;(*Bauernbewertung*)

     (* Zentrumsbewertung für alle Figuren zusätzlich zu Beginn des Spiels *)
      IF zaehleFigurenliste(figurenliste) >15 THEN
      wert:=wert +(
                   (
                   (5-ABS(5-(aktuell^.pos MOD 10)))
                   +
                   (5-ABS(5-(aktuell^.pos DIV 10)))
                   )*aktuell^.farbe
                  );

    aktuell:=aktuell^.nach;
   END;(*WHILE not nil*)
 bewerteZug := wert;
END;

PROCEDURE ComputerZugSetzen(VAR brett:Tbrett; VAR ziehe:Tziehe);
VAR aktuell:Tfigurenliste;
BEGIN
 //ShowMessage ('ComputerZugSetzen: Beginn');
 brett(.ziehe.vonpos.):=leer;
 brett(.ziehe.nachpos.):=ziehe.art*ziehe.farbe;
(* writeln(' farbe ',ziehe.farbe,' art ',ziehe.art,' ', ziehe.farbe*ziehe.art,' ',brett(.ziehe.nachpos.));*)
 aktuell:=figurenliste;
 WHILE (aktuell<>nil)
  DO
   BEGIN
    IF (
        (aktuell^.pos=ziehe.vonpos)AND
        (NOT(aktuell^.geschlagen)) AND
        (aktuell^.art=ziehe.art)   AND
        (aktuell^.farbe=ziehe.farbe)
       )
    THEN
     BEGIN
      aktuell^.pos:=ziehe.nachpos;

     END;
    aktuell:=aktuell^.nach;
   END;
   IF (ziehe.geschlagen<>NIL)
   THEN ziehe.geschlagen^.geschlagen:=true;
    //ShowMessage ('ComputerZugSetzen: Ende');
END;

PROCEDURE brettZugSetzen (VAR brett:Tbrett;VAR ziehe:Tziehe);
VAR aktuell:Tfigurenliste;
BEGIN
 brett(.ziehe.vonpos.):=leer;
 brett(.ziehe.nachpos.):=ziehe.art*ziehe.farbe;
 aktuell:=figurenliste;
 WHILE (aktuell<>nil)
  DO
   BEGIN
    IF (
        (aktuell^.pos=ziehe.vonpos)AND
        (NOT(aktuell^.geschlagen)) AND
        (aktuell^.art=ziehe.art)   AND
        (aktuell^.farbe=ziehe.farbe)
       )
    THEN
     BEGIN
      aktuell^.pos:=ziehe.nachpos;

     END;
     aktuell:=aktuell^.nach;
   END;
   IF (ziehe.geschlagen<>NIL)
    THEN ziehe.geschlagen^.geschlagen:=true;
END;

 PROCEDURE brettZugZuruecknehmen (VAR brett:Tbrett; VAR ziehe:Tziehe);
VAR aktuell:Tfigurenliste;
BEGIN
 brett(.ziehe.nachpos.):=leer;
 brett(.ziehe.vonpos.):=ziehe.art*ziehe.farbe;
 aktuell:=figurenliste;
 WHILE (aktuell<>nil)
  DO
   BEGIN
    IF (
        (aktuell^.pos=ziehe.nachpos)AND
        (NOT(aktuell^.geschlagen))  AND
        (aktuell^.art=ziehe.art)   AND
        (aktuell^.farbe=ziehe.farbe)
       )
     THEN
      BEGIN
       aktuell^.pos:=ziehe.vonpos;
      END;
       aktuell:=aktuell^.nach;
   END;
   IF (ziehe.geschlagen<>NIL)
        THEN
         BEGIN
          brett(.ziehe.geschlagen^.pos.):=ziehe.geschlagen^.art*
                                 ziehe.geschlagen^.farbe;
                                 ziehe.geschlagen^.geschlagen:=false;
          ziehe.geschlagen:=NIL;
         END;

END;

 FUNCTION matt (linie:STRING;farbe:SHORTINT; VAR figurenliste:Tfigurenliste):BOOLEAN;
 VAR aktuell:Tfigurenliste;
     aktuellerzug,koenigszugliste:Tzugliste;
     zug:Tziehe;
     alternativen:BOOLEAN;

 BEGIN
  matt:=true;
  alternativen:=false;
  aktuell:=figurenliste;
  koenigszugliste:=NIL;
  WHILE(aktuell <>NIL)
   DO
    BEGIN(*figurenliste*)
     IF ((aktuell^.art=ck)AND(aktuell^.farbe=farbe))THEN
      IF (attakiert(aktuell^.pos,aktuell))
        THEN
         BEGIN (*attakiert*)
         koenigszugliste:=nil;
         koenigszugliste:=zuggenerator(farbe,zug); // Parameter Zug wird hier nicht benoetigt ist indefiniert uebergeben da im Spiel fuer en passant genutzt
         aktuellerzug:=koenigszugliste;
         IF (aktuellerzug<>NIL)
          THEN
           BEGIN(*alternativen*)
           WHILE(aktuellerzug<>NIL)
            DO
             BEGIN
               zug.nachpos   :=aktuellerzug^.nachpos;
               zug.vonpos    :=aktuellerzug^.vonpos;
               zug.farbe     :=aktuellerzug^.farbe;
               zug.art       :=aktuellerzug^.art;
               zug.geschlagen:=aktuellerzug^.geschlagen;

               brettzugsetzen(brett,zug);
                IF NOT(attakiert(aktuell^.pos,aktuell))
                 THEN alternativen:=true;
               brettzugzuruecknehmen(brett,zug);
              aktuellerzug:=aktuellerzug^.nach;
              END;(*ENDE ZUGLIST*)
              IF (alternativen) THEN matt:=false ELSE matt := true;
              IF (koenigszugliste<>NIL)
              THEN zugabbau(linie,farbe,koenigszugliste);
           END(*alternativen*)
           ELSE matt:=true;
         END(*IF attakiert()*)
         ELSE matt:=false;
    aktuell:=aktuell^.nach;
    END;(*figurenliste*)



 END;(*matt*)

 FUNCTION zaehleZugliste(zugliste:Tzugliste):INTEGER;
 VAR aktuell:Tzugliste;zaehler:INTEGER;
 BEGIN
  aktuell:=zugliste;zaehler:=c0;
  WHILE aktuell<>nil
  DO
  BEGIN
   zaehler:=zaehler+c1;
   aktuell:=aktuell^.nach;
  END;
  zaehleZugliste:=zaehler;
 END;

 FUNCTION schach(farbe:SHORTINT):BOOLEAN;
 VAR aktuell:Tfigurenliste;
 BEGIN
  aktuell:=figurenliste;
  WHILE (aktuell<>NIL)
  DO
  BEGIN
   IF ((aktuell^.art=ck)AND(aktuell^.farbe=farbe))
    THEN
    IF(attakiert(aktuell^.pos,aktuell)) THEN schach:=true ELSE schach:=false;
   aktuell:=aktuell^.nach;
  END
 END;

 FUNCTION alphabeta (farbe, alpha, beta, tiefe, maxTiefe: INTEGER;linie:STRING;letzterzug:Tziehe): INTEGER;
  VAR bewertung: INTEGER;
      zugliste,aktuell:Tzugliste;
      zug:Tziehe;



  BEGIN (*alphabeta*)
     IF (matt(linie,farbe,figurenliste))
     THEN
      BEGIN
       alphabeta:=(c1000+maxtiefe-tiefe)*-farbe;
      END
     ELSE
     BEGIN
     IF (tiefe = maxTiefe)
      THEN alphabeta := bewerteZug()
     ELSE
     BEGIN
        zugliste:=nil;
        zugliste:= zuggenerator(farbe,letzterzug);
        aktuell := zugliste;
        WHILE aktuell <> NIL DO
        BEGIN
         zug.nachpos:=aktuell^.nachpos;
         zug.vonpos :=aktuell^.vonpos;
         zug.farbe  :=aktuell^.farbe;
         zug.art    :=aktuell^.art;
         zug.geschlagen:=aktuell^.geschlagen;

         brettZugSetzen (brett,zug);

         IF  (schach(farbe))
         THEN
         BEGIN
          brettZugZuruecknehmen (brett,zug);
         END
         ELSE
 	BEGIN

         (* ANFANG nicht schach *)
         bewertung := AlphaBeta (-farbe,beta,alpha,tiefe+1,maxTiefe,linie+'-',letzterzug);
         IF ((farbe=cweiss)  AND(bewertung>alpha)) THEN alpha:=bewertung;
         IF ((farbe=cschwarz)AND(bewertung<alpha)) THEN alpha:=bewertung;

         brettZugZuruecknehmen (brett,zug);


         IF((farbe=cweiss)AND(alpha>=beta)AND(zugliste<>nil))
          THEN
           BEGIN
            IF (zugliste<>NIL)THEN  zugAbbau(linie,farbe,zugliste); zugliste:= NIL; alphabeta:= alpha; aktuell:=nil;
           END;

         IF((farbe=cschwarz)AND(alpha<=beta)AND(zugliste<>nil))
          THEN
           BEGIN
            IF (zugliste<>NIL)
             THEN BEGIN zugAbbau(linie,farbe,zugliste); zugliste:= NIL;alphabeta:= alpha; aktuell:=nil; END;
           END;
         (* ENDE nicht schach *)
         END;

         IF (aktuell <>nil) THEN aktuell := aktuell^.nach;
        END;(*WHILE*)
        IF (zugliste<>NIL)
         THEN BEGIN zugAbbau(linie,farbe,zugliste); zugliste:= NIL;alphabeta:= alpha; aktuell:=nil; END;
        AlphaBeta := alpha;
     END;(*ELSE bewertung*)
     END;(*ELSE MATT *)
   END;(*alphabeta*)

 PROCEDURE bauernumwandlung(farbe:SHORTINT;VAR figurenliste:Tfigurenliste;letzterBauernzug:Tziehe);
 VAR
  aktuellefigur:Tfigurenliste;
  bewertungcs,bewertungcl,bewertungcd,bewertungct:Integer;
  umgewandeltIn:Byte;
 BEGIN
         aktuellefigur:=figurenliste;
         WHILE ((aktuellefigur^.pos<>letzterBauernzug.nachpos)AND (aktuellefigur<> NIL))
         DO
         BEGIN
          aktuellefigur:=aktuellefigur^.nach;
         END;
         IF aktuellefigur<>NIL
         THEN
         BEGIN
         aktuellefigur^.art:=cs;brett(.aktuellefigur^.pos.):=cs*farbe;
         bewertungcs := AlphaBeta (-farbe,-farbe*cmaxInteger,-farbe*cminInteger,1,1,'-',letzterBauernzug);
         umgewandeltIn :=bewertungcs;

         aktuellefigur^.art:=cl;brett(.aktuellefigur^.pos.):=cl*farbe;
         bewertungcl := AlphaBeta (-farbe,-farbe*cmaxInteger,-farbe*cminInteger,1,1,'-',letzterBauernzug);

         aktuellefigur^.art:=cd;brett(.aktuellefigur^.pos.):=cd*farbe;
         bewertungcd := AlphaBeta (-farbe,-farbe*cmaxInteger,-farbe*cminInteger,1,1,'-',letzterBauernzug);

         aktuellefigur^.art:=ct;brett(.aktuellefigur^.pos.):=ct*farbe;
         bewertungct := AlphaBeta (-farbe,-farbe*cmaxInteger,-farbe*cminInteger,1,1,'-',letzterBauernzug);



         IF (farbe=cweiss)
         THEN
         BEGIN
          IF bewertungcl >= bewertungcs
          THEN
          BEGIN
          aktuellefigur^.art:=cl;brett(.aktuellefigur^.pos.):=cl*farbe;
          umgewandeltIn:=bewertungcl;
          END;
          IF bewertungcd >= bewertungcl
          THEN
          BEGIN
          aktuellefigur^.art:=cd;brett(.aktuellefigur^.pos.):=cd*farbe;
          umgewandeltIn:=bewertungcd;
          END;
          IF bewertungct >= bewertungcd
          THEN
          BEGIN
          aktuellefigur^.art:=ct;brett(.aktuellefigur^.pos.):=ct*farbe;
          umgewandeltIn:=bewertungct;
          END;
         END
         ELSE (*farbe=cschwarz*)
         BEGIN
          IF bewertungcl <= bewertungcs
          THEN
          BEGIN
          aktuellefigur^.art:=cl;brett(.aktuellefigur^.pos.):=cl*farbe;
          umgewandeltIn:=bewertungcl;
          END;
          IF bewertungcd <= bewertungcl
          THEN
          BEGIN
          aktuellefigur^.art:=cd;brett(.aktuellefigur^.pos.):=cd*farbe;
          umgewandeltIn:=bewertungcd;
          END;
          IF bewertungct <= bewertungcd
          THEN
          BEGIN
          aktuellefigur^.art:=ct;brett(.aktuellefigur^.pos.):=ct*farbe;
          umgewandeltIn:=bewertungct;
          END;
         END
        END
        ELSE write(' umgewandelt in Fehler');


  write(' umgewandelt in '); schreibeFigur(umgewandeltIn);
 END;


 FUNCTION computerzug (farbe, alpha, beta, tiefe, maxTiefe: INTEGER;linie:STRING): INTEGER;
  VAR bewertung,zuglistenzaehler,schachzaehler: INTEGER;
      zugliste,aktuell:Tzugliste;
      zug,computerzieht:Tziehe;
      kannziehen:BOOLEAN;


  BEGIN
     kannziehen:=false;zuglistenzaehler:=c0;schachzaehler:=c0;
     IF (matt(linie,farbe,figurenliste))
     THEN
      BEGIN
       computerzug:=cmaxinteger*farbe; writeln(' matt erkannt ');
       endmatt:=true;
      END
     ELSE
     BEGIN
        (*writeln(' nicht matt ');*)
        zugliste:=nil;
        zugliste:= zuggenerator(farbe,zug);   // Paramter zug beim ersten Zug undefiniert
        zuglistenzaehler:=zaehleZugliste(zugliste);
        aktuell := zugliste;
        IF (zugliste<>NIL)THEN

        BEGIN
        kannziehen:=true;

        zug.nachpos:=aktuell^.nachpos;
        zug.vonpos :=aktuell^.vonpos;
        zug.farbe  :=aktuell^.farbe;
        zug.art    :=aktuell^.art;
        zug.geschlagen:=aktuell^.geschlagen;
        computerzieht.nachpos:=aktuell^.nachpos;
        computerzieht.vonpos :=aktuell^.vonpos;
        computerzieht.farbe  :=aktuell^.farbe;
        computerzieht.art    :=aktuell^.art;
        computerzieht.geschlagen:=aktuell^.geschlagen;
        END;

        WHILE aktuell <> NIL DO
        BEGIN

         zug.nachpos:=aktuell^.nachpos;
         zug.vonpos :=aktuell^.vonpos;
         zug.farbe  :=aktuell^.farbe;
         zug.art    :=aktuell^.art;
         zug.geschlagen:=aktuell^.geschlagen;


         brettZugSetzen (brett,zug);

         IF  schach(farbe)
         THEN
         BEGIN
          brettZugZuruecknehmen (brett,zug); schachzaehler:=schachzaehler+c1;
         END
         ELSE
 	BEGIN

         (* ANFANG nicht schach *)


         bewertung := alphabeta (-farbe,beta,alpha,tiefe+1,maxTiefe,linie+'-',zug);


         IF ((farbe=cweiss)  AND(bewertung>alpha))
          THEN
           BEGIN
            alpha:=bewertung;
            computerzieht.nachpos:=aktuell^.nachpos;
            computerzieht.vonpos :=aktuell^.vonpos;
            computerzieht.farbe  :=aktuell^.farbe;
            computerzieht.art    :=aktuell^.art;
            computerzieht.geschlagen:=aktuell^.geschlagen;
           END;
         IF ((farbe=cschwarz)AND(bewertung<alpha))
          THEN
           BEGIN
            alpha:=bewertung;
            computerzieht.nachpos:=aktuell^.nachpos;
            computerzieht.vonpos :=aktuell^.vonpos;
            computerzieht.farbe  :=aktuell^.farbe;
            computerzieht.art    :=aktuell^.art;
            computerzieht.geschlagen:=aktuell^.geschlagen;
           END;

         brettZugZuruecknehmen (brett,zug);

          IF((farbe=cweiss)AND(alpha>=beta)AND(zugliste<>nil))
          THEN
           BEGIN
            IF (zugliste <>NIL)
             THEN BEGIN zugAbbau(linie,farbe,zugliste); zugliste:=NIL;computerzug:= alpha; aktuell:=nil; END;
           END;

         IF((farbe=cschwarz)AND(alpha<=beta)AND(zugliste<>nil))
          THEN
           BEGIN
            IF (zugliste<>NIL)
             THEN BEGIN zugAbbau(linie,farbe,zugliste); zugliste:=NIL;computerzug:= alpha; aktuell:=nil; END;
           END;
        (* ENDE nicht schach *)
         END;

         IF (aktuell<>NIL)THEN aktuell := aktuell^.nach;
        END;(*WHILE*)


       IF (kannziehen AND(zuglistenzaehler-schachzaehler>c0))
       THEN
       BEGIN
        write(linie,'COMPUTERZUG -> =');

        IF (farbe=cweiss) THEN write(' WEISS   AM ZUG ')
                          ELSE write(' SCHWARZ AM ZUG ');
        schreibeFigur (computerzieht.art*computerzieht.farbe);write(' ');schreibePosition(computerzieht.vonpos );
        IF(computerzieht.geschlagen<>nil)
         THEN write(' SCHLAEGT NACH ') ELSE write(' NACH ');
        schreibePosition(computerzieht.nachpos);writeln;
        ComputerZugSetzen(brett,computerzieht);
        (*Damenumwandlung---------------------------------------------------------------------------------------------------------------------------------------------------------------------*)
         IF ((computerzieht.art=cb)AND((brett(.computerzieht.nachpos+(10*computerzieht.farbe).)=dumy)))THEN bauernumwandlung(computerzieht.farbe,figurenliste,computerzieht);
        IF (zugliste<>nil)
        THEN BEGIN zugAbbau(linie,farbe,zugliste); zugliste:=NIL; END;
       END(*kannziehen*)
       ELSE BEGIN writeln ('kannziehen ',kannziehen,' zuglistenzaehler ',zuglistenzaehler,' schachzaehler ',schachzaehler); writeln('die Stellung ist patt'); patt:=true; END;
        computerzug:= alpha;
       END;(*ELSE MATT*)
   END;(*computerzug*)

 FUNCTION spielerzieht (farbe, alpha, beta, tiefe, maxTiefe: INTEGER;linie:STRING): BOOLEAN;
  VAR bewertung,zuglistenzaehler,schachzaehler: INTEGER;
      zugliste,aktuell:Tzugliste;
      zug,computerzieht:Tziehe;
      spielerkannziehen,kannziehen:BOOLEAN;


  BEGIN
     //ShowMessage ('Weiss am Zug: Beginn');
     kannziehen:=false;zuglistenzaehler:=c0;schachzaehler:=c0;spielerkannziehen:=false;
     IF (matt(linie,farbe,figurenliste))
     THEN
      BEGIN
       spielerzieht:=true;// false //cmaxinteger*farbe; writeln(' matt erkannt ');
       endmatt:=true;
       //ShowMessage ('Weiss am Zug: Matt erkannt');
      END
     ELSE
     BEGIN
        (*writeln(' nicht matt ');*)
        zugliste:=nil;
        zugliste:= zuggenerator(farbe,zug);   // Paramter zug beim ersten Zug undefiniert
        zuglistenzaehler:=zaehleZugliste(zugliste);
        aktuell := zugliste;
        IF (zugliste<>NIL)THEN

        BEGIN
        kannziehen:=true;

        zug.nachpos:=aktuell^.nachpos;
        zug.vonpos :=aktuell^.vonpos;
        zug.farbe  :=aktuell^.farbe;
        zug.art    :=aktuell^.art;
        zug.geschlagen:=aktuell^.geschlagen;
        computerzieht.nachpos:=aktuell^.nachpos;
        computerzieht.vonpos :=aktuell^.vonpos;
        computerzieht.farbe  :=aktuell^.farbe;
        computerzieht.art    :=aktuell^.art;
        computerzieht.geschlagen:=aktuell^.geschlagen;
        END;

        WHILE (aktuell <> NIL) DO
        BEGIN

         zug.nachpos:=aktuell^.nachpos;
         zug.vonpos :=aktuell^.vonpos;
         zug.farbe  :=aktuell^.farbe;
         zug.art    :=aktuell^.art;
         zug.geschlagen:=aktuell^.geschlagen;


         brettZugSetzen (brett,zug);

         IF  schach(farbe)
         THEN
         BEGIN
          brettZugZuruecknehmen (brett,zug); schachzaehler:=schachzaehler+c1;
          //ShowMessage ('Weiss am Zug: Eigentor: Schach erkannt');
         END
         ELSE
 	BEGIN

         (* ANFANG nicht schach *)

         IF ((spielerzug.vonpos=aktuell^.vonpos)AND(spielerzug.nachpos=aktuell^.nachpos))
          THEN
           BEGIN
            spielerkannziehen:=true;
            //weissAmZug:=false;//
            //break;
            //statt break
            //ShowMessage ('Weiss am Zug: Legaler Zug erkannt Beginn');
            computerzieht.nachpos:=aktuell^.nachpos;
            computerzieht.vonpos :=aktuell^.vonpos;
            computerzieht.farbe  :=aktuell^.farbe;
            computerzieht.art    :=aktuell^.art;
            computerzieht.geschlagen:=aktuell^.geschlagen;
            IF (zugliste<>NIL)
              THEN BEGIN zugAbbau(linie,farbe,zugliste); zugliste:=NIL; aktuell:=nil; END;
           END;
          brettZugZuruecknehmen (brett,zug);
         END;

        IF (aktuell<>NIL)  THEN aktuell := aktuell^.nach;
        END;(*WHILE*)

        //ShowMessage ('Weiss am Zug: Legaler Zug ermittelt ENDE');

        //ShowMessage ('Weiss am Zug: Legaler Zug erkannt Ende');

       IF (kannziehen AND(zuglistenzaehler-schachzaehler>c0) AND spielerkannziehen)
       THEN
       BEGIN
        //ShowMessage ('Weiss am Zug: Zug wird ausgeführt');
        ComputerZugSetzen(brett,computerzieht);
        spielerzieht:=false;
        //ShowMessage ('Weiss am Zug: Legaler Zug wird ausgeführt');
        (*Damenumwandlung---------------------------------------------------------------------------------------------------------------------------------------------------------------------*)
         IF ((computerzieht.art=cb)AND((brett(.computerzieht.nachpos+(10*computerzieht.farbe).)=dumy)))THEN bauernumwandlung(computerzieht.farbe,figurenliste,computerzieht);
       END(*kannziehen*)
       ELSE
       BEGIN
        spielerzieht:= true;
        //IF (NOT(kannziehen) OR (zuglistenzaehler-schachzaehler=c0)) THEN patt:=true;
       END;
       END;(*ELSE MATT*)
       //ShowMessage ('Weiss am Zug: Ende');
   END;(*spielerzieht*)
 PROCEDURE kleinerochade(figurenliste:Tfigurenliste;farbe:SHORTINT);
 VAR aktuell:Tfigurenliste;
     zaehler,Ex,Fx,Gx,Hx:BYTE;
 CONST
       rechts= +1;
 BEGIN
  aktuell:=figurenliste;
  zaehler:=c0;
  IF farbe=cschwarz
  THEN
   BEGIN
    Ex:=E8;Hx:=H8;Fx:=F8;Gx:=G8;
   END
  ELSE
   BEGIN
    Ex:=E1;Hx:=H1;Fx:=F1;Gx:=G1;
   END;
  WHILE (aktuell<>NIL)
   DO
    BEGIN
     IF ((aktuell^.art=ck)AND (aktuell^.pos=Ex)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
      BEGIN
       IF NOT(attakiert(aktuell^.pos,aktuell)) THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+rechts,aktuell)) AND (brett(.Fx.)=leer))
        THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+rechts+rechts,aktuell)) AND (brett(.Gx.)=leer))
       THEN zaehler:=zaehler+1;
      END;
      IF ((aktuell^.art=ct)AND (aktuell^.pos=Hx)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
       IF NOT(attakiert(aktuell^.pos,aktuell))
        THEN zaehler:=zaehler+1;
      aktuell:=aktuell^.nach;
     END;

   IF zaehler=4
   THEN
    BEGIN
    aktuell:=figurenliste;
    WHILE (aktuell<>NIL)
    DO
     BEGIN
     IF ((aktuell^.art=ck)AND (aktuell^.pos=Ex)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
      BEGIN
       aktuell^.pos:=Gx;brett(.Gx.):=ck*farbe;brett(.Ex.):=leer;
      END;
     IF ((aktuell^.art=ct)AND (aktuell^.pos=Hx)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
      BEGIN
       aktuell^.pos:=Fx;brett(.Fx.):=ct*farbe;brett(.Hx.):=leer;
      END;
     aktuell:=aktuell^.nach;
     END;
    END;
     IF farbe=cweiss Then rochiertweiss:=true ELSE rochiertschwarz := true;
 END;

 FUNCTION kleinerochademoeglich(figurenliste:Tfigurenliste;farbe:SHORTINT):BOOLEAN;
 VAR aktuell:Tfigurenliste;
     zaehler,Ex,Fx,Gx,Hx:BYTE;
 CONST rechts= +1;

 BEGIN
  aktuell:=figurenliste;
  zaehler:=c0;
  IF farbe=cschwarz
  THEN
   BEGIN
    Ex:=E8;Hx:=H8;Fx:=F8;Gx:=G8;
   END
  ELSE
   BEGIN
    Ex:=E1;Hx:=H1;Fx:=F1;Gx:=G1;
   END;
  WHILE (aktuell<>NIL)
   DO
    BEGIN
     IF ((aktuell^.art=ck)AND (aktuell^.pos=Ex)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
      BEGIN
       IF NOT(attakiert(aktuell^.pos,aktuell)) THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+rechts,aktuell)) AND (brett(.Fx.)=leer))
        THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+rechts+rechts,aktuell)) AND (brett(.Gx.)=leer))
       THEN zaehler:=zaehler+1;
      END;
     IF ((aktuell^.art=ct)AND (aktuell^.pos=Hx)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
     THEN
      IF NOT(attakiert(aktuell^.pos,aktuell))
       THEN zaehler:=zaehler+1;
     aktuell:=aktuell^.nach;
    END;
   IF zaehler=4
   THEN
    kleinerochademoeglich:=true ELSE kleinerochademoeglich:=false;
 END;

 PROCEDURE grosserochade(figurenliste:Tfigurenliste;farbe:SHORTINT);
 VAR aktuell:Tfigurenliste;
     zaehler,Ax,Bx,Cx,Dx, Ex:BYTE;
 CONST links = -1;

 BEGIN
  aktuell:=figurenliste;
  zaehler:=c0;
  IF farbe=cschwarz
  THEN
   BEGIN
    Ax:=A8;Bx:=B8;Cx:=C8;Dx:=D8; Ex:=E8;
   END
  ELSE
   BEGIN
    Ax:=A1;Bx:=B1;Cx:=C1;Dx:=D1; Ex:=E1;
   END;
  WHILE (aktuell<>NIL)
   DO
    BEGIN
     IF ((aktuell^.art=ck)AND (aktuell^.pos=Ex)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
      BEGIN
       IF NOT(attakiert(aktuell^.pos,aktuell)) THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+links,aktuell)) AND (brett(.Dx.)=leer))
        THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+links+links,aktuell)) AND (brett(.Cx.)=leer))
       THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+links+links+links,aktuell)) AND (brett(.Bx.)=leer))
       THEN zaehler:=zaehler+1;
      END;
      IF ((aktuell^.art=ct)AND (aktuell^.pos=Ax)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
       IF NOT(attakiert(aktuell^.pos,aktuell))
        THEN zaehler:=zaehler+1;
      aktuell:=aktuell^.nach;
     END;

   IF zaehler=5
   THEN
    BEGIN
    aktuell:=figurenliste;
    WHILE (aktuell<>NIL)
    DO
     BEGIN
     IF ((aktuell^.art=ck)AND (aktuell^.pos=Ex)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
      BEGIN
       aktuell^.pos:=Bx;brett(.Bx.):=ck*farbe;brett(.Ex.):=leer;
      END;
     IF ((aktuell^.art=ct)AND (aktuell^.pos=Ax)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
      BEGIN
       aktuell^.pos:=Cx;brett(.Cx.):=ct*farbe;brett(.Ax.):=leer;
      END;
     aktuell:=aktuell^.nach;
     END;
    END;
     IF farbe=cweiss Then rochiertweiss:=true ELSE rochiertschwarz := true;
 END;

 FUNCTION grosserochademoeglich(figurenliste:Tfigurenliste;farbe:SHORTINT):BOOLEAN;
 VAR aktuell:Tfigurenliste;
     zaehler,Ax,Bx,Cx,Dx, Ex:BYTE;
 CONST links = -1;

 BEGIN
  aktuell:=figurenliste;
  zaehler:=c0;
  IF farbe=cschwarz
  THEN
   BEGIN
    Ax:=A8;Bx:=B8;Cx:=C8;Dx:=D8; Ex:=E8;
   END
  ELSE
   BEGIN
    Ax:=A1;Bx:=B1;Cx:=C1;Dx:=D1; Ex:=E1;
   END;
  WHILE (aktuell<>NIL)
   DO
    BEGIN
     IF ((aktuell^.art=ck)AND (aktuell^.pos=Ex)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
      THEN
      BEGIN
       IF NOT(attakiert(aktuell^.pos,aktuell)) THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+links,aktuell)) AND (brett(.Dx.)=leer))
        THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+links+links,aktuell)) AND (brett(.Cx.)=leer))
        THEN zaehler:=zaehler+1;
       IF (NOT(attakiert(aktuell^.pos+links+links+links,aktuell)) AND (brett(.Bx.)=leer))
        THEN zaehler:=zaehler+1;
      END;
     IF ((aktuell^.art=ct)AND (aktuell^.pos=Ax)AND (aktuell^.farbe=farbe)AND (aktuell^.geschlagen=false))
     THEN
      IF NOT(attakiert(aktuell^.pos,aktuell))
       THEN zaehler:=zaehler+1;
     aktuell:=aktuell^.nach;
    END;
   IF zaehler=5
   THEN
    grosserochademoeglich:=true ELSE grosserochademoeglich:=false;
 END;


end.

