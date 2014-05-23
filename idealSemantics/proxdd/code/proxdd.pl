
% file:         proxdd.pl
% author:       Robert Craven, robert.craven@imperial.ac.uk
% date:         11/06/13
% language:     SICStus Prolog 4.2+, Yap Prolog 6.2+
% purpose:      implementation of SXDD algorithm of Francesca Toni
% version:      1.2

% NOTES:
% - The algorithm implemented here is defined in:
%   "A generalised framework for dispute derivations in assumption-based argumentation"
%   Francesca Toni
%   http://dx.doi.org/10.1016/j.artint.2012.09.010
% - There are many efficiencies that could have been introduced but
%   were not, to keep as close as possible to original algorithm.

:- use_module(library(lists)).
:- use_module(library(ordsets)).

% initialize for different prologs

:-
 (current_prolog_flag(dialect, BaseDialect) ; current_prolog_flag(language, BaseDialect)),
 (
  (BaseDialect = sicstus, prolog_flag(version_data, sicstus(4,_,_,_,_)))
  -> Dialect = sicstus4
  ;  Dialect = BaseDialect
 ),  
 atom_concat('proxdd.', Dialect, DialectFile),
 (
  ensure_loaded(DialectFile)
  -> assert(option(prolog_version, Dialect))
  ;  format('Unknown Prolog dialect: ~w. This may not work.~n', [Dialect]),
     assert(option(prolog_version, unknown))
 ).

% load

:- [filtering,help,printing,selection].

:-
 discontiguous
  internal_predicate/2.

:-
 dynamic
  % generic
  filestem/1,
  option/2,
  user_defined_predicate/2,
  % specific: input
  assumption/1,
  contrary/2,
  non_assumption/1,
  rule/3,
  rule_counter/1,
  toBeProved/1,
  % specific: other
  sols/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TOP-LEVEL

sxdd(S, Result, Output) :-
 (
  assumption(S)
  -> D0 = [S]
  ;  D0 = []
 ),
 (
  verbose
  -> show_step(0, [[[1,[],[S],S]-0],[],D0,[],[],[]])
  ;  true
 ),
 retractall(sols(_)),
 assert(sols(1)),
 derivation([[[1,[],[S],S]-0],[],D0,[],[],[],[]], 1, 2, Result),
 show_print_result(Result, Output),
 incr_sols.

sxdd_all(S) :-
 sxdd(S, _),
 fail.
sxdd_all(_).

%% TOP-LEVEL HELPERS

