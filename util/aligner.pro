:- use_module(bio(io)).
:- use_module(bio(metadata_nlp)).


/*
unique_pair(S1,S2,T1,T2) :-
        setof(T1-T2,pair(S1,S2,T1,T2),Pairs),
        member(T1-T2,Pairs).

pair(S1,S2,T1,T2) :-
        class(T1),
        id_idspace(T1,S1),
        class(T2),
        id_idspace(T2,S2).
*/

u(S,T) :-
        class(T),
        id_idspace(T,S).


m(S1,S2,T1,T2) :-
        u(S1,T1),
        entity_pair_label_reciprocal_best_intermatch(T1,T2,false),
        id_idspace(T2,S2).

ix :-
        index_entity_pair_label_match.

efo(T1,T2) :-
        ix,
        (   S='EFO'
        ;   S='ORPHANET'),
        m(S,'DOID',T1,T2).

orphanet(T1,T2) :-
        ix,
        m('ORPHANET','DOID',T1,T2).
