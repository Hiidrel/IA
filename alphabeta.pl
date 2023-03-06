:- [negamax].

negamaxAB(J,Etat,P,P,Alpha,Beta,[Coup,Val]) :- 
	Coup = rien,
	heuristique(J,Etat,Val).

negamaxAB(J,Etat,_P,_Pmax,_Alpha,_Beta,[Coup,Val]) :- 
	situation_terminale(J,Etat),
	Coup = rien,
	heuristique(J,Etat,Val).

% pour negamaxAB (on reprend negamax), on rajoute les deux paramètres et on modifie l'appel de loop_negamax
negamaxAB(J,Etat,P,Pmax,Alpha,Beta,[Coup,(Val)]) :-
	P=<Pmax,
    writeln("ITERATION negamaxAB"), nl,
	successeurs(J,Etat,Succ),
    writeln(Succ),
	loop_negamax_AB(J,P,Pmax,Alpha,Beta,Succ,Liste_Couples),
    writeln("Tout est ok après 1st loop"), nl,
	meilleur(Liste_Couples,[Coup,V2]),
	Val is -V2.

% pour loop_negamax, l'idée serait de prendre en compte dans la recherche 
loop_negamax_AB(_,_,_,_,_,[],[]).
loop_negamax_AB(J,P,Pmax,Alpha,Beta,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]) :-
	writeln("NVLLE ITERATION LOOP"), nl, writeln("Succ"+Succ), nl, writeln("Liste_Couples:"+Reste_Couples), nl,
    loop_negamax_AB(J,P,Pmax,Alpha,Beta,Succ,Reste_Couples),
    writeln("loop fini"),nl,
	adversaire(J,A),
    Pnew is P + 1,
    writeln("Vsuiv:"+Vsuiv),
    writeln(A+Suiv+Pnew+Pmax+Alpha+Beta+Vsuiv), nl,
    negamaxAB(A,Suiv,Pnew,Pmax,-Beta,-Alpha,[_,Vsuiv]),
    writeln("negamaxAB du loop fini"), nl,
    test_valeurs(Alpha,Beta,Vsuiv,Coup,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]),
    skip(J,Suiv,P,Alpha,Beta,Reste_Succ,V,Acc2,Resultat).

% test_valeurs pour mettre à jour au besoin la valeur de alpha ou de beta
	% cas 1/
test_valeurs(Alpha,_Beta,Vsuiv,Coup,[[_C,V]|Succ],[[Coup,Vsuiv]|_Reste_Couples]) :-
    Vsuiv > V,
    Vsuiv < Alpha.
	% cas 2/ 
test_valeurs(_Alpha,_Beta,Vsuiv,Coup,[[_C,V]|Succ],[[Coup,V]|_Reste_Couples]) :-
    Vsuiv =< V.
	% cas 3/ on n'est pas dans les bornes, on skip
test_valeurs(Alpha,Beta,Vsuiv,Coup,[],[[Coup,Vsuiv]]) :-
    Vsuiv >= Alpha,
    Vsuiv =< Beta.

% skip pour ne pas étudier les branches inutiles
skip(_,_,_,Alpha,Beta,_,Liste_Couples,Liste_Couples) :-
    Beta < Alpha.
skip(J,Suiv,P,Alpha,Beta,Reste_Succ,V,Succ,Resultat) :-
    upddatenegamaxAB(Alpha,Beta,V,Suiv,Succ,CouplesApres),
    Beta2 is min(Beta,V),
    loop_negamax_AB(J,P,Alpha,Beta2,Reste_Succ,CouplesApres,Resultat).

% updatenegamaxAB pour changer les valeurs de alpha et de beta si nécessaire // pas dvpée, nous n'avons pas su déterminer comment ne renvoyer que les bons couples
upddatenegamaxAB(Alpha,Beta,V,Suiv,CouplesAvant,CouplesApres) :-
    true.

% main similaire au main de negamax, avec seulement alpha et beta en paramètres supplémentaires
mainAB(C,V,Pmax):-
    Pmax=<9,
    joueur_initial(J),
    situation_initiale(S),
	P is 0,
	negamaxAB(J, S, P, Pmax, 0, 10000, [C, V]).