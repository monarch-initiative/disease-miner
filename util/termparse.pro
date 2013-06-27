
tp(D,N1,C1,N2,C2) :-
        class(D,N),
        id_idspace(D,'DOID'),
        concat_atom(Toks,' ',N),
        append(L1,L2,Toks),
        concat_atom(L1,' ',N1),
        concat_atom(L2,' ',N2),
        p(N1,N2,C1,C2).

p(N1,N2,C1,C2) :-
        resolve(N1,C1),
        !,
        (   resolve(N2,C2)
        ->  true
        ;   C2='NO_MATCH').
p(_N1,N2,C1,C2) :-
        resolve(N2,C2),
        C1='NO_MATCH'.

resolve(N,C) :-
        entity_label(C,N),
        !.
resolve(N,C) :-
       entity_synonym_scope(C,N,exact),
       !.
resolve(N,C) :-
       entity_synonym(C,N),
       !.
