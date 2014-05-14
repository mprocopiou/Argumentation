main :- sxdd(p,X).
?- set_prolog_flag(redefine_warnings, off).
?- compile(proxdd).
?- loadf(toni6_2).	
?- main.
?- halt.