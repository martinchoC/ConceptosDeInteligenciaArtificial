/**********************************************************************************************
 Proyecto: Conceptos de Inteligencia Artificial - Segundo cuatrimestre 2019
    Desarrollo de Agentes Inteligentes para la busqueda de planes en una mina.
	
 Alumno:
       Castro, Martin E.

 Agente: minero
**********************************************************************************************/

/*********************************************************************************************
										MODULO DE BUSQUEDA
**********************************************************************************************/

:- dynamic estaEn/2.
:- dynamic estadoSucesor/4.
:- dynamic frontera/1.
:- dynamic visitados/1.
:- set_prolog_flag(answer_write_options,[max_depth(0)]).
:- consult('minaExample.pl').
:- consult('modulo_acciones.pl').

/*****************************************************************************************************
buscar_plan
 Este predicado realiza la implementación del predicado solicitado en la cátedra.
*****************************************************************************************************/
buscar_plan(EstadoInicial,Plan,Destino,Costo):-
    nth0(0,EstadoInicial,PosicionInicial),
    sinObstaculos(PosicionInicial),
    celda(PosicionInicial,_),
    assert(frontera([EstadoInicial,[],0,0])), 
    buscar(Meta),
    Meta = [EstadoMeta,Camino,Costo,_],
    EstadoMeta= [Destino,_,_,_],
    reverse(Camino,Plan),
    reset(),
    !.

buscar_plan(_,'No es posible realizar un plan',_,_):- 
    reset(),
    !.


/**************************************************************************
buscar.
Este predicado es la implementacion del algoritmo de busqueda A*
Le pongo el cut ya que el costo de los siguientes planes encontrados
seran mayores (o a lo sumo igual) a al primero encontrado.
***************************************************************************/
%Caso Base 
buscar(Nodo):-
    buscarMinimo(Nodo),
    esMeta(Nodo).

%Caso Recursivo
buscar(Nodo):-
    buscarMinimo(Minimo),
    generarVecinos(Minimo,Vecinos),
    retract(frontera(Minimo)),
    insertarVecinos(Vecinos),
    buscar(Nodo).

/*****************************************************************************************************
generarVecinos
 Este predicado realiza la generacion de vecinos a partir de un nodo.
*****************************************************************************************************/
generarVecinos([Estado,Camino,Costo,_],VecinosAgregar):-
    findall([ProximoEstado,[Operacion|Camino],CostoTotal],estadoSucesor(Estado,ProximoEstado,Operacion,Costo,CostoTotal),Vecinos),
    controlCiclos(Vecinos,VecinosAgregar).

% estadoSucesor genera un estado sucesor valido para la entrada 
estadoSucesor(EstadoActual,ProximoEstado,Operacion,Costo,CostoTotal):-
    estadoSucesor(EstadoActual,ProximoEstado,Operacion,CostoAccion),
    CostoTotal is Costo + CostoAccion.


/**************************************************************************
insertarVecinos 
  Predicado que inserta los siguientes estados en la frontera
**************************************************************************/
insertarVecinos([]):-!.

insertarVecinos([Nodo|ListaVecinos]):-
    Nodo= [Estado,_,_],
    visitados(Estado),
    insertarVecinos(ListaVecinos).

insertarVecinos([Nodo|ListaVecinos]):-
    Nodo= [Estado,Camino,CostoNodo],
    not(visitados(Estado)),
    assert(visitados(Estado)),
    heuristica(Nodo,H),
    CostoTotal is CostoNodo+ H,
    Nuevo= [Estado,Camino,CostoNodo,CostoTotal],
    assert(frontera(Nuevo)),
    insertarVecinos(ListaVecinos).


/*********************************************************************************************
heuristica
Este predicado calcula el valor heuristico para una posicion a la meta.
Por lo tanto, h(n) lo defino como que la distancia Manhattan mejorada es la distancia menor
entre la posicion actual y la meta mas cercana. 
Se buscara una funcion h admisible, que no sea costosa.
***********************************************************************************************/
%caso 1 : tengo un detonador y la carga puesta. Obtengo la distancia al sitio de detonación
heuristica(Nodo,H):-
    Nodo  = [Estado,_,_],
    Estado = [Pos,_,ListaPosesiones,no],
    member([d,_,no],ListaPosesiones),
    findall(Posicion, sitioDetonacion(Posicion), [Primera|Resto]),
	distanciaAdetonacion(Pos, Primera, Resto, H).
    
