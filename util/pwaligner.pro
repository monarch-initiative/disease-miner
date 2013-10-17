:- use_module(bio(io)).
:- use_module(bio(metadata_nlp)).


u(S,T) :-
        class(T),
        id_idspace(T,S).


m(T1,T2) :-
        ix,
        consult('util/ignore_word_disease_pw.pro'),
        entity_pair_label_reciprocal_best_intermatch(T1,T2,false),
        id_idspace(T2,'PW').

ix :-
        index_entity_pair_label_match.

