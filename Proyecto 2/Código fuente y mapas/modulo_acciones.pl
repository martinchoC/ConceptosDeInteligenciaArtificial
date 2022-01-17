/**********************************************************************************************
 Proyecto: Conceptos de Inteligencia Artificial - Segundo cuatrimestre 2019
    Desarrollo de Agentes Inteligentes para la busqueda de planes en una mina.
	
 Alumno:
       Castro, Martin E.

 Agente: minero
**********************************************************************************************/

/*********************************************************************************************
										MODULO DE ACCIONES DEL AGENTE
**********************************************************************************************/

:-consult('minaExample.pl'). 

suelo(firme,2).
suelo(resbaladizo,3).

/******************************************CAMINAR*******************************************/ 

/********************************************************************************************
caminar 
va a avanzar sobre un terreno en caso de ser posible en cierta direccion, realizando las acciones 
necesarias como avanzar sobre un reja.
*********************************************************************************************/
caminar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[PosDestino,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo):-
    siguienteCelda(Pos,PosDestino,caminar,Dir),
    (sinObstaculos(PosDestino); (estaEn([r,NombreReja],PosDestino),member([l,NombreLlave],ListaPosesiones),abreReja([l,NombreLlave],[r,NombreReja]))),
    celda(PosDestino,TipoSuelo),
    suelo(TipoSuelo,Costo).

/*********************GIRAR EN UNA POSICION****************************/

/**********************************************************************
rotar(EstadoInicial, DireccionFinal, EstadoFinal, Costo) indica el costo de girar 90º o 180º
al realizar la correspondiente rotación.
***********************************************************************/
rotar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente], DirDestino, [Pos, DirDestino, ListaPosesiones,ColocacionCargaPendiente], 1):- girar90o(Dir, DirDestino).
rotar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente], DirDestino, [Pos, DirDestino, ListaPosesiones,ColocacionCargaPendiente], 2):- girar180o(Dir, DirDestino).

girar180o(n,s).
girar180o(s,n).
girar180o(e,o).
girar180o(o,e).
girar90o(n,o).
girar90o(n,e).
girar90o(s,o).
girar90o(s,e).
girar90o(o,n).
girar90o(o,s).
girar90o(e,n).
girar90o(e,s).

/*******************************SALTAR OBSTACULO*******************************/

/*****************************************************************************
saltar(EstadoInicial,EstadoFinal,Nombrevalla,Altura,Costo) salta una valla
con una altura menor a 4 en una direccion indicando su costo
******************************************************************************/
saltar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[PosDestino,Dir,ListaPosesiones,ColocacionCargaPendiente],NombreValla,Altura0,Costo):- 
    siguienteCelda(Pos,PosDestino,saltar, Dir), 
    sinObstaculos(PosDestino),
    celda(PosDestino,TipoSuelo),
    suelo(TipoSuelo,CostoSuelo),
    siguienteCelda(Pos,PosObstaculo,caminar,Dir),  
    estaEn([v,NombreValla,Altura0],PosObstaculo),  
    Altura0 < 4, 
    Costo is 1 + CostoSuelo.

/*********************JUNTAR LLAVE**********************/ 

