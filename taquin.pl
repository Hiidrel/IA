/* Fichier du probleme. 

Doit contenir au moins 4 predicats qui seront utilises par A*

etat_initial(I)                                         % definit l'etat initial

etat_final(F)                                           % definit l'etat final  

rule(Rule_Name, Rule_Cost, Before_State, After_State)   % règles applicables

heuristique(Current_State, Hval)				           % calcul de l'heuristique 


Les autres prédicats sont spécifiques au Taquin.
*/


%:- lib(listut).      % Laisser cette directive en commentaire si vous utilisez Swi-Prolog 

                    % Sinon décommentez la ligne si vous utilisez ECLiPSe Prolog :
                    % -> permet de disposer du predicat nth1(N, List, E)
                    % -> permet de disposer du predicat sumlist(List, S)
                    % (qui sont predefinis en Swi-Prolog)

                    
%***************************
%DESCRIPTION DU JEU DU TAKIN
%***************************

%********************
% ETAT INITIAL DU JEU
%********************   
% format :  initial_state(+State) ou State est une matrice (liste de listes)


initial_state([ [b, h, c],       % C EST L EXEMPLE PRIS EN COURS
            [a, f, d],       % 
            [g,vide,e] ]).   % h1=4,   h2=5,   f*=5



% AUTRES EXEMPLES POUR LES TESTS DE  A*

/*
initial_state([ [ a, b, c],        
            [ g, h, d],
            [vide,f, e] ]). % h2=2, f*=2

initial_state([ [b, c, d],
            [a,vide,g],
            [f, h, e]  ]). % h2=10 f*=10
        
initial_state([ [f, g, a],
            [h,vide,b],
            [d, c, e]  ]). % h2=16, f*=20
        
initial_state([ [e, f, g],
            [d,vide,h],
            [c, b, a]  ]). % h2=24, f*=30 

initial_state([ [a, b, c],
            [g,vide,d],
            [h, f, e]]). % etat non connexe avec l'etat final (PAS DE SOLUTION)
*/  


%******************
% ETAT FINAL DU JEU
%******************
% format :  final_state(+State) ou State est une matrice (liste de listes)

% final_state la situation finale F pour le Taquin 3x3
final_state([[a, b,  c],
            [h,vide, d],
            [g, f,  e]]).
% final_state_4 la situation finale F pour le Taquin 4x4
final_state_4([[1, 2, 3, 4],
            [5, 6, 7, 8],
            [9, 10, 11, 12],
            [13, 14, 15, vide]]).

            
%********************
% AFFICHAGE D UN ETAT
%********************
% format :  write_state(?State) ou State est une liste de lignes a afficher

write_state([]).
write_state([Line|Rest]) :-
writeln(Line),
write_state(Rest).

% question 1.2.c, vérification de la position d'un élément P dans U0 par rapport à F
is_in_place(P) :-
	initial_state(U0),
	final_state(F),
	% position de P dans Ini = [I1,I2]
	nth1(I1,U0,X),
	nth1(I2,X,P),
	% vérification de la position de P = [I1,I2]
	nth1(I1,F,Ligne),
	nth1(I2,Ligne,P).

%**********************************************
% REGLES DE DEPLACEMENT (up, down, left, right)             
%**********************************************
% format :   rule(+Rule_Name, ?Rule_Cost, +Current_State, ?Next_State)

rule(up,   1, S1, S2) :-
vertical_permutation(_X,vide,S1,S2).

rule(down, 1, S1, S2) :-
vertical_permutation(vide,_X,S1,S2).

rule(left, 1, S1, S2) :-
horizontal_permutation(_X,vide,S1,S2).

rule(right,1, S1, S2) :-
horizontal_permutation(vide,_X,S1,S2).

%***********************
% Deplacement horizontal            
%***********************
% format :   horizontal_permutation(?Piece1,?Piece2,+Current_State, ?Next_State)

horizontal_permutation(X,Y,S1,S2) :-
append(Above,[Line1|Rest], S1),
exchange(X,Y,Line1,Line2),
append(Above,[Line2|Rest], S2).

%***********************************************
% Echange de 2 objets consecutifs dans une liste             
%***********************************************

exchange(X,Y,[X,Y|List], [Y,X|List]).
exchange(X,Y,[Z|List1],  [Z|List2] ):-
exchange(X,Y,List1,List2).

%*********************
% Deplacement vertical            
%*********************

vertical_permutation(X,Y,S1,S2) :-
append(Above, [Line1,Line2|Below], S1), % decompose S1
delete(N,X,Line1,Rest1),    % enleve X en position N a Line1,   donne Rest1
delete(N,Y,Line2,Rest2),    % enleve Y en position N a Line2,   donne Rest2
delete(N,Y,Line3,Rest1),    % insere Y en position N dans Rest1 donne Line3
delete(N,X,Line4,Rest2),    % insere X en position N dans Rest2 donne Line4
append(Above, [Line3,Line4|Below], S2). % recompose S2 

