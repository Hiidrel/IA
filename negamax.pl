	/*
	Ce programme met en oeuvre l'algorithme Minmax (avec convention
	negamax) et l'illustre sur le jeu du TicTacToe (morpion 3x3)
	*/
	
:- [tictactoe].

	/****************************************************
  	ALGORITHME MINMAX avec convention NEGAMAX : negamax/5
  	*****************************************************/

	/*
	negamax(+J, +Etat, +P, +Pmax, [?Coup, ?Val])

	retourne pour un joueur J donne, devant jouer dans
	une situation donnee Etat, de profondeur donnee P,
	le meilleur couple [Coup, Valeur] apres une analyse
	pouvant aller jusqu'a la profondeur Pmax.
	*/

%******************************
	/*
	Cas 1/ la profondeur maximale est atteinte : on ne peut pas
	developper cet Etat ; 
	il n'y a donc pas de coup possible a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique. 
	*/

negamax(J, Etat, P, P, [Coup, Val]) :- 
	Coup = rien,
	heuristique(J,Etat,Val).

%******************************
	/*
	Cas 2/ la profondeur maximale n'est pas atteinte mais J ne
	peut pas jouer ; au TicTacToe un joueur ne peut pas jouer
	quand le tableau est complet (totalement instancie) ;
	il n'y a pas de coup a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique. 
	*/

negamax(J, Etat, _P, _Pmax, [Coup, Val]) :- 
	situation_terminale(J,Etat),
	Coup = rien,
	heuristique(J,Etat,Val).

%******************************
	/*
	Cas 3/ la profondeur maxi n'est pas atteinte et J peut encore
	jouer. Il faut evaluer le sous-arbre complet issu de Etat ; 

	- on determine d'abord la liste de tous les couples
	[Coup_possible, Situation_suivante] via le predicat
	 successeurs/3 (deja fourni, voir plus bas).

	- cette liste est passee a un predicat intermediaire :
	loop_negamax/5, charge d'appliquer negamax sur chaque
	Situation_suivante ; loop_negamax/5 retourne une liste de
	couples [Coup_possible, Valeur]

	- parmi cette liste, on garde le meilleur couple, c-a-d celui
	qui a la plus petite valeur (cf. predicat meilleur/2);
	soit [C1,V1] ce couple optimal. Le predicat meilleur/2
	effectue cette selection.

	- finalement le couple retourne par negamax est [Coup, V2]
	avec : V2 is -V1 (cf. convention negamax vue en cours).
	*/
	
negamax(J, Etat, P, Pmax, [Coup, (Val)]) :-
	P=<Pmax,
	successeurs(J,Etat,Succ),
	loop_negamax(J,P,Pmax,Succ,Liste_Couples),
	meilleur(Liste_Couples,[Coup,V2]),
	Val is -V2.

%*******************************************************************************
	/*******************************************
	DEVELOPPEMENT D'UNE SITUATION NON TERMINALE
	successeurs/3 
	*******************************************/

	/*
   	successeurs(+J,+Etat, ?Succ)

   	retourne la liste des couples [Coup, Etat_Suivant]
 	pour un joueur donne dans une situation donnee 
	*/

successeurs(J,Etat,Succ) :-
	copy_term(Etat, Etat_Suiv),
	findall([Coup,Etat_Suiv],
		    successeur(J,Etat_Suiv,Coup),
		    Succ).

%*******************************************************************************
	/*************************************
    Boucle permettant d'appliquer negamax 
    a chaque situation suivante :
	*************************************/

	/*
	loop_negamax(+J,+P,+Pmax,+Successeurs,?Liste_Couples)

	retourne la liste des couples [Coup, Valeur_Situation_Suivante]
	a partir de la liste des couples [Coup, Situation_Suivante]
	*/

loop_negamax(_,_,_,[],[]).
loop_negamax(J,P,Pmax,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]) :-
	loop_negamax(J,P,Pmax,Succ,Reste_Couples),
	adversaire(J,A),
	Pnew is P+1,
	negamax(A,Suiv,Pnew,Pmax,[_,Vsuiv]).

%*******************************************************************************
	/*********************************
	Selection du couple qui a la plus
	petite valeur V 
	*********************************/

	/*
	meilleur(+Liste_Couples, ?Meilleur_Couple)

	On suppose que chaque element de la liste est du type [C,V]
	- le meilleur dans une liste a un seul element est cet element
	- le meilleur dans une liste [X|L] avec L \= [], est obtenu en comparant
	  X et Y,le meilleur couple de L 
	  Entre X et Y on garde celui qui a la petite valeur de V.
	*/

meilleur([X],X).
meilleur([[CX,VX]|Liste_Couples], Meilleur_Couple):- 
	Liste_Couples\=[],
	meilleur(Liste_Couples,[CY,VY]),
	(VX<VY-> Meilleur_Couple=[CX,VX]; Meilleur_Couple=[CY,VY]).


%*******************************************************************************
	/******************
  	PROGRAMME PRINCIPAL
  	******************/

	/* 
	main(?C, ?V, +Pmax)
	
	Renvoie le meilleur coup à jouer et son heuristique pour une profondeur Pmax donnée
	*/

main(C,V, Pmax) :-
	Pmax=<9,
	joueur_initial(J),
	situation_initiale(S),
	P is 0,
	negamax(J, S, P, Pmax, [C, V]).