%caso 2 : no tengo detonador y planté la carga, entonces devuelvo la distancia al detonador
heuristica(Nodo,H):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,no],
    not(member([d,_,no], ListaPosesiones)),
    estaEn([d,_,no],[PosXDet,PosYDet]),
    Pos = [X,Y],
    H is abs(X-PosXDet) + abs(Y-PosYDet).

%caso 3 : tengo el detonador, tengo la carga y no la planté, entonces devuelvo la distancia al lugar donde debo plantar la carga
heuristica(Nodo,H):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,si],
    member([d,_,no],ListaPosesiones),
    member([c,_],ListaPosesiones),
    ubicacionCarga([PosXUbic,PosYUbic]),
    Pos = [X,Y],
    H is abs(X-PosXUbic) + abs(Y-PosYUbic).

%caso 4 : tengo detonador pero no la carga y no la planté, entonces devuelvo la distancia a la carga
heuristica(Nodo,H):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,si],
    member([d,_,no],ListaPosesiones),
    not(member([c,_],ListaPosesiones)),
    estaEn([c,_],[PosXCarga,PosYCarga]),
    Pos = [X,Y],
    H is abs(X-PosXCarga) + abs(Y-PosYCarga).

%caso 5 : no tengo detonador, tengo la carga pero no la planté, entonces devuelvo la distancia menor a la posicion del detonador o donde debo plantar la carga
heuristica(Nodo,H):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,si],     
    not(member([d,_,_], ListaPosesiones)), 
    member([c,_],ListaPosesiones),
    ubicacionCarga([PosXUbic,PosYUbic]),
    estaEn([d,_,_],[PosXDet,PosYDet]),
    Pos = [X,Y],
    DistanciaUbicCarga is abs(X-PosXUbic) + abs(Y-PosYUbic),
    DistanciaDetonador is abs(X-PosXDet) + abs(Y-PosYDet),
    H is min(DistanciaUbicCarga,DistanciaDetonador).

%caso 6 : no tengo ni la carga ni el detonador, y no planté la carga, entonces devuelvo la distancia menor sea a la carga o al detonador 
heuristica(Nodo,H):-
    Nodo= [Estado,_,_],
    Estado= [Posicion,_,ListaPosesiones,si],     
    not(member([d,_,_], ListaPosesiones)), 
    not(member([c,_],ListaPosesiones)),
    estaEn([c,_],[PosXCarga,PosYCarga]),
    estaEn([d,_,_],[PosXDet,PosYDet]),
    Posicion = [X,Y],
    DistanciaCarga is abs(X-PosXCarga) + abs(Y-PosYCarga),
    DistanciaDetonador is abs(X-PosXDet) + abs(Y-PosYDet),
    H is min(DistanciaCarga,DistanciaDetonador).

/********************************************************************************************
distanciaAdetonacion
Este predicado calcula la menor distancia al punto de detonación.
********************************************************************************************/
distanciaAdetonacion([X1,Y1], [X2, Y2], [], MenorDistancia):-
	%distancia de manhattan
    MenorDistancia is abs(X1-X2) + abs(Y1-Y2).  

distanciaAdetonacion([PosX,PosY], [X1, Y1], [[X2, Y2]|Resto], MenorDistancia) :-
	Distancia1 is abs(PosX-X1) + abs(PosY-Y1),  
	Distancia2 is abs(PosX-X2) + abs(PosY-Y2),
    Distancia1 < Distancia2  -> 
                                distanciaAdetonacion([PosX,PosY],[X1, Y1],Resto,MenorDistancia) 
                                ;
							    distanciaAdetonacion([PosX,PosY],[X2, Y2],Resto,MenorDistancia).