%***********************************************************************
% Retrait d une occurrence X en position N dans une liste L (resultat R) 
%***********************************************************************
% use case 1 :   delete(?N,?X,+L,?R)
% use case 2 :   delete(?N,?X,?L,+R)   

delete(1,X,[X|L], L).
delete(N,X,[Y|L], [Y|R]) :-
delete(N1,X,L,R),
N is N1 + 1.



%*******************
% PARTIE A COMPLETER
%*******************

%*******************************************************************
% Coordonnees X(colonne),Y(Ligne) d une piece P dans une situation U
%*******************************************************************
% format : coordonnees(?Coord, +Matrice, ?Element)
% Définit la relation entre des coordonnees [Ligne, Colonne] et un element de la matrice
/*
Exemples

?- coordonnees(Coord, [[a,b,c],[d,e,f]],  e).        % quelles sont les coordonnees de e ?
Coord = [2,2]
yes

?- coordonnees([2,3], [[a,b,c],[d,e,f]],  P).        % qui a les coordonnees [2,3] ?
P=f
yes
*/


coordonnees([L,C], Mat, Elt) :- 
    nth1(L,Mat,X), nth1(C,X,Elt).

                                            
%*************
% HEURISTIQUES
%*************

heuristique(U,H) :-
% heuristique1a(U, H).  % au debut on utilise l heuristique 1 
heuristique2(U, H).  % ensuite utilisez plutot l heuristique 2  


%****************
%HEURISTIQUE no 1
%****************
% Nombre de pieces mal placees dans l etat courant U
% par rapport a l etat final F


% Suggestions : définir d abord le prédicat coordonnees(Piece,Etat,Lig,Col) qui associe à une pièce présente dans Etat
% ses coordonnees (Lig= numero de ligne, Col= numero de Colonne)

% Definir ensuite le predicat malplace(P,U,F) qui est vrai si les coordonnes de P dans U et dans F sont differentes.
% On peut également comparer les pieces qui se trouvent aux memes coordonnees dans U et dans H et voir si il sagit de la
% meme piece.

% malplace(+P,+U,+F)
malplace(P,U,F) :-
coordonnees([L,C],U,P), not(coordonnees([L,C],F,P)).

% Definir enfin l heuristique qui détermine toutes les pièces mal placées (voir prédicat findall) 
% et les compte (voir prédicat length)

% version par recherche de la liste des pièces mal placées (heuristique 1a)
% heuristique1a(+U,?H).
heuristique1a(U, H) :- 
    final_state(Fin), findall(X, (malplace(X, U, Fin), X\= vide), L), length(L,H).


% version récursive (heuristique 1b)
% heursitique1b(+U,?H)
heuristique1b(U,H):-
    final_state(F),
    heuristique1b(U,F,0,H).
heuristique1b([],[],Acu,Acu). % cas d'arrêt, matrices vides, l'heuristique H=Acu
heuristique1b([LU|RU],[LF|RF],Acu,H):-
    h1b_Ligne(LU,LF,H2),
    Acu2 is Acu + H2,
    heuristique1b(RU,RF,Acu2,H).
% h1b_Ligne calcule l'heuristique H pour une ligne donnée
h1b_Ligne([],[],0). % cas d'arrêt, H=0 pour une ligne vide
h1b_Ligne([E|LU],[E|LF],H) :-
    h1b_Ligne(LU,LF,H).
h1b_Ligne([EU|LU],[EF|LF],H) :-
    h1b_Ligne(LU,LF,H2),
    EF\=EU,
    EU\= vide,
    H is H2+1.
h1b_Ligne([vide|LU],[EF|LF],H) :- % gestion du cas 'vide' (on le saute)
    h1b_Ligne(LU,LF,H),
    EF\= vide.

%****************
%HEURISTIQUE no 2
%****************

% Somme des distances de Manhattan à parcourir par chaque piece
% entre sa position courante et sa positon dans l etat final

% dm(+Elt,+U,?D).
dm(Elt,U,F,D):-
    coordonnees([L,C],U,Elt),
    coordonnees([L1,C1],F,Elt),
    D is (abs(L-L1)+abs(C-C1)).

% sum(+Q,?Somme).
sum([],0):-!.
sum([T|Q],Somme) :-
    sum(Q,S),
    Somme is T + S.

% heuristique2(+U,?H).
heuristique2(U, H) :-
    final_state(F),
    findall(X,(malplace(X,U,F),X \= vide),L),
    findall(D,(member(X,L),dm(X,U,F,D)),L2),
    sum(L2,H).