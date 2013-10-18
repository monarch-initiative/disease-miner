:- use_module(bio(io)).
:- use_module(bio(metadata_nlp)).


u(S,T) :-
        class(T),
        id_idspace(T,S).

m(T1,T2) :-
        consult('util/ignore_word_disease_pw.pro'),
        ix,
        entity_pair_label_reciprocal_best_intermatch(T1,T2,_),
        id_idspace(T2,'PW'),
        T2\='PW:0000001'.


ix :-
        index_entity_pair_label_match.

