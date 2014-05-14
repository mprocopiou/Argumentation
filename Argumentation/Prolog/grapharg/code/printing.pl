
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PRINTING: DERIVATION STEPS

print_step(N, [P,O,D,C,JsP,JsO,Att,G]) :-
 format('*** Step ~w~n', [N]),
 format('P:    [', []),
 print_step_list(P),
 format('O:    [', []),
 print_step_list(O),
 format('D:    [', []),
 print_step_list(D),
 format('C:    [', []),
 print_step_list(C),
 format('JsP:  [', []),
 print_step_list_brackets(JsP),
 format('JsO:  [', []),
 print_step_list(JsO),
 format('Att:  [', []),
 print_step_list_brackets(Att),
 format('G:    [', []),
 print_step_list_brackets(G).

print_step_list([]) :-
 format(']~n', []).
print_step_list([X]) :-
 !,
 format('~w]~n', [X]).
print_step_list([H|T]) :-
 format('~w,~n       ', [H]),
 print_step_list(T).

print_step_list_brackets([]) :-
 format(']~n', []).
print_step_list_brackets([X]) :-
 !,
 format('(~w)]~n', [X]).
print_step_list_brackets([H|T]) :-
 format('(~w),~n       ', [H]),
 print_step_list_brackets(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PRINTING: RESULTS

show_result([D,C,JsP,JsO,Att,G]) :-
 format('~nDEFENCE:             ~w~n', [D]),
 format('CULPRITS:            ~w~n', [C]),
 format('PROP JUSTIFICATIONS: ~w~n', [JsP]),
 format('OPP JUSTIFICATIONS:  ~w~n', [JsO]),
 format('ATTACKS:             ~w~n', [Att]),
 format('GRAPH:               ~w~n', [G]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PRINTING: PRINT TO FILE

graph_colour(background,                        '#FFFFFF').

graph_colour(proponent_justifications,          '#A2DDF3').
graph_colour(proponent_asm_toBeProved,          '<type>Asm</type><action>claim</action>').
graph_colour(proponent_asm,                     '<type>Asm</type><action>support</action>').
graph_colour(proponent_nonAsm_toBeProved,       '<type>noAsm</type><action>claim</action>').
graph_colour(proponent_nonAsm,                  '<type>nonAsm</type><action>argument</action>').

graph_colour(opponent_finished_justification,   '#CCCCCC').
graph_colour(opponent_unfinished_justification, '#FFFFFF').
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

%

print_result(Result) :-
 option(print_to_file, Print),
 (
  Print
  -> print_to_file(Result)
  ;  true
 ),
 option(show_solution, Show),
 (
  Show
  -> show_result(Result)
  ;  true
 ).

%

print_to_file(Result) :-
 filestem(FileStem),
 option(frameworkdir, Dir),
 option(fileID, Suff),
 atom_concat(FileStem, '', File),
 sols(N),
 number_codes(N, NCodes),
 atom_codes(NAtom, NCodes),
 atom_concat(File, '', NumberedFile),
 atom_concat(NumberedFile, '.xml', FileName),
 atom_concat(Dir, FileName, DirAndFileName),
 open(DirAndFileName, write, Fd),
 dot_file(Result, Fd),
 close(Fd).

dot_file([D,C,JsP,JsO,Att,_], Fd) :-
 dot_preliminaries(Fd),
 proponent_cluster(JsP, Fd, PropNodeInfo),
 opponent_clusters(JsO, D, C, PropNodeInfo, Att, Fd, 1),
  format(Fd, '~n</solution> ~n', []).

dot_preliminaries(Fd) :-
 format(Fd, '<solution> ~n', []).
%

proponent_cluster(JsP, Fd, NodeInfo) :-
 graph_colour(proponent_justifications, PropCol),
 proponent_nodes(JsP, 0, Fd, NodeInfo),
 proponent_edges(JsP, NodeInfo, Fd).

proponent_nodes([], _, _, []).
proponent_nodes([(A,*)|Rest], N, Fd, [(A,N,0)|RestNodes]) :-
 !,
 number_atom(N, NAtom),
 format(Fd, '<node>~n<id>s0_~w</id>~n ', [NAtom]),
 (
  proving(A)
  -> graph_colour(proponent_asm_toBeProved, Colour)
  ;  graph_colour(proponent_asm, Colour)
 ),
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [A,Colour]),
 N1 is N + 1,
 proponent_nodes(Rest, N1, Fd, RestNodes).
proponent_nodes([(S,_)|Rest], N, Fd, [(S,N,0)|RestNodes]) :-
 number_atom(N, NAtom),
 format(Fd, '<node>~n<id>s0_~w</id>~n ', [NAtom]),
 (
  proving(S)
  -> graph_colour(proponent_nonAsm_toBeProved, Colour)
  ;  graph_colour(proponent_nonAsm, Colour)
 ),
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [S,Colour]),
 N1 is N + 1,
 proponent_nodes(Rest, N1, Fd, RestNodes).