incr_sols :-
 sols(N),
 retractall(sols(N)),
 N1 is N + 1,
 assert(sols(N1)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DERIVATION CONTROL: basic control structure

% tuples have form:
%  [Prop,Opp,Defence,Culprits,Att,Arg,F]
% arguments have the form:
%  [L,S_m,S_u,C]
%  L is the label number
%  C is the claim
% members of Prop have the form:
%  [L,S_m,S_u,C]-L'
%  (members of Opp are sets of terms of this form)
% the empty argument is []

% derivation(T, N, L, R)
%  T - current tuple
%  N - derivation step number
%  L - next new argument label number
%  R - result

derivation([[],[],D,C,At,Ar,[]], _, _,[D,C,At,Ar,[]]) :-
 !.
derivation(T, N, L, Result) :-
 derivation_step(T, L, T1, L1),
 poss_show_step(N, T1),
 N1 is N + 1,
 derivation(T1, N1, L1, Result).

derivation_step([P,O,D,C,At,Ar,F], L, T1, L1) :-
 choose_turn(P, O, F, Turn),
 (
  Turn = proponent
  -> proponent_step([P,O,D,C,At,Ar,F], L, T1, L1)
  ; 
	(
	 Turn = opponent
	 -> opponent_step([P,O,D,C,At,Ar,F], L, T1, L1)
	 ; fail_step([P,O,D,C,At,Ar,F], L, T1, L1)
	 )
 ).

proponent_step([P|RestT], L, T1, L1) :-
 proponent_arg_choice(P, Arg, PMinus),
 proponent_sentence_choice(Arg, S, ArgMinus),
 (
  assumption(S)
  -> proponent_i(S, ArgMinus, PMinus, RestT, L, T1, L1)
  ;  proponent_ii(S, ArgMinus, PMinus, RestT, L, T1, L1)
 ).

opponent_step([P,O|RestT], L, T1, L1) :-
 opponent_arg_choice(O, Arg, OMinus),
 opponent_sentence_choice(Arg, S, ArgMinus),
 (
  assumption(S)
  -> opponent_i(S, ArgMinus, OMinus, [P|RestT], L, T1, L1)
  ;  opponent_ii(S, ArgMinus, OMinus, [P|RestT], L, T1, L1)
 ).

fail_step([P,O,D,C,At,Ar,F], L, [P,O,D,C,At,Ar,F1], L) :-
 (
   ib_derivation
   -> fail_step_inner(F) 
   ; F1 = []
  ).
  
fail_step_inner([]) :-
 !.
fail_step_inner([HeadF|RestF]) :-
 get_ord_assumptions(HeadF, HeadFAs),
 fail_derivation([[HeadF,[],HeadFAs,[]]]),
 fail_step_inner(RestF).
 
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DERIVATION CASES

% the labelling of cases and logic here match those in:
% "A generalised framework for dispute derivations in assumption-based argumentation"
%  Francesca Toni
%  http://dx.doi.org/10.1016/j.artint.2012.09.010

%% PROPONENT

proponent_i(A, [La,Sm,Su,Cl]-LL, PMinus, [O,D,C,Args,Atts,F], L, [P1,O1,D,C,Args1,Atts1,F], L1) :-
 ord_add_element(Sm, A, NewSm),
 (
  Su = []
  -> NewP = [],
     NewArgs = [[La,NewSm,Su,Cl]],
     NewAtts = [La-LL]
  ;  NewP = [[La,NewSm,Su,Cl]-LL],
     NewArgs = [],
     NewAtts = []
 ),
 ord_union(PMinus, NewP, P1),
 contrary(A, ContA),
 append(O, [[L,[],[ContA],ContA]-La], O1),
 ord_union(Args, NewArgs, Args1),
 ord_union(Atts, NewAtts, Atts1),
 L1 is L + 1,
 poss_show_case('1.(i)').

proponent_ii(S, [La,Sm,Su,Cl]-LL, PMinus, [O,D,C,Args,Atts,F], L, [P1,O,D1,C,Args1,Atts1,F], L) :-
 proponent_rule_choice(S, Body),
 fDbyC(Body, C),
 fDbyD(Body, D, FDbyD),
 (
  (Su = [], FDbyD = [])
  -> NewP = [],
     ord_union(Sm, Body, NewSm),
     NewArgs = [[La,NewSm,[],Cl]],
     NewAtts = [La-LL]
  ;  subtract(Body, FDbyD, Sub),
     ord_union(Sm, Sub, NewSm),
     append_elements_nodup(Su, FDbyD, NewSu),
     NewP = [[La,NewSm,NewSu,Cl]-LL],
     NewArgs = [],
     NewAtts = []
 ),
 ord_union(PMinus, NewP, P1),
 get_ord_assumptions(Body, BodyAs),
 ord_union(D, BodyAs, D1),
 ord_union(Args, NewArgs, Args1),
 ord_union(Atts, NewAtts, Atts1),
 poss_show_case('1.(ii)').

%% OPPONENT

opponent_i(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1) :-
 (
  fCbyD(A, D),          % "don't ignore" option
  (
   fCbyC([A], C)
   -> opponent_ib(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1)
   ;  opponent_ic(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1)
  )
  ;
  opponent_ia(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1) % "ignore" option
 ).

opponent_ia(A, [La,Sm,Su,Cl]-LL, OMinus, [P,D,C,Args,Atts,F], L, [P,O1,D,C,Args,Atts,F], L) :-
 ord_add_element(Sm, A, NewSm),
 ord_add_element(OMinus, [La,NewSm,Su,Cl]-LL, O1),
 poss_show_case('2.(ia)').

opponent_ib(A, [La,Sm,Su,Cl]-LL, OMinus, [P,D,C,Args,Atts,F], L, [P,OMinus,D,C,Args1,Atts1,F1], L) :-
 ord_add_element(Sm, A, NewSm),
 ord_add_element(Args, [La,NewSm,Su,Cl], Args1),
 ord_add_element(Atts, La-LL, Atts1),
 ord_union(Sm,Su,Update),
 ord_union([Update],F,F1),
 poss_show_case('2.(ib)').

opponent_ic(A, [La,Sm,Su,Cl]-LL, OMinus, [P,D,C,Args,Atts,F], L, [P1,OMinus,D1,C1,Args1,Atts1,F1], L1) :-
 ord_add_element(Sm, A, NewSm),
 contrary(A, ContA),
 append(P, [[L,[],[ContA],ContA]-La], P1),
 get_ord_assumptions([ContA], NewD),
 ord_union(D, NewD, D1),
 ord_add_element(C, A, C1),
 ord_add_element(Args, [La,NewSm,Su,Cl], Args1),
 ord_add_element(Atts, La-LL, Atts1),
 ord_union(NewSm,Su,Update),
 ord_union([Update],F,F1),
 L1 is L + 1,
 poss_show_case('2.(ic)').


opponent_ii(S, [_,Sm,Su,Cl]-LL, OMinus, [P,D,C,Args,Atts,F], L, [P,O1,D,C,Args1,Atts1,F1], L1) :-
 findall(Body, rule(S, _, Body), Bodies),
 split_fCbyC(Bodies, C, Sf, Snf),
 make_label_snf_args(Snf, L, Sm, Su, Cl, LL, InterL, NewO),
 append(OMinus, NewO, O1),
 make_label_sf_args(Sf, C, InterL, Sm, Su, Cl, LL, L1, NewArgs, NewAtts),
 make_f_updates(Sf,Sm,Su,FUpdates),
 ord_union(FUpdates,F,F1),
 append(Args, NewArgs, Args1),
 append(Atts, NewAtts, Atts1),
 poss_show_case('2.(ii)').

 %% FAIL DERIVATION

 fail_derivation([]) :-
 !.
 fail_derivation([Qtuple|Rest]) :-
	Qtuple \= [[],[]|_],
 	fail_derivation_step(Qtuple,NewQtuples),
	append(NewQtuples,Rest,D1),
	fail_derivation(D1).

 fail_derivation_step([P,O|Rest], NewQtuples) :-
	fail_choose_turn(P, O, Turn),
	(
	 Turn = proponent
	 -> fail_proponent_step([P,O|Rest], NewQtuples)
	 ;  fail_opponent_step([P,O|Rest], NewQtuples)
	).

 fail_proponent_step([[S|PMinus]|RestT], T1) :-
  (
   assumption(S)
   -> fail_proponent_i(S, PMinus, RestT, T1)
   ;  fail_proponent_ii(S, PMinus, RestT, T1)
  ).
  
 fail_proponent_i(A, PMinus, [O,D,C],[[PMinus,O1,D,C]]) :-
  contrary(A, ContA),
  ord_union(O, [[ContA]], O1).
 
 fail_proponent_ii(S, PMinus, [O,D,C], T1) :-
  findall(CheckBody, rule(S, _, CheckBody), CheckBodies),
   (
    CheckBodies = []	
	->  T1 = []
	; proponent_rule_choice(S, Body),
	  fDbyC(Body, C),
	  fDbyD(Body, D, FDbyD),
	  ord_union(PMinus, FDbyD, P1),
	  get_ord_assumptions(Body, BodyAs),
	  ord_union(D, BodyAs, D1),
	  T1 = [[P1,O,D1,C]]
   ). 	  
	  
 fail_opponent_step([P,[[]|RestO]|RestT],[]):-
 !.
 
 fail_opponent_step([P,[[S|RestS]|OMinus]|RestT], T1) :-
  (
   assumption(S)
   -> fail_opponent_i(S, RestS, OMinus, [P|RestT], T1)
   ;  fail_opponent_ii(S, RestS, OMinus, [P|RestT], T1)
  ).
 
 fail_opponent_i(A, RestS, OMinus, [P,D,C|RestT], T) :-
  fail_opponent_ia(RestS, OMinus, [P,D,C|RestT], T1), % "ignore" option
 (
  fCbyD(A, D)          % "don't ignore" option
  ->
  (
   fCbyC([A], C)
   -> fail_opponent_ib(OMinus, [P,D,C|RestT], T3)
   ;  fail_opponent_ic(A, OMinus, [P,D,C|RestT], T3)
  ),
  T2 = [T3]
  ; T2 = []
 ),
 append(T2,[T1],T).
 
 fail_opponent_ia(RestS, OMinus, [P,D,C], [P,O1,D,C]) :-
  ord_union(OMinus,[RestS],O1).
 
 fail_opponent_ib(OMinus, [P,D,C], [P,OMinus,D,C]). 
 
 fail_opponent_ic(A, OMinus, [P,D,C], [P1,OMinus,D1,C1]) :-
  contrary(A, ContA),
  (
    assumption(ContA)
	-> ord_union(D,[ContA],D1),
	   P1 = P
	;  D = D1,
	   ord_union(P,[ContA],P1)
   ),  
  ord_add_element(C, A, C1).    
 
 fail_opponent_ii(S, RestS, OMinus, [P,D,C], [[P,O1,D,C]]) :-
  findall(Body, (rule(S, _, Body),fDbyC(Body,C)), Bodies),
  make_rs(RestS,Bodies,Rs),
  ord_union(OMinus,Rs,O1).
 
 make_rs(_,[],[]) :-
 !.
 
 make_rs(RestS,[Body|Bodies],[NewBody|NewBodies]) :-
  append_elements_nodup(RestS,Body,NewBody),
  make_rs(RestS,Bodies,NewBodies).
  
 
% opponent_selection([P,[[]|RestO], []) :-
% 	!.
% opponent_selection([P,[[Sigma|Sentences]|RestO], NewQtuple) :-	
%  

%	opponent_selection([P,O|RestT], L, T1, L1) :-
%	 opponent_arg_choice(O, Arg, OMinus),
%	 opponent_sentence_choice(Arg, S, ArgMinus),
%	(
%	assumption(S)
%	-> fail_opponent_i(S, ArgMinus, OMinus, [P|RestT], L, T1, L1),	    
%	;  opponent_ii(S, ArgMinus, OMinus, [P|RestT], L, T1, L1)
%	).

% fail_opponent_i(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1) :-
% (
%  fCbyD(A, D),          % "don't ignore" option
%  (
%   fCbyC([A], C)
%   -> opponent_ib(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1)
%   ;  opponent_ic(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1)
%  ),
%	opponent_ia(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1)
%  ;
%  opponent_ia(A, ArgMinus, OMinus, [P,D,C|RestT], L, T1, L1) % "ignore" option
% ).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HELPERS

% append_element_nodup(L, E, Res)
% - Res is the result of adding E to the end of L, if E is not in L
% - otherwise, Res is L
append_element_nodup([], Element, [Element]).
append_element_nodup([Element|Rest], Element, [Element|Rest]) :-
 !.
append_element_nodup([H|T], Element, [H|Rest]) :-
 append_element_nodup(T, Element, Rest).

% append_elements_nodup(Es, L, Res)
% - Res is the result of adding all members of Es not already in L
%   to the end of L
append_elements_nodup([], Result, Result).
append_elements_nodup([Element|Elements], InList, Result) :-
 append_element_nodup(InList, Element, OutList),
 append_elements_nodup(Elements, OutList, Result).

% get_ord_assumptions(Ss, As)
% - As is the ordered set of assumptions in Ss
get_ord_assumptions(Ss, As) :-
 get_ord_assumptions(Ss, [], As).
% - same, with accumulator
get_ord_assumptions([], As, As).
get_ord_assumptions([A|Ss], InAs, As) :-
 assumption(A),
 !,
 ord_add_element(InAs, A, OutAs),
 get_ord_assumptions(Ss, OutAs, As).
get_ord_assumptions([_|Ss], InAs, As) :-
 get_ord_assumptions(Ss, InAs, As).

% split_fCbyC(VarsBodies, C, Sf, Snf)
% - divide a list of rule bodies according to
%   fCbyC filter using C
split_fCbyC([], _, [], []).
split_fCbyC([Body|Rest], C, [Body|RestSf], Snf) :-
 fCbyC(Body, C),
 !,
 split_fCbyC(Rest, C, RestSf, Snf).
split_fCbyC([Body|Rest], C, Sf, [Body|RestSnf]) :-
 split_fCbyC(Rest, C, Sf, RestSnf).

% used to construct new arguments in opponent's case 2(ii)
make_label_snf_args([], L, _, _, _, _, L, []).
make_label_snf_args([Body|Rest], L, Sm, Su, Cl, LL, InterL, [[L,Sm,NewSu,Cl]-LL|RestArgs]) :-
 append_elements_nodup(Body, Su, NewSu),
 L1 is L + 1,
 make_label_snf_args(Rest, L1, Sm, Su, Cl, LL, InterL, RestArgs).
 
% used in IB derivation to update values of F in opponent's case 2(ii)
make_f_updates([],_,_,[]).
make_f_updates([Body|Rest],Sm,Su,[FUpdate|RestUpdates]) :-
	append_elements_nodup(Body,Su,NewSu),
	ord_union(Sm,NewSu,FUpdate),
	make_f_updates(Rest,Sm,Su,RestUpdates).
	

% used to construct new arguments in opponent's case 2(ii)
make_label_sf_args([], _, L, _, _, _, _, L, [], []).
make_label_sf_args([Body|Rest], C, L, Sm, Su, Cl, LL, InterL, [[L,NewSm,NewSu,Cl]|RestArgs], [L-LL|RestAtts]) :-
 split_rule_culprits(Body, C, BodyNonC, BodyC),
 list_to_ord_set(BodyC, O_BodyC),
 ord_union(Sm, O_BodyC, NewSm),
 append_elements_nodup(BodyNonC, Su, NewSu),
 L1 is L + 1,
 make_label_sf_args(Rest, C, L1, Sm, Su, Cl, LL, InterL, RestArgs, RestAtts).

% split a list of sentences into those which are culprits and those which
% aren't
split_rule_culprits([], _, [], []).
split_rule_culprits([A|Rest], C, BodyNonC, [A|RestBodyC]) :-
 member(A, C),
 !,
 split_rule_culprits(Rest, C, BodyNonC, RestBodyC).
split_rule_culprits([A|Rest], C, [A|RestBodyNonC], BodyC) :-
 split_rule_culprits(Rest, C, RestBodyNonC, BodyC).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% OPTIONS

option(fileID, '_sol_').
option(num_sols, 0).    % all solutions
option(print_solution, fail).
option(show_solution, true).
option(verbose, fail).

option(derivation_type, ab).

option(strategy(opponent, arg_choice), s).
option(strategy(opponent, sentence_choice), p).
option(strategy(proponent, arg_choice), s).
option(strategy(proponent, sentence_choice), p).
option(strategy(proponent, rule_choice), s).
option(strategy(turn_choice), p).

% OPTIONS: generic

set_opt(Option, Value) :-
 retractall(option(Option,_)),
 assert(option(Option, Value)).

options :-
 option(Opt, Val),
 format('~w = ~w~n', [Opt,Val]),
 fail.
options.

% OPTIONS: setting

set_ab :-
 set_derivation(ab).
set_gb :-
 set_derivation(gb).
set_ib :-
 set_derivation(ib).

set_derivation(Type) :-
 set_opt(derivation_type, Type).

set_print :-
 set_opt(print_solution, true).
set_noprint :-
 set_opt(print_solution, fail).

set_strategies([TurnChoice,PropArg,OppArg,PropS,OppS,PropRule]) :-
 set_opt(strategy(turn_choice), TurnChoice),
 set_opt(strategy(proponent, arg_choice), PropArg),
 set_opt(strategy(opponent, arg_choice), OppArg),
 set_opt(strategy(proponent, sentence_choice), PropS),
 set_opt(strategy(opponent, sentence_choice), OppS),
 set_opt(strategy(proponent, rule_choice), PropRule).

set_show :-
 set_opt(show_solution, true).
set_noshow :-
 set_opt(show_solution, fail).

set_verbose :-
 set_opt(verbose, true).
set_quiet :-
 set_opt(verbose, fail).

% OPTIONS: checking

ab_derivation :-
 option(derivation_type, ab).
gb_derivation :-
 option(derivation_type, gb).
ib_derivation :-
 option(derivation_type, ib).

verbose :-
 option(verbose, Verbose),
 Verbose.

% OPTIONS: set some on loading (will be overridden if 'proxdd' script used)

:-
 source_file(X),
 (
  atom_concat(Path, 'code/selection.pl', X)
  -> atom_concat(Path, 'data/', FrameworkDir),
     set_opt(frameworkdir, FrameworkDir)
 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOADING

% specific

expected_predicate(asm(A), assumption(A)).
expected_predicate(assumption(X), assumption(X)).
expected_predicate(contrary(A,S), contrary(A,S)).
expected_predicate(myAsm(A), assumption(A)).
expected_predicate(myRule(H,B), rule(H,_,B)).
expected_predicate(rule(H,B), rule(H,_,B)).
expected_predicate(toBeProved(TBP), toBeProved(TBP)).

internal_predicate(filestem, 1).
internal_predicate(rule_counter, 1).

process_expected_term(:-(Head, true)) :-
 !,
 (
  Head = rule(_,RC,_)
  -> rule_counter(RC),
     incr_rule_counter
  ;  true
 ),
 (
  ground(Head)
  -> true
  ;  format('ERROR: non-ground ABA frameworks not supported!~n', [])
 ),
 assert(:-(Head, true)),
 fail.

incr_rule_counter :-
 rule_counter(RC),
 RC1 is RC + 1,
 retractall(rule_counter(_)),
 assert(rule_counter(RC1)).

postloading :-
 non_assumptions,
 check_input.

non_assumptions :-
 findall(S, ((
              rule(H, _, Body),
              member(S, [H|Body])
              ;
              contrary(_, S)
             ),
             \+ assumption(S)
            ),
          NonAssumptions),
 list_to_ord_set(NonAssumptions, O_NonAssumptions),
 member(S, O_NonAssumptions),
 (
  non_assumption(S)
  -> true
  ;  assert(non_assumption(S))
 ),
 fail.
non_assumptions.

% checks are:
%  - every assumption has a contrary
%  - no assumption is head of a rule
%  - every contrary is of an assumption
%  - there is at least one assumption
check_input :-
 findall(A, assumption(A), Asms),
 findall(A, (assumption(A), \+ contrary(A, _)), As),
 findall((S,C), (contrary(S,C), \+ assumption(S)), ContPairs),
 findall(A, (rule(A, _, _), assumption(A)), Hs),
 list_to_ord_set(As, O_As),
 list_to_ord_set(Hs, O_Hs),
 list_to_ord_set(ContPairs, O_ContPairs),
 (
  Asms = [],
  format('ERROR: no assumptions~n', []),
  fail
  ;
  member(A, O_As),
  format('ERROR: ~w declared an assumption without contrary~n', [A]),
  fail
  ;
  member((S,C), O_ContPairs),
  format('ERROR: ~w declared as contrary of ~w, which is not an assumption~n', [C,S]),
  fail
  ;
  member(A, O_Hs),
  format('ERROR: ~w head of a rule but declared an assumption~n', [A]),
  fail
 ).
check_input :-
 flush_output.

preloading_specific :-
 assert(rule_counter(1)).

% generic

loads(Input) :-
	preloading,	
	assert(filestem(test)),
	repeat, 
		member(X, Input),
		(last(Input, X) -> !; process_fail(X)), 
	(process_fail(X); true),
	postloading.

loadf(FileStem) :-
 preloading,
 filename(FileStem, FileName),
 assert(filestem(FileStem)),
 open(FileName, read, Fd),
 repeat,
  read(Fd, Term),
  process_fail(Term),
 !,
 close(Fd),
 postloading.

preloading :-
 internal_predicate(Func, Arity),
 functor(Term, Func, Arity),
 retractall(Term),
 fail.
preloading :-
 user_defined_predicate(Func, Arity),
 retract(user_defined_predicate(Func, Arity)),
 abolish(Func/Arity, [force(true)]),
 fail.
preloading :-
 preloading_specific.

filename(FileStem, DirAndFileName) :-
 option(frameworkdir, Dir),
 atom_concat(FileStem, '.pl', FileName),
 atom_concat(Dir, FileName, DirAndFileName).

process_fail(end_of_file) :-
 !.
process_fail(:-(Head,Body)) :-
 expected_predicate(Head, StoreHead),
 !,
 process_expected_term(:-(StoreHead,Body)),
 fail.
process_fail(:-(Head,Body)) :-
 !,
 functor(Head, Func, Arity),
 (
  user_defined_predicate(Func, Arity)
  -> true
  ;  assert(user_defined_predicate(Func, Arity))
 ),
 assert(:-(Head,Body)),
 fail.
process_fail(Fact) :-
 process_fail(:-(Fact,true)).

internal_predicate(Func, Arity) :-
 findall(Head, expected_predicate(_, Head), Heads),
 list_to_ord_set(Heads, O_Heads),
 member(Term, O_Heads),
 functor(Term, Func, Arity).


