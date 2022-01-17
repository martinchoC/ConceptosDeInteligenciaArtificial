/*

  Representacion grafica de una mina con 1 fila y 12 columnas:

     1   2   3   4   5   6   7   8   9   10  11  12 
    _______________________________________________
1  | # | V1|   |   | L1| R1|   | ~ | ! | D | C | P |
   |___|___|___|___|___|___|___|___|___|___|___|___|



-----------------------------------------------
Referencias de Suelo:

 ____
 |   | : Celda con suelo firme
 |___|

 ____
 | ~ | : Celda con suelo resbaladizo
 |___|

 ____
 | # | : Sitio de colocacion de carga explosiva
 |___|

 ____
 | ! | : Posicion para la detonacion
 |___|


-----------------------------------------------
Referencias de Objetos:

 Ri: Reja i

 Li: Llave i

 C: Carga Explosiva

 D: Detonador

 P: Pilar

 Vi: Valla con altura i

-----------------------------------------------
IMPORTANTE: Para aquellas celdas que albergan objetos (reja, llave, carga, detonador, pilar o valla)
la grilla dibujada no ilustra el tipo de suelo de la celda (debe observarse en la coleccion de hechos
definida a continuacion).

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/*
    Configuracion de la mina ilustrada

    Coleccion de Hechos celda/2, estaEn/2, ubicacionCarga/2, sitioDetonacion/1 y abreReja/2:
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Celdas de la mina:

celda([1,1], resbaladizo).
celda([1,2], firme).
celda([1,3], firme).
celda([1,4], firme).
celda([1,5], firme).
celda([1,6], resbaladizo).
celda([1,7], firme).
celda([1,8], resbaladizo).
celda([1,9], firme).
celda([1,10], resbaladizo).
celda([1,11], firme).
celda([1,12], resbaladizo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Objetos en la mina:

% Rejas:
estaEn([r, r1], [1,6]).

% Llaves:
estaEn([l, l1], [1,5]).

% Carga:
estaEn([c, c1], [1,11]).

% Detonador:
estaEn([d, d1, no], [1,10]).

% Pilares:
estaEn([p, p1, 3], [1,12]).

% Vallas:
estaEn([v, v1, 3], [1,2]).


% Sitio donde debe ser ubicada la Carga
ubicacionCarga([1,1]).

% Sitios habilitados para efectuar la detonacion
sitioDetonacion([1,9]).

% Indicador de que llave abre que reja
abreReja([l, l1], [r, r1]).