proponent_edges([], _, _).
proponent_edges([(_,*)|Rest], NodeInfo, Fd) :-
 !,
 proponent_edges(Rest, NodeInfo, Fd).
proponent_edges([(S,RuleID)|Rest], NodeInfo, Fd) :-
 rule(S, RuleID, Body),
 body_edges(Body, S, 0, NodeInfo, Fd),
 proponent_edges(Rest, NodeInfo, Fd).

%

opponent_clusters([], _, _, _, _, _, _).
opponent_clusters([Ss-Js-_Conc|RestOpJs], D, C, PropNodeInfo, Att, Fd, ClusterN) :-
 (
  Ss = []
  -> graph_colour(opponent_finished_justification, OppClusterCol)
  ;  graph_colour(opponent_unfinished_justification, OppClusterCol)
 ),
 opponent_nodes(Js-Ss, D, C, ClusterN, 0, Fd, [], OppNodeInfo),
 opponent_edges(Js, D, C, ClusterN, OppNodeInfo, Fd),
 graph_colour(attack_edge, AttackCol),
 attacks(Att, PropNodeInfo, OppNodeInfo, Fd),
 ClusterN1 is ClusterN + 1,
 opponent_clusters(RestOpJs, D, C, PropNodeInfo, Att, Fd, ClusterN1).

opponent_nodes([]-[], _, _, _, _, _, NodeInfo, NodeInfo).
opponent_nodes([(A,*)|RestJs]-Ss, D, C, ClusterN, N, Fd, InNodeInfo, NodeInfo) :-
 !,
 number_atom(ClusterN, ClusterNAtom),
 number_atom(N, NAtom),
 format(Fd, '<node>~n<id>s~w_~w</id>~n ', [ClusterNAtom,NAtom]),
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
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [A,FillColour]),
 N1 is N + 1,
 opponent_nodes(RestJs-Ss, D, C, ClusterN, N1, Fd, [(A,N,ClusterN)|InNodeInfo], NodeInfo).
opponent_nodes([(S,_)|RestJs]-Ss, D, C, ClusterN, N, Fd, InNodeInfo, NodeInfo) :-
 !,
 number_atom(ClusterN, ClusterNAtom),
 number_atom(N, NAtom),
 format(Fd, '<node>~n<id>s~w_~w</id>~n ', [ClusterNAtom,NAtom]),
 graph_colour(opponent_ms_nonAsm, FillColour),
 graph_colour(opponent_ms_border, BorderCol),
 graph_colour(opponent_ms_nonAsm_text, Font),
 format(Fd, '<name>~w</name>~n~w~n</node>~n', [S,FillColour]),
 N1 is N + 1,
 opponent_nodes(RestJs-Ss, D, C, ClusterN, N1, Fd, [(S,N,ClusterN)|InNodeInfo], NodeInfo).
