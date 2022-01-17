%----------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------PROYECTO 1------------------------------------------------------------
%----------------------------------------------------------CASTRO, Martin----------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------------

% Declaracion de operadores
:-op(400,fy,'no').
:-op(500,yfx,'and').
:-op(600,yfx,'or').
:-op(700,yfx,'->').
:-op(800,yfx,'equiv').

% Valores de verdad
% 1: verdadero (true)
% 0: falso (false)
%Elegí esta notación, que personalmente es más familiar que usar true o false.

% Definicion de valor_de_verdad
% valor_de_verdad(?V) si V es un valor de verdad.
valor_de_verdad(0).
valor_de_verdad(1).

% funcion_de_verdad(+Op, +V1, +V2, -V) si Op(V1,V2) = V
% funcion_de_verdad(+Op, +V1, -V) si Op(V1) = V
funcion_de_verdad('no',1,0).
funcion_de_verdad('no',0, 1).
funcion_de_verdad('and',1,1,1):-!.
funcion_de_verdad('and',_,_,0).
funcion_de_verdad('or',0,0,0):-!.
funcion_de_verdad('or',_,_,1).
funcion_de_verdad('->',1,0,0):-!.
funcion_de_verdad('->',_,_,1).
funcion_de_verdad('equiv',X,X,1):-!.
funcion_de_verdad('equiv',_,_,0).

% Definición del valor de una fbf en una interpretación
% valor(+F, +I, -V) se verifica si el valor de la fbf F en la interpretacion I es V

% Ejemplo:
% ?-valor((a or b) and (no b or c),[(a,1),(b,0),(c,1)],V).
% V=1
% ?-valor((a or b) and (no b or c),[(a,0),(b,0),(c,1)],V).
% V=0

valor(F,I,V):-memberchk((F,V),I). 
% memberchk/2: memberchk(Elem,List)es verdadero cuando Elem es un elemento de la Lista. Esta variante de member/ 2 es semi determinista y, 
% por lo general, se utiliza para probar la pertenencia a una lista.
% ojo! memberchk no hace backtracking!!!
% Ejemplo memberchk(?Elem, +List)
% findall(X, member(X, [one,two,three]), Bag).
% Bag = [one, two, three].
valor(no A,I,V):-valor(A,I,VA),funcion_de_verdad(no,VA,V).
valor(F,I,V):-F=..[Op,A,B],valor(A,I,VA),valor(B,I,VB),funcion_de_verdad(Op,VA,VB,V).

% Interpretacion principal I de la fbf F
% interpretaciones_fbf(+F,-L) se verifica si L es el conjunto de las interpretaciones principales de la fbf F.

% Ejemplo:
% ?- interpretaciones_fbf((a or b) and (no b or c),L).
% L=[[(a,0),(b,0),(c,0)],
% [(a,0),(b,0),(c,1)],
% [(a,0),(b,1),(c,0)],
% [(a,0),(b,1),(c,1)],
% [(a,1),(b,0),(c,0)],
% [(a,1),(b,0),(c,1)],
% [(a,1),(b,1),(c,0)],
% [(a,1),(b,1),(c,1)]].
interpretaciones_fbf(F,U):-findall(I,interpretacion_fbf(I,F),U).

% Interpretacion I de una fbf F
% interpretacion_fbf(?I,+F) se verifica si I es una interpretacion de la fbf F.

% Ejemplo:
% ?- interpretacion_fbf(I,(a or b) and (no b or c)).
% I=[(a,0),(b,0),(c,0)];
% I=[(a,0),(b,0),(c,1)];
% I=[(a,0),(b,1),(c,0)];
% I=[(a,0),(b,1),(c,1)];
% I=[(a,1),(b,0),(c,0)];
% I=[(a,1),(b,0),(c,1)];
% I=[(a,1),(b,1),(c,0)];
% I=[(a,1),(b,1),(c,1)];
% 0.
interpretacion_fbf(I,F):-simbolos_fbf(F,U),interpretacion_simbolos(U,I).

% simbolos de una fbf
% simbolos_fbf(+F,?U) se verifica si U es el conjunto ordenado de los simbolos proposicionales de la fbf F.

%Ejemplo:
% ?-símbolos_fbf((a or b) and (no b or c),U).
% U=[a,b,c]

simbolos_fbf(F,U):-simbolos_fbf_aux(F,U1),sort(U1,U).
% sort/2: es verdadero si se puede unificar con una lista que contiene los elementos de la Lista, ordenada según el orden estándar de los términos. 
% Los duplicados se eliminan. El predicado sort / 2 puede ordenar una lista cíclica y devolver una versión no cíclica con los mismos elementos.
simbolos_fbf_aux(F,[F]):-atom(F).
% atom/1: es verdadero si el término está ligado a un átomo.
simbolos_fbf_aux(no F,U):-simbolos_fbf_aux(F,U).
simbolos_fbf_aux(F,U):- F=..[_Op,A,B],simbolos_fbf_aux(A,UA),simbolos_fbf_aux(B,UB),union(UA,UB,U).
% union/3: es verdadero si U unifica con la union de las listas UA y UB 

