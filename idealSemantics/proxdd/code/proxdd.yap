
samsort(Order, List, Sorted) :-
 sam_sort(List, Order, [], 0, Sorted).

sam_sort([], Order, Stack, _, Sorted) :-
 sam_fuse(Stack, Order, Sorted).
sam_sort([Head|Tail], Order, Stack, R, Sorted) :-
 sam_run(Tail, [Head|Queue], [Head|Queue], Order, Run, Rest),
 S is R + 1,
 sam_fuse(Stack, Run, Order, S, NewStack),
 sam_sort(Rest, Order, NewStack, S, Sorted).

sam_fuse([], _, []).
sam_fuse([Run|Stack], Order, Sorted) :-
 sam_fuse(Stack, Run, Order, 0, [Sorted]).

sam_fuse([B|Rest], A, Order, K, Ans) :-
 0 is K /\ 1,
 !,
 J is K >> 1,
 sam_merge(B, A, Order, C),
 sam_fuse(Rest, C, Order, J, Ans).
sam_fuse(Stack, Run, _, _, [Run|Stack]).

sam_run([], Run, [_], _, Run, []).
sam_run([Head|Tail], QH, QT, Order, Run, Rest) :-
 sam_rest(QH, QT, Head, Tail, Order, Run, Rest).

sam_rest(Qh, [Last|Qt], Head, Tail, Order, Run, Rest) :-
 call(Order, Last, Head),
 !,
 Qt = [Head|_],
 sam_run(Tail, Qh, Qt, Order, Run, Rest).
sam_rest(Run, [_], Head, Tail, Order, Run, [Head|Tail]) :-
 head_less_equal(Order, Run, Head),
 !.
sam_rest(Qh, Qt, Head, Tail, Order, Run, Rest) :-
 sam_run(Tail, [Head|Qh], Qt, Order, Run, Rest).

head_less_equal(Order, [H|_], X) :-
 call(Order, H, X).

sam_merge(List1, [], _, List1) :-
 !.
sam_merge([], List2, _, List2) :-
 !.
sam_merge([Head1|Tail1], [Head2|Tail2], Order, [Head1|Merged]) :-
 call(Order, Head1, Head2),
 !,
 sam_merge(Tail1, [Head2|Tail2], Order, Merged).
sam_merge(List1, [Head2|Tail2], Order, [Head2|Merged]) :-
 sam_merge(List1, Tail2, Order, Merged).