opponent_nodes([]-[S|RestSs], D, C, ClusterN, N, Fd, InNodeInfo, NodeInfo) :-
 (
  member((S,_,_), InNodeInfo)
  -> N1 is N,
     OutNodeInfo = InNodeInfo
  ;  number_atom(ClusterN, ClusterNAtom),
     number_atom(N, NAtom),
     format(Fd, '<node>~n<id>s~w_~w</id>~n ', [ClusterNAtom,NAtom]),
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
     format(Fd, '<name>~w</name>~n~w~n</node>~n', [S,FillColour]),
     N1 is N + 1,
     OutNodeInfo = [(S,N,ClusterN)|InNodeInfo]
 ),
 opponent_nodes([]-RestSs, D, C, ClusterN, N1, Fd, OutNodeInfo, NodeInfo).

opponent_edges([], _, _, _, _, _).
opponent_edges([(_,*)|Rest], D, C, ClusterN, NodeInfo, Fd) :-
 !,
 opponent_edges(Rest, D, C, ClusterN, NodeInfo, Fd).
opponent_edges([(S,RuleID)|Rest], D, C, ClusterN, NodeInfo, Fd) :-
 rule(S, RuleID, Body),
 body_edges(Body, S, ClusterN, NodeInfo, Fd),
 opponent_edges(Rest, D, C, ClusterN, NodeInfo, Fd).

% attacks(Att, PropNodeInfo, OppNodeInfo, Fd)

attacks([], _, _, _).
attacks([(FromS,ToS)|RestAtt], PropNodeInfo, OppNodeInfo, Fd) :-
 member((FromS,FromN,FromClusterN), PropNodeInfo),
 member((ToS,ToN,ToClusterN), OppNodeInfo),
 !,
 number_atom(FromN, FromNAtom),
 number_atom(FromClusterN, FromClusterNAtom),
 number_atom(ToN, ToNAtom),
 number_atom(ToClusterN, ToClusterNAtom),
 format(Fd, '<attack>~n<source>s~w_~w</source>~n<target>s~w_~w</target>~n</attack>~n', [FromClusterNAtom,FromNAtom,ToClusterNAtom,ToNAtom]),
 attacks(RestAtt, PropNodeInfo, OppNodeInfo, Fd).
attacks([(FromS,ToS)|RestAtt], PropNodeInfo, OppNodeInfo, Fd) :-
 member((FromS,FromN,FromClusterN), OppNodeInfo),
 member((ToS,ToN,ToClusterN), PropNodeInfo),
 !,
 number_atom(FromN, FromNAtom),
 number_atom(FromClusterN, FromClusterNAtom),
 number_atom(ToN, ToNAtom),
 number_atom(ToClusterN, ToClusterNAtom),
 format(Fd, '<attack>~n<source>s~w_~w</source>~n<target>s~w_~w</target>~n</attack>~n', [FromClusterNAtom,FromNAtom,ToClusterNAtom,ToNAtom]),
 attacks(RestAtt, PropNodeInfo, OppNodeInfo, Fd).
attacks([_|RestAtt], PropNodeInfo, OppNodeInfo, Fd) :-
 attacks(RestAtt, PropNodeInfo, OppNodeInfo, Fd).

%

format_lines([], _).
format_lines([Line|Rest], Fd) :-
 format(Fd, Line, []),
 format(Fd, '~n', []),
 format_lines(Rest, Fd).

% convert a number into the corresponding atom
number_atom(N, A) :-
 number_codes(N, Codes),
 atom_codes(A, Codes).

body_edges([], _, _, _, _).
body_edges([SFrom|Rest], STo, ClusterN, NodeInfo, Fd) :-
 memberchk((SFrom,NFrom,_), NodeInfo),
 memberchk((STo,NTo,_), NodeInfo),
 number_atom(NFrom, FromAtom),
 number_atom(NTo, ToAtom),
 number_atom(ClusterN, ClusterNAtom),
 format(Fd, '<attack>~n<source>s~w_~w</source>~n<target>s~w_~w</target>~n</attack>~n', [ClusterNAtom,FromAtom,ClusterNAtom,ToAtom]),
 body_edges(Rest, STo, ClusterN, NodeInfo, Fd).