% Interpretacion de una lista de simbolos
% interpretacion_simbolos(+L,-I) se verifica si I es una interpretacion de la lista de simbolos proposicionales L.

% Ejemplo:
% ?- interpretación_simbolos([a,b,c],I).
% I=[(a,0),(b,0),(c,0)];
% I=[(a,0),(b,0),(c,1)];
% I=[(a,0),(b,1),(c,0)];
% I=[(a,0),(b,1),(c,1)];
% I=[(a,1),(b,0),(c,0)];
% I=[(a,1),(b,0),(c,1)];
% I=[(a,1),(b,1),(c,0)];
% I=[(a,1),(b,1),(c,1)];
% 0.

interpretacion_simbolos([],[]).
interpretacion_simbolos([A|L],[(A,V)|IL]):-valor_de_verdad(V),interpretacion_simbolos(L,IL).

% Comprobacion de modelo de una fbf
% es_modelo_fbf(+I,+F) se verifica si la interpretacion I es un modelo de la fbf F.

% Ejemplo:
% ?-es_modelo_fbf([(a,1),(b,0),(c,1)],(a or b) and (no b or c)).
% 1
% ?-es_modelo_fbf([(p,0),(q,0),(r,1)],(a or b) and (no b or c)).
% 0

es_modelo_fbf(I,F):-valor(F,I,V),V=1.

% Calculo de los modelos principales de una fbf
% modelo_fbf(?I,+F) se verifica si I es un modelo principal de la fbf F.

% Ejemplo:
% ?-modelo_fbf(I,(a or b) and (no b or c)).
% I=[(a,0),(b,1),(c,1)];
% I=[(a,1),(b,0),(c,0)];
% I=[(a,1),(b,0),(c,1)];
% I=[(a,1),(b,1),(c,1)];
% 0

modelo_fbf(I,F):-interpretacion_fbf(I,F),es_modelo_fbf(I,F).

% modelos_fbf(+F,-L) se verifica si L es el conjunto de los modelos principales de la fbf F.

% Ejemplo:
% ?-modelos_fbf((a or b) and (no b or c),L).
% L=[[(a,0),(b,1),(c,1)],
% [(a,1),(b,0),(c,0)],
% [(a,1),(b,0),(c,1)],
% [(a,1),(b,1),(c,1)]]

modelos_fbf(F,L):-findall(I,modelo_fbf(I,F),L).

%----------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------EJERCICIO 1------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------------

%listarModelosFbf/0 solicita el ingreso de una fbf.
listarModelosFbf:- nl, write('Ingrese una formula bien formada (fbf) finalizada en punto(.): '), ver_respuesta_ejercicio_1.
ver_respuesta_ejercicio_1:- read(F), nl, write('Los modelos de la fbf ingresada son: '),nl,modelos_fbf(F,L),formatoModelosFbf(L).

formatoModelosFbf([]).
formatoModelosFbf([Cabeza|Resto]):- 
    write('['),write(Cabeza),write(']'),nl,formatoModelosFbf(Resto).
    
%----------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------EJERCICIO 2------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------------

interpretarFbf:- nl, write('Ingrese una formula bien formada (fbf) de la logica proposicional'),nl,
                     write('terminada en "." y presione ENTER al finalizar: '), ver_respuesta_ejercicio_2.
ver_respuesta_ejercicio_2:- read(F), nl, modelos_fbf(F,L), nl,
                            write('Bajo la interpretacion que considera a las vocales como verdaderas'),nl,
                            write('y al resto de las letras proposicionales como falsas, la fbf ingresada es: '), buscarModelo(L),nl,nl,
                            write('**En este ejercicio, si en la lista de modelos alguno cumple las restricciones del ejercicio, verdadero, sino falso. '),nl,
                            write('Los modelos validos de la fbf son: '), nl, formatoModelosFbf(L).

esVocal(X,Y):- (X='a'; X='e'; X='i'; X='o'; X='u'), Y = 1.
esConsonante(X,Y):- not(esVocal(X,_)), Y = 0.

%Chequea si un modelo cumple las condiciones del enunciado
elementoCorrecto([]).
elementoCorrecto([(E1,V1)|Resto]):- (esVocal(E1,V1);esConsonante(E1,V1)), elementoCorrecto(Resto),!.

%buscarModelo([]).
buscarModelo([Cabeza|_]):-elementoCorrecto(Cabeza), write('verdadera'),!.
buscarModelo([_|Cuerpo]):-buscarModelo(Cuerpo).
buscarModelo([]):- write('falsa'),!.