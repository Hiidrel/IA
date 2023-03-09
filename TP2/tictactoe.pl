	/*********************************
	DESCRIPTION DU JEU DU TIC-TAC-TOE
	*********************************/

	/*
	Une situation est decrite par une matrice 3x3.
	Chaque case est soit un emplacement libre (Variable LIBRE), soit contient le symbole d'un des 2 joueurs (o ou x)

	Contrairement a la convention du tp precedent, pour modeliser une case libre
	dans une matrice on n'utilise pas une constante speciale (ex : nil, 'vide', 'libre','inoccupee' ...);
	On utilise plut�t un identificateur de variable, qui n'est pas unifiee (ex : X, A, ... ou _) .
	La situation initiale est une "matrice" 3x3 (liste de 3 listes de 3 termes chacune)
	o� chaque terme est une variable libre.	
	Chaque coup d'un des 2 joureurs consiste a donner une valeur (symbole x ou o) a une case libre de la grille
	et non a deplacer des symboles deja presents sur la grille.		
	
	Pour placer un symbole dans une grille S1, il suffit d'unifier une des variables encore libres de la matrice S1,
	soit en ecrivant directement Case=o ou Case=x, ou bien en accedant a cette case avec les predicats member, nth1, ...
	La grille S1 a change d'etat, mais on n'a pas besoin de 2 arguments representant la grille avant et apres le coup,
	un seul suffit.
	Ainsi si on joue un coup en S, S perd une variable libre, mais peut continuer a s'appeler S (on n'a pas besoin de la designer
	par un nouvel identificateur).
	*/

%*******************************************************************************
	% Situation initiale, la matrice est vide
situation_initiale([ [_,_,_],
                     [_,_,_],
                     [_,_,_] ]).

	% Une situation gagnante pour o
situation([ [o,_,a],
								[o,b,_],
								[o,_,_] ]).

	% Convention (arbitraire) : c'est x qui commence
joueur_initial(x).

	% Definition de la relation adversaire/2
adversaire(x,o).
adversaire(o,x).

	% Situation terminale, i.e sans case libre
situation_terminale(_Joueur, Situation) :-
    ground(Situation).

%*******************************************************************************
	/********************************************************
	DEFINITIONS D'UN ALIGNEMENT (dans une matrice carrée NxN)
	********************************************************/

alignement(L, Matrix) :- ligne(L,Matrix).
alignement(C, Matrix) :- colonne(C,Matrix).
alignement(D, Matrix) :- diagonale(D,Matrix).
	
	% Alignement de lignes
ligne(L, M) :-
	nth1(_E,M,L).

	% Alignement de colonnes
transpose([[]|_], []).
transpose(Matrix, [Row|Rows]) :- transpose_1st_col(Matrix, Row, RestMatrix),
                                 transpose(RestMatrix, Rows).
transpose_1st_col([], [], []).
transpose_1st_col([[H|T]|Rows], [H|Hs], [T|Ts]) :- transpose_1st_col(Rows, Hs, Ts).

colonne(C,M) :-
	transpose(M,Mt),
	ligne(C,Mt).

	% Alignement de diagonales
diagonale(D, M) :- 
	premiere_diag(1,D,M).

diagonale(D, M) :- 
    seconde_diag(M,D).

premiere_diag(_,[],[]).
premiere_diag(K,[E|D],[Ligne|M]) :-
	nth1(K,Ligne,E),
	K1 is K+1,
	premiere_diag(K1,D,M).

seconde_diag(M, D) :-
	length(M,K),
	seconde_diag(K, M, D).

seconde_diag(_,[],[]).
seconde_diag(K,[Ligne|M],[E|D]) :-
	nth1(K,Ligne,E),
	K1 is K-1,
	seconde_diag(K1,M,D).

%*******************************************************************************
	/*****************************
	DEFINITION D'UN ALIGNEMENT 
	POSSIBLE POUR UN JOUEUR DONNE
	*****************************/

	/*
	possible(+Ali,+J)

	Renvoie true si l'alignement Ali est possible pour J (cases libres ou du type de J)
	*/

possible([X|L],J) :- unifiable(X,J), possible(L,J).
possible([],_).

	% Vérification du caractère unifiable des emplacements de la liste
unifiable(X,_) :- var(X).
unifiable(X,J) :- ground(X), X=J.

%*******************************************************************************
	/**********************************
	DEFINITION D'UN ALIGNEMENT GAGNANT
	OU PERDANT POUR UN JOUEUR DONNE J
	**********************************/

	/*
	alignement_gagnant(+Ali, +J)
	alignement_perdant(+Ali, +J)
	*/

	% Un alignement gagnant pour J est un alignement possible pour J qui n'a aucun element encore libre.
alignement_gagnant(Ali, J) :- ground(Ali), possible(Ali,J).

	% Un alignement perdant pour J est un alignement gagnant pour son adversaire. 
alignement_perdant(Ali, J) :- adversaire(J,J2), alignement_gagnant(Ali,J2).

%*******************************************************************************
	/******************************
	DEFINITION D'UN ETAT SUCCESSEUR
	******************************/

	/*
	successeur(+J,+Etat,+[L,C])

	Écrit dans Etat la valeur associée à J à l'élément C de la ligne L
	*/

	% Définition de l'état suivant un coup de J en [L,C]
successeur(J, Etat,[L,C]) :- nth1(L,Etat,Lig), nth1(C,Lig,J).

%*******************************************************************************
	/**************************************
   	EVALUATION HEURISTIQUE D'UNE SITUATION
  	***************************************/
	
	/*
	heuristique(+J, +Situation, ?H)

	Renvoie l'heuristique pour J pour la Situation
	*/

	/* 1 - l'heuristique est +infini si la situation J est gagnante pour J */

heuristique(J,Situation,H) :-		% cas 1
   H = 10000,				% grand nombre approximant +infini
   alignement(Alig,Situation),
   alignement_gagnant(Alig,J), !.
	
	/* 2 - l'heuristique est -infini si la situation J est perdante pour J */

heuristique(J,Situation,H) :-		% cas 2
   H = -10000,				% grand nombre approximant -infini
   alignement(Alig,Situation),
   alignement_perdant(Alig,J), !.	


	/* 3 - sinon, on fait la difference entre :
	   le nombre d'alignements possibles pour J
	   -
 	   le nombre d'alignements possibles pour l'adversaire de J
	On ne vient ici que si les cut precedents n'ont pas fonctionne, c-a-d si la Situation n'est ni perdante ni gagnante. */

heuristique(J,Situation,H) :-
    % coups possibles pour J
    findall(Alig_g,(alignement(Alig_g,Situation),possible(Alig_g,J)),Lg),
    length(Lg,Cg),
    % coups possibles pour l'adversaire
    adversaire(J,J2),
    findall(Alig_p,(alignement(Alig_p,Situation),possible(Alig_p,J2)),Lp),
    length(Lp,Cp),
    % H = nb de coups possibles pour J - nb de coups possibles pour J2
    H is Cg-Cp.