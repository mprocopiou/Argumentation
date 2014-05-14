
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SHOWING: DERIVATION STEPS

poss_show_case(Case) :-
 (
  verbose
  -> format('~nCase ~w~n', [Case])
  ;  true
 ).

poss_show_step(StepN, Step) :-
(
  verbose
  -> show_step(StepN, Step)
  ;  true
 ).

show_step(N, [P,O,D,C,Args,Atts]) :-
 format('*** Step ~w~n', [N]),
 format('P:    [', []),
 show_step_list_args(P),
 format('O:    [', []),
 show_step_list_args(O),
 format('D:    ~w~n', [D]),
 format('C:    ~w~n', [C]),
 format('Arg:  [', []),
 show_step_list_args(Args),
 format('Att:  [', []),
 show_step_list(Atts).

show_step_list([]) :-
 format('<attack></attack>~n', []).
show_step_list([X]) :-
 !,
 format('<attack>~w</attack>~n', [X]).
show_step_list([H|T]) :-
 format('<attack>~w</attack>~n', [H]),
 show_step_list(T).

show_step_list_args([]) :-
 format('<argument></argument>~n', []).
show_step_list_args([X]) :-
 !,
 format('<argument>', []),
 show_arg(X),
 format('</argument>~n', []).
show_step_list_args([H|T]) :-
 format('<argument>', []),
 show_arg(H),
 format('</argument>~n', []),
 show_step_list_args(T).

show_arg(A-Attacked) :-
 !,
 show_basic_arg(A),
 format(' --> ~w', [Attacked]).
show_arg(A) :-
 show_basic_arg(A).

