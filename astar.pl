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
    % expand pour trouver tous les successeurs et calculer les coûts associés
expand([[_Fu,_Hu,Gu],S],Lsuc):-
    G is Gu+1,
    findall((S2,A,[F,H,G]), (rule(A, 1, S, S2), heuristique2(S2,H), F is G+H), Lsuc).

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
    % loop_successors
    % cas d'arrêt ou la liste es successeurs est vide
loop_successors([], Pf, Pu, _Q, _Pere, Pf, Pu).

    % S est connu, on l'ignore et on continue
loop_successors([(S,_A,[_F,_H,_G])|Suc],Pf,Pu,Q,Pere, Pf_out, Pu_out):-
    belongs([S,_Val,_Pere,_Coup],Q),
    !, writeln("a"),
    loop_successors(Suc,Pf,Pu,Q,Pere, Pf_out, Pu_out).

    % S est connu dans Pu, on le met à jour (si le cout trouvé est inférieur au précédant)
loop_successors([(S,A,[F,H,G])|Suc],Pf,Pu,Q,Pere, Pf_out, Pu_out):-
    belongs([S,[Old_F,_H,_G],_Pere,_A],Pu),
    !, writeln("b"),
    comp_F(Old_F,Pf,Pu,S,[F,H,G],Pere,A,Pf_new,Pu_new),
    loop_successors(Suc,Pf_new,Pu_new,Q,Pere, Pf_out, Pu_out).

    % S est une situation nouvelle, on insère dans Pu et Pf
loop_successors([(S,A,[F,H,G])|Suc],Pf,Pu,Q,Pere, Pf_out, Pu_out):-
    insert([S,[F,H,G],Pere,A],Pu,Pu_new), 
    insert([[F,H,G],S],Pf,Pf_new),
    loop_successors(Suc,Pf_new,Pu_new,Q,Pere, Pf_out, Pu_out).

%*******************************************************************************
    % affiche_solution
affiche_solution(Q,Sol):-
    put_flat(Q).


%*******************************************************************************
    % aetoile

    % cas trivial, Pf et Pu sont vides
aetoile([],[],_):- print("PAS DE SOLUTION : L ETAT FINAL N EST PAS ATTEIGNABLE !").
    
    % cas trivial, solution trouvée
aetoile(Pf,_Pu,Qs):- 
	final_state(Fin), 
	suppress_min([[F,H,G],Fin], Pf, _Pf2),
    !, writeln(Pu),
    suppress([Fin,[F,H,G],Pere,A], Pu, Pu2),
    insert([Fin,G,Pere,A], Qs,Q_new),
    !, writeln("end"),
    !, put_flat(Q_new),
    !, writeln(Sol),
	affiche_solution(Q_new,Sol).

    % cas général
aetoile(Pf,Pu,Qs):- 
	suppress_min(U, Pf, Pf2), % M état de cout F minimal
    U=[[F,H,G],S],
	suppress([S,[F,H,G],Pere,A], Pu, Pu2), % on enlève aussi M dans Pu (symétrie)
    expand(U,Lsuc), % on trouve tous les successeurs
    loop_successors(Lsuc, Pf2, Pu2, Qs, U, Pf_out, Pu_out), % on traite chaque successeur
    !, put_flat(Pf_out), nl, nl,
    !, put_flat(Pu_out), nl,
    insert([U,G,Pere,A], Qs,Q_new), % on ajoute l'état traité dans Q
    !, writeln("itération finie, Q :"),
    !, put_flat(Q_new), nl,
    aetoile(Pf_out, Pu_out, Q_new). % on fait la récursion

%*******************************************************************************
    % main program
    % initialisations Pf, Pu et Q 
	% lancement de Aetoile
    % programme principal qui init la situation et appelle A*
main :-
	initial_state(Ini),
	heuristique2(Ini,H0),
	G0 is 0,
	F0 is G0 + H0,
	empty(Pf),
	empty(Pu),
	empty(Q),
	insert([[F0,H0,G0],Ini],Pf,Pfi),
	insert([Ini,[F0,H0,G0], nil, nil],Pu,Pui),
    aetoile(Pfi, Pui, Q).