/********************************************************************************************
buscarMinimo
Este predicado busca el nodo con menor Heuristica de la Frontera.
********************************************************************************************/	
buscarMinimo(NodoMenor):-
    findall(Nodo,frontera(Nodo),[PrimerNodo|Resto]),
    minimo(PrimerNodo,Resto,NodoMenor).

minimo(Nodo,[],Nodo):- !.

minimo([Estado1,Camino1,CostoNodo1,CostoTotal1],[[Estado2,Camino2,CostoNodo2,CostoTotal2]|Resto],Minimo):-
    CostoTotal1 < CostoTotal2 -> minimo([Estado1,Camino1,CostoNodo1,CostoTotal1],Resto,Minimo)
                                 ; 
                                 minimo([Estado2,Camino2,CostoNodo2,CostoTotal2],Resto,Minimo).

/********************************************************************************************
esMeta
Este predicado determina si un nodo es meta.
********************************************************************************************/
esMeta(Nodo):-
    Nodo=[Estado,_,_,_],
    Estado=[_,_,ListaPosesiones,no],
    member([d,_,si],ListaPosesiones). 

/*****************************************************************************************************
controlDeCiclos
Este predicado controla los ciclos para que solo esten disponibles los vecinos que hay que agregar a 
la frontera.
*****************************************************************************************************/
controlCiclos([],[]):-!.

%en el control de frontera, un estado es alcanzado por un camino mejor que el asociado al nodo actual
controlCiclos(Vecinos,VecinosAgregar):-
	Vecinos=[Nodo|RestoVecinos],
    Nodo= [Estado,Camino,CostoNodo,CostoTotal1],
    frontera([Estado,Camino1,CostoNodo1,CostoTotal2]),
    CostoTotal1<CostoTotal2,!,
    retract(frontera([Estado,Camino1,CostoNodo1,CostoTotal2])),
    assert(frontera([Estado,Camino,CostoNodo,CostoTotal1])),
	controlCiclos(RestoVecinos,VecinosAgregar).

%en el control de visitados, un estado es alcanzado por un camino mejor que el asociado al nodo actual
controlCiclos(Vecinos,VecinosAgregar):-
    Vecinos=[Nodo|RestoVecinos],
    Nodo= [Estado,Camino,CostoNodo,CostoTotal1],
    visitados([Estado,Camino1,CostoNodo1,CostoTotal2]),
    CostoTotal1<CostoTotal2,
    retract(visitados([Estado,Camino1,CostoNodo1,CostoTotal2])),
    assert(frontera(nodo(Estado,Camino,CostoNodo,CostoTotal1))),
    controlCiclos(RestoVecinos,VecinosAgregar).

%en el control de frontera, todo ok
controlCiclos(Vecinos,VecinosAgregar):-
    Vecinos=[Nodo|RestoVecinos],
    Nodo= [Estado,_,_,CostoTotal1],
    frontera([Estado,_,_,CostoTotal2]),
    CostoTotal1 >= CostoTotal2,!,
    controlCiclos(RestoVecinos,VecinosAgregar).
	

%en el control de visitados, todo ok
controlCiclos(Vecinos,VecinosAgregar):-
    Vecinos=[Nodo|RestoVecinos],
    Nodo= [Estado,_,_,CostoTotal1],
    visitados([Estado,_,_,CostoTotal2]),
    CostoTotal1 > CostoTotal2, !,
    controlCiclos(RestoVecinos,VecinosAgregar).

%si no existe ni en la frontera ni en visitados un nodo N1, se agrega a la frontera un nodo N2
controlCiclos([Nodo|RestoVecinos],[Nodo|VecinosAgregar]):-
	controlCiclos(RestoVecinos,VecinosAgregar).

/*****************************************************************************************************
reset
Este predicado borra toda la informacion en la frontera y los nodos visitados.
*****************************************************************************************************/
reset():-
  borrarFrontera(),
  borrarVisitados().

borrarFrontera():-
  retract(frontera(_)),
  borrarFrontera(),
  !.

borrarFrontera().

borrarVisitados():-
  retract(visitados(_)),
  borrarVisitados(),
  !.

borrarVisitados().