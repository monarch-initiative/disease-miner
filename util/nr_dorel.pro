nrdorel(D,DN,R,X,XN,Def) :-
        mdorel(D,DN,R,X,XN,Def),
        \+ ((mdorel(D2,_,R,X2,_,_),
             X2\=X,
             D2\=X,
             subclassRT(D,D2),
             subclassRT(X2,X),
             debug(nr,'Redundant: ~w < ~w AND ~w < ~w',[D,D2,X2,X])
             )).