show_basic_arg([L,Sm,Su,Cl]) :-
 format('<number>~w</number>~n<Sm>~w</Sm>~n<Su>~w</Su>~n<Cl>~w</Cl>~n', [L,Sm,Su,Cl]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SHOWING: SOLUTIONS

show_print_result(Solution) :-
 option(print_solution, Print),
 (
  Print
  -> print_solution(Solution)
  ;  true
 ),
 option(show_solution, Show),
 (
  Show
  -> show_solution(Solution)
  ;  true
 ).

show_solution([D,C,Args,Atts]) :-
 sols(N),
 format('<document>~n',[]),
 format('<solution>~w</solution>~n', [N]),
 format('<def>~w</def>~n', [D]),
 format('<cul>~w</cul>~n', [C]),
 format('<arguments>', []),
 show_step_list_args(Args),
 format('</arguments>~n', []),
 format('<attacks>~n', []),
 show_step_list(Atts),
 format('</attacks>~n', []),
 format('</document>',[]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PRINT TO FILE

% NOTE: This section badly needs editing

graph_colour(background,                        '#FFFFFF').

graph_colour(proponent_arg,                     '#A2DDF3').
graph_colour(proponent_asm_toBeProved,          '<type>Asm</type><action>claim</action>').
graph_colour(proponent_asm,                     '<type>Asm</type><action>support</action>').
graph_colour(proponent_nonAsm_toBeProved,       '<type>noAsm</type><action>claim</action>').
graph_colour(proponent_nonAsm,                  '<type>nonAsm</type><action>argument</action>').

graph_colour(opponent_finished_arg,             '#CCCCCC').
graph_colour(opponent_unfinished_arg,           '#FFFFFF').
graph_colour(opponent_ms_border,                '#000000').
graph_colour(opponent_ms_asm_culprit,           '<type>Asm</type><action>attack</action>').
graph_colour(opponent_ms_asm_culprit_text,      '#FFFFFF').
graph_colour(opponent_ms_asm_defence,           '<type>Asm</type><action>support</action>').
graph_colour(opponent_ms_asm_defence_text,      '#FFFFFF').
graph_colour(opponent_ms_asm,                   '<type>Asm</type><action>support</action>').
graph_colour(opponent_ms_asm_text,              '#000000').
graph_colour(opponent_ms_nonAsm,                '<type>nonAsm</type><action>argument</action>').
graph_colour(opponent_ms_nonAsm_text,           '#FFFFFF').
graph_colour(opponent_ums_asm_defence,          '<type>Asm</type><action>support</action>').
graph_colour(opponent_ums_asm_defence_border,   '#117711').
graph_colour(opponent_ums_asm_defence_text,     '#FFFFFF').
graph_colour(opponent_ums_asm_culprit,          '<type>Asm</type><action>attack</action>').
graph_colour(opponent_ums_asm_culprit_border,   '#CC9922').
graph_colour(opponent_ums_asm_culprit_text,     '#FFFFFF').
graph_colour(opponent_ums_asm,                  '<type>Asm</type><action>support</action>').
graph_colour(opponent_ums_asm_border,           '#77BB77').
graph_colour(opponent_ums_asm_text,             '#000000').
graph_colour(opponent_ums_nonAsm,               '<type>nonAsm</type><action>argument</action>').
graph_colour(opponent_ums_nonAsm_border,        '#AAAAAA').
graph_colour(opponent_ums_nonAsm_text,          '#000000').

graph_colour(attack_edge,                       '#BB2222').

%%

print_solution(Solution) :-
 dot_filename(FileName),
 open(FileName, write, Fd),
 print_dot_file(Solution, Fd),
 close(Fd).

dot_filename(DirAndFileName) :-
 filestem(FileStem),
 option(frameworkdir, Dir),
 option(fileID, Suff),
 atom_concat(FileStem, '', File),
 sols(N),
 number_codes(N, NCodes),
 atom_codes(NAtom, NCodes),
 atom_concat(File, '', NumberedFile),
 atom_concat(NumberedFile, '.xml', FileName),
 atom_concat(Dir, FileName, DirAndFileName).

print_dot_file([D,C,Args,Att], Fd) :-
 dot_preliminaries(Fd),
 print_dot_args(Args, 0, D, C, Att, [], Fd),
  format(Fd, '~n</solution> ~n', []).

dot_preliminaries(Fd) :-
 format(Fd, '<solution> ~n', []).

print_dot_args([], _, _, _, _, _, _).
print_dot_args([[L,Sm,Su,Cl]|Args], ClusterN, D, C, Att, ArgTurns, Fd) :-
 (
  L = 1
  -> Player = proponent
  ;  memberchk(L-LL, Att),
     memberchk([LL,_,AttackedPlayer|_], ArgTurns),
     other_player(AttackedPlayer, Player)
 ),
 print_dot_arg_attacks([L,Sm,Su,Cl], ClusterN, Player, D, C, Att, ArgTurns, Fd),
 ClusterN1 is ClusterN + 1,
 print_dot_args(Args, ClusterN1, D, C, Att, [[L,ClusterN,Player,Sm]|ArgTurns], Fd).

print_dot_arg_attacks([L,Sm,Su,Cl], ClusterN, Player, D, C, Atts, ArgTurns, Fd) :-
 (
  Player = proponent
  -> graph_colour(proponent_arg, ArgColour)
  ;  (
      Su = []
      -> graph_colour(opponent_finished_arg, ArgColour)
      ;  graph_colour(opponent_unfinished_arg, ArgColour)
     )
 ),
 print_dot_arg_nodes(Sm, Su, Cl, ClusterN, Player, D, C, 0, Fd),
 graph_colour(attack_edge, AttackCol),
 print_dot_attacks(L, Atts, Cl, ClusterN, ArgTurns, C, Fd).

print_dot_arg_nodes(Sm, Su, Cl, ClusterN, Player, D, C, 0, Fd) :-
 !,
 print_dot_arg_node(0, ClusterN, Cl, Player, cl, D, C, Fd),
 print_dot_arg_nodes(Sm, Su, Cl, ClusterN, Player, D, C, 1, Fd).
print_dot_arg_nodes([], [], _, _, _, _, _, _, _).
print_dot_arg_nodes([], [S|RestSu], _, ClusterN, Player, D, C, NodeN, Fd) :-
 !,
 print_dot_arg_node(NodeN, ClusterN, S, Player, ums, D, C, Fd),
 format(Fd, '<attack>~n<source>s~w_~w</source>~n<target>s~w_0</target>~n</attack>~n', [ClusterN,NodeN,ClusterN]),
 NodeN1 is NodeN + 1,
 print_dot_arg_nodes([], RestSu, _, ClusterN, Player, D, C, NodeN1, Fd).
print_dot_arg_nodes([S|RestSm], Su, _, ClusterN, Player, D, C, NodeN, Fd) :-
 print_dot_arg_node(NodeN, ClusterN, S, Player, ms, D, C, Fd),
 format(Fd, '<attack>~n<source>s~w_~w</source>~n<target>s~w_0</target>~n</attack>~n', [ClusterN,NodeN,ClusterN]),
 NodeN1 is NodeN + 1,
 print_dot_arg_nodes(RestSm, Su, _, ClusterN, Player, D, C, NodeN1, Fd).

% TO BE PROVED
print_dot_arg_node(0, 0, S, _, claim, _, _, Fd) :-
 !,
 format(Fd, '<node>~n<id>s~0_0</id>~n', []),
 (
  assumption(S)
  -> graph_colour(proponent_asm_toBeProved, Colour)
  ;  graph_colour(proponent_nonAsm_toBeProved, Colour)
 ),
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [S,Colour]).
% PROPONENT ARGUMENTS
print_dot_arg_node(NodeN, ClusterN, S, proponent, _, _, _, Fd) :-
 format(Fd, '<node>~n<id>s~w_~w</id>~n ', [ClusterN,NodeN]),
 (
  assumption(S)
  -> graph_colour(proponent_asm, Colour)
  ;  graph_colour(proponent_nonAsm, Colour)
 ),
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [S,Colour]).
% OPPONENT ARGUMENTS: CLAIM
print_dot_arg_node(0, ClusterN, Claim, opponent, cl, _, _, Fd) :-
 format(Fd, '<node>~n<id>s~w_0</id>~n', [ClusterN]),
 graph_colour(opponent_ms_nonAsm, FillColour),
 graph_colour(opponent_ms_border, BorderCol),
 graph_colour(opponent_ms_nonAsm_text, Font),
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [Claim,FillColour]).
% OPPONENT ARGUMENTS: MARKED SUPPORT
print_dot_arg_node(NodeN, ClusterN, A, opponent, ms, D, C, Fd) :-
 format(Fd, '<node>~n<id>s~w_~w</id>~n', [ClusterN,NodeN]),
 (
  % MARKED SUPPORT: CULPRIT
  member(A, C)
  -> graph_colour(opponent_ms_asm_culprit, FillColour),
     graph_colour(opponent_ms_asm_culprit_text, Font)
  ;
  % MARKED SUPPORT: DEFENCE SET
  member(A, D)
  -> graph_colour(opponent_ms_asm_defence, FillColour),
     graph_colour(opponent_ms_asm_defence_text, Font)
  ;
  % MARKED SUPPORT: ASSUMPTION (NOT DEFENCE, NOT CULPRIT)
     graph_colour(opponent_ms_asm, FillColour),
     graph_colour(opponent_ms_asm_text, Font)
 ),
 graph_colour(opponent_ms_border, BorderCol),
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [A,FillColour]).
% OPPONENT ARGUMENTS: UNMARKED SUPPORT
print_dot_arg_node(NodeN, ClusterN, S, opponent, ums, D, C, Fd) :-
 format(Fd, '<node>~n<id>s~w_~w</id>~n', [ClusterN,NodeN]),
 (
  assumption(S)
  -> (
      member(S, D)
      -> 
      % UNMARKED SUPPORT: DEFENCE SET
         graph_colour(opponent_ums_asm_defence, FillColour),
         graph_colour(opponent_ums_asm_defence_border, Colour),
         graph_colour(opponent_ums_asm_defence_text, Font)
      ;
      member(S, C)
      ->
      % UNMARKED SUPPORT: CULPRIT
         graph_colour(opponent_ums_asm_culprit, FillColour),
         graph_colour(opponent_ums_asm_culprit_border, Colour),
         graph_colour(opponent_ums_asm_culprit_text, Font)
      ;
      % UNMARKED SUPPORT: NON-DEFENCE SET, NON-CULPRIT
         graph_colour(opponent_ums_asm, FillColour),
         graph_colour(opponent_ums_asm_border, Colour),
         graph_colour(opponent_ums_asm_text, Font)
     )
  ;  
     % UNMARKED SUPPORT: NON-ASSUMPTION
     graph_colour(opponent_ums_nonAsm, FillColour),
     graph_colour(opponent_ums_nonAsm_border, Colour),
     graph_colour(opponent_ums_nonAsm_text, Font)
 ),
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [S,FillColour]).

print_dot_attacks(L, Atts, Cl, ClusterN, ArgTurns, C, Fd) :-
 findall([AttClusterN,Sm], (member(L-LL, Atts),
                            member([LL,AttClusterN,_,Sm], ArgTurns)),
         AttClusterNs),
 print_dot_attacks_aux(AttClusterNs, Cl, ClusterN, C, Fd).

print_dot_attacks_aux([], _, _, _, _).
print_dot_attacks_aux([[AttClusterN,Sm]|RestAttClusterNs], Cl, ClusterN, C, Fd) :-
 (
  contrary(A, Cl),
  nth1(NodeN, Sm, A),
  format(Fd, '<attack>~n<source>s~w_0</source>~n<target>s~w_~w</target>~n</attack>~n', [ClusterN,AttClusterN,NodeN]),
  fail
  ;
  true
 ),
 print_dot_attacks_aux(RestAttClusterNs, Cl, ClusterN, C, Fd).

%% HELPERS

other_player(proponent, opponent).
other_player(opponent, proponent).

format_lines([], _).
format_lines([Line|Rest], Fd) :-
 format(Fd, Line, []),
 format(Fd, '~n', []),
 format_lines(Rest, Fd).