/**********************************************************************
juntar_llave
si no se posee una llave,del mismo nombre, se levanta y agrega a la lista de posesiones.
**********************************************************************/
juntar_llave([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[Pos,Dir,NuevaListaPosesiones,ColocacionCargaPendiente],NombreLlave,Costo):-
    estaEn([l,NombreLlave],Pos),
    not(member([l,NombreLlave],ListaPosesiones)),
    append(ListaPosesiones,[[l,NombreLlave]],ListaAuxiliar),
    sort(ListaAuxiliar,NuevaListaPosesiones),
    Costo is 1.

/*********************JUNTAR CARGA**********************/ 

/**********************************************************************
juntar_carga
si no se posee una carga, se levanta y agrega a la lista de posesiones.
**********************************************************************/

juntar_carga([Pos, Dir, ListaPosesiones,_],[Pos,Dir,NuevaListaPosesiones,si],NombreCarga,Costo):-
    estaEn([c,NombreCarga],Pos),
    not(member([c,NombreCarga],ListaPosesiones)),
    append(ListaPosesiones,[[c,NombreCarga]],ListaAuxiliar),
    sort(ListaAuxiliar,NuevaListaPosesiones),
    Costo is 3.

/*********************JUNTAR DETONADOR**********************/ 

/**********************************************************************
juntar_detonador
si no se posee un detonador, se levanta y agrega a la lista de posesiones.
**********************************************************************/
 juntar_detonador([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[Pos,Dir,NuevaListaPosesiones,ColocacionCargaPendiente],NombreDetonador,Activado,Costo):-
    estaEn([d,NombreDetonador,Activado],Pos),
    not(member([d,NombreDetonador,Activado],ListaPosesiones)),
    append(ListaPosesiones,[[d,NombreDetonador,Activado]],ListaAuxiliar),
    sort(ListaAuxiliar,NuevaListaPosesiones),
    Costo is 2.

/*********************DEJAR CARGA**********************/ 

/**********************************************************************
dejar_carga
si se posee una carga y esta en el lugar que se debe dejar, se 
deja la misma y se setea que la carga no está pendiente para dejarla
**********************************************************************/
dejar_carga([Pos,Dir,ListaPosesiones,si],[Pos,Dir,NuevaListaPosesiones,no],NombreCarga,Costo):-
    member([c,NombreCarga],ListaPosesiones),
    ubicacionCarga(Pos),
    delete(ListaPosesiones,[c,NombreCarga],NuevaListaPosesiones),
    Costo is 1.

/*********************DETONAR**********************/ 

/**********************************************************************
detonar
si se está en el sitio apto para detonacion, no está pendiente la acción de
dejar la carga y tengo un detonador, acciono el mismo y el mismo queda
ya accionado.
**********************************************************************/
detonar([Pos,Dir,ListaPosesiones,no],[Pos,Dir,NuevaListaPosesiones,no],NombreDetonador,Costo):-
    member([d,NombreDetonador,no],ListaPosesiones),
    sitioDetonacion(Pos),
    delete(ListaPosesiones,[d,NombreDetonador,no],ListaAux),  
    append(ListaAux,[[d,NombreDetonador,si]],NuevaListaPosesiones),
    Costo is 1.



/**********************************************************************
sinIbstaculos
predicado para chequear que en una posicion no hay rejas, vallas ni pilares.
**********************************************************************/
sinObstaculos(Posicion):-
    not(estaEn([r,_],Posicion)), 
    not(estaEn([v,_,_],Posicion)), 
    not(estaEn([p,_,_],Posicion)).

/**********************************************************************
siguienteCelda
predicado para indicar si hay que caminar o saltar una valla.
**********************************************************************/
siguienteCelda([FilaActual,ColumnaActual],[FilaFinal,ColumnaActual],caminar,n):- FilaFinal is (FilaActual-1).
siguienteCelda([FilaActual,ColumnaActual],[FilaFinal,ColumnaActual],caminar,s):- FilaFinal is (FilaActual+1).
siguienteCelda([FilaActual,ColumnaActual],[FilaActual,ColumnaFinal],caminar,e):- ColumnaFinal is (ColumnaActual+1).
siguienteCelda([FilaActual,ColumnaActual],[FilaActual,ColumnaFinal],caminar,o):- ColumnaFinal is (ColumnaActual-1).
siguienteCelda([FilaActual,ColumnaActual],[FilaFinal,ColumnaActual],saltar,n):- FilaFinal is (FilaActual-2).
siguienteCelda([FilaActual,ColumnaActual],[FilaFinal,ColumnaActual],saltar,s):- FilaFinal is (FilaActual+2).
siguienteCelda([FilaActual,ColumnaActual],[FilaActual,ColumnaFinal],saltar,e):- ColumnaFinal is (ColumnaActual+2).
siguienteCelda([FilaActual,ColumnaActual],[FilaActual,ColumnaFinal],saltar,o):- ColumnaFinal is (ColumnaActual-2).

/*************************************************************************************************
estadoSucesor
Dada la etiqueta de un estado genera el nuevo estado y su accion correspondiente 
(caminar,rotar,saltar valla, juntar llave, carga o detonador, dejar carga o detonar)
**************************************************************************************************/

estadoSucesor(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],caminar,Costo):-
	caminar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).

estadoSucesor(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],rotar(DirDestino),Costo):-
	rotar(Estado,DirDestino,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

estadoSucesor(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],saltar_valla([v,NombreValla,Altura0]),Costo):-
	saltar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],NombreValla,Altura0,Costo).

estadoSucesor(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_llave([l,NombreLlave]),Costo):-
	juntar_llave(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],NombreLlave,Costo).

estadoSucesor(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_carga([c,NombreCarga]),Costo):-
	juntar_carga(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],NombreCarga,Costo).

estadoSucesor(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_detonador([d,NombreDetonador,Activado]),Costo):-
	juntar_detonador(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],NombreDetonador,Activado,Costo).

estadoSucesor(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],dejar_carga([c,NombreCarga]),Costo):-
	dejar_carga(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],NombreCarga,Costo).

estadoSucesor(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],detonar([d,NombreDetonador,no]),Costo):-
	detonar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],NombreDetonador,Costo).