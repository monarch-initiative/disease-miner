
mdorel(D,DN,R,U,UN,Def) :-
        dorel(D,DN,R,X,XN,Def),
        mapid(X,XN,U,UN).

% step1 - map FMA
mapid(X,XN,U,UN) :-
        id_idspace(X,fma),
        class(ID,XN),
        id_idspace(ID,'FMA'),
        !,
        mapid2(ID,XN,U,UN).
mapid(X,XN,U,UN) :-
        mapid2(X,XN,U,UN).

mapid2(X,_XN,U,UN) :-
        id_idspace(X,S),
        \+ banned(S),
        entity_xref(U,X),
        class(U,UN),
        !.
mapid2(X,XN,X,XN) :- !.

banned('EHDA').
banned('EMAP').
banned('EMAPA').
banned('AAO').
banned('FBbt').
banned('TADS').
banned('TAO').
banned('ZFA').
