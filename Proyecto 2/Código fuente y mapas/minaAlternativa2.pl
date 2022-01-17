/*

  Representacion grafica de una mina con 6 filas y 6 columnas:

     1   2   3   4   5   6  
    _______________________
1  | P | P | P |   |   |   |
   |___|___|___|___|___|___|
2  | P | # | P | ! | ~ |   |
   |___|___|___|___|___|___|
3  | P | V1| P | P |   |   |
   |___|___|___|___|___|___|
4  | C |   | V2| # | ~ |   |
   |___|___|___|___|___|___|
5  | ~ |   | V3|   |   | ~ |
   |___|___|___|___|___|___|
6  | ~ | ! | V4|   | D |   |
   |___|___|___|___|___|___|
     1   2   3   4   5   6  


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
celda([1,4], resbaladizo).
celda([1,5], firme).
celda([1,6], resbaladizo).


celda([2,1], resbaladizo).
celda([2,2], firme).
celda([2,3], firme).
celda([2,4], resbaladizo).
celda([2,5], resbaladizo).
celda([2,6], resbaladizo).


celda([3,1], resbaladizo).
celda([3,2], firme).
celda([3,3], firme).
celda([3,4], resbaladizo).
celda([3,5], firme).
celda([3,6], firme).


celda([4,1], firme).
celda([4,2], firme).
celda([4,3], firme).
celda([4,4], firme).
celda([4,5], resbaladizo).
celda([4,6], firme).


celda([5,1], firme).
celda([5,2], firme).
celda([5,3], firme).
celda([5,4], firme).
celda([5,5], firme).
celda([5,6], resbaladizo).


celda([6,1], resbaladizo).
celda([6,2], firme).
celda([6,3], resbaladizo).
celda([6,4], firme).
celda([6,5], firme).
celda([6,6], firme).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Objetos en la mina:

% Rejas:
estaEn([r, r2], [4,3]).

% Llaves:
estaEn([l, l2], [5,3]).

% Carga:
estaEn([c, c1], [2,6]).

% Detonador:
estaEn([d, d1, no], [6,5]).

% Pilares:
estaEn([p, p1, 3], [1,1]).
estaEn([p, p2, 5], [1,2]).
estaEn([p, p3, 7], [1,3]).
estaEn([p, p1, 3], [2,1]).
estaEn([p, p2, 5], [2,3]).
estaEn([p, p3, 7], [3,1]).
estaEn([p, p4, 6], [3,3]).
estaEn([p, p6, 8], [3,4]).

% Vallas:
estaEn([v, v1, 3], [3,2]).
estaEn([v, v2, 4], [4,3]).
estaEn([v, v3, 2], [5,3]).
estaEn([v, v4, 1], [6,3]).


% Sitio donde debe ser ubicada la Carga
ubicacionCarga([4,4]).

% Sitios habilitados para efectuar la detonacion
sitioDetonacion([2,4]).
sitioDetonacion([6,2]).
