%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************
    % expand pour trouver tous les successeurs et calculer les coûts associés.
    % expand([_,_,+G],?Lsuc).
expand([[_Fu,_Hu,Gu],S],Lsuc):-
    G is Gu+1,
    findall((S2,A,[F,H,G]), (rule(A, 1, S, S2), heuristique2(S2,H), F is G+H), Lsuc),
    writeln(Lsuc), nl.

%*******************************************************************************
    % comp_F pour mettre à jour (ou non) Pu et Pf si l'état successeur y est déjà (cf. loop_successors)
comp_F(Old_F,Pf,Pu,S,[F,H,G],Pere,A,Pf_new,Pu_new):- % cas F < Old_F, on met à jour dans Pu et Pf
    F < Old_F,
    suppress([S,[_F,_H,_G],_Pere,_A],Pu,Pui), 
    suppress([[_,_,_],S],Pf, Pfi),
    insert((S,[F,H,G],Pere,A),Pui,Pu_new), 
    insert([[F,H,G],S],Pfi,Pf_new).

comp_F(Old_F,Pf,Pu,_S,[F,_H,_G],_Pere,_A,Pf,Pu):- % cas F >= Old_F, on ne fait rien
    F >= Old_F.

%*******************************************************************************
    % loop_successors(+Suc,+Pf,+Pu,+Q,+Pere,?Pf_out,?Pu_out).
    % cas d'arrêt ou la liste des successeurs est vide
loop_successors([], Pf, Pu, _Q, _Pere, Pf, Pu).

    % S est connu, on l'ignore et on continue
loop_successors([(S,_A,[_F,_H,_G])|Suc],Pf,Pu,Q,Pere, Pf_out, Pu_out):-
    belongs([S,_Val,_Pere,_Coup],Q),
    loop_successors(Suc,Pf,Pu,Q,Pere, Pf_out, Pu_out).

    % S est connu dans Pu, on le met à jour (si le cout trouvé est inférieur au précédent)
loop_successors([(S,A,[F,H,G])|Suc],Pf,Pu,Q,Pere, Pf_out, Pu_out):-
    belongs([S,[Old_F,_H,_G],_Pere,_A],Pu),
    comp_F(Old_F,Pf,Pu,S,[F,H,G],Pere,A,Pf_new,Pu_new),
    loop_successors(Suc,Pf_new,Pu_new,Q,Pere, Pf_out, Pu_out).

    % S est une situation nouvelle, on insère dans Pu et Pf
loop_successors([(S,A,[F,H,G])|Suc],Pf,Pu,Q,Pere, Pf_out, Pu_out):-
    insert([S,[F,H,G],Pere,A],Pu,Pu_new), 
    insert([[F,H,G],S],Pf,Pf_new),
    loop_successors(Suc,Pf_new,Pu_new,Q,Pere, Pf_out, Pu_out).

%*******************************************************************************
    % affiche_solution(+Sol,+Q,+Coups).

affiche_solution(Sol) :-
    put_flat(Sol),nl.

%*******************************************************************************
    % aetoile(+Pf,+Pu,+Q).
    % cas trivial, Pf et Pu sont vides
aetoile([],[],_):- print("PAS DE SOLUTION : L ETAT FINAL N EST PAS ATTEIGNABLE !").
    
    % cas trivial, solution trouvée <=> min de Pf = situation terminale
aetoile(Pf,Pu,Q):- 
	final_state(Fin), 
	suppress_min([[F,H,G],Fin], Pf, _Pf2),
    suppress([Fin,[F,H,G],Pere,A], Pu, _Pu2), 
    insert([[[F,H,G],Fin],G,Pere,A], Q,Q_new),
    put_flat(Q_new),nl,
	affiche_solution(Q_new).

    % cas général
aetoile(Pf,Pu,Qs):- 
	suppress_min(U, Pf, Pf2), % M état de coût F minimal
    writeln(U),nl,
    U=[[F,H,G],S],
	suppress([S,[F,H,G],Pere,A], Pu, Pu2), % on enlève aussi M dans Pu (synchronisation)
    expand(U,Lsuc), % on trouve tous les successeurs
    loop_successors(Lsuc, Pf2, Pu2, Qs, U, Pf_out, Pu_out), % on traite chaque successeur
    insert([U,G,Pere,A], Qs,Q_new), % on ajoute l'état traité dans Q
    aetoile(Pf_out, Pu_out, Q_new). % on fait la récursion

%*******************************************************************************
    % main program
    % initialisations Pf, Pu et Q 
	% lancement de A*
main :-
	final_state(Ini),
	heuristique2(Ini,H0),
	G0 is 0, % on n'a rien fait pour l'instant
	F0 is G0 + H0,
	empty(Pf),
	empty(Pu),
	empty(Q),
	insert([[F0,H0,G0],Ini],Pf,Pfi),
	insert([Ini,[F0,H0,G0], nil, nil],Pu,Pui),
    statistics(walltime, [_TimeSinceStart | [_TimeSinceLastCall]]),
    aetoile(Pfi, Pui, Q),
    statistics(walltime, [_NewTimeSinceStart | [ExecutionTime]]),
    write('Execution took '), write(ExecutionTime), write(' ms.'), nl.