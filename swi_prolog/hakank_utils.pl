/*

  Utils in SWI Prolog

  Mostly for clpfd.

  TODO: Make it a package.

  Model created by Hakan Kjellerstrand, hakank@gmail.com
  See also my SWI Prolog page: http://www.hakank.org/swi_prolog/

*/
:- module(hakank_utils,
          [
           time2/2,
           new_matrix/3,
           new_matrix/4,
           domain_matrix/2,
           print_matrix/1,      % perhaps not?
           matrix_dimensions/3,
           latin_square/1,        
           list_domains/2,
           matrix_element/4,
           matrix_element1/4,
           matrix_element2/4,
           matrix_element3/4,
           matrix_element4/4,
           matrix_element5/4,
           element2/3,
           alldifferent_except_0/1,
           alldifferent_except_n/2,
           increasing/1,
           increasing_strict/1,
           decreasing/1,
           decreasing_strict/1,
           count_occurrences/3,
           extract_from_indices/3,
           extract_from_indices2d/3,
           extract_from_indices2d/4,           
           scalar_product2/3,
           min_list_clp/2,
           max_list_clp/2,
           slice/4,
           to_num/2,
           to_num/3,
           zip2/3,
           zip3/4,
           inverse/1,
           inverse/2,
           between/4,
           same/1,
           lex_lte/2,
           lex_lt/2,
           numlist_cross2/3,
           numlist_cross3/4,           
           diagonal1_slice/2,
           diagonal2_slice/2,
           prod/2,
           regular/6,
           regular2/7,           
           rotate/2,
           variable_selection/1,
           value_selection/1,
           strategy_selection/1,
           labelings/3,

           
           print_attrs_list/1
          ]).

:- use_module(library(clpfd)).


%%
%% Returns the time of a goal.
%%
time2(Goal, Time) :-
        statistics(cputime, Time1),
        call(Goal),
        statistics(cputime,Time2),
        Time is Time2 - Time1.

%%
%% Create a new matrix, but without any domain
%%
new_matrix(NumRows, NumCols, Matrix) :-
        length(Cols,NumCols),
        length(Matrix,NumRows),
        maplist(same_length(Cols),Matrix).

%%
%% Create a matrix of dimension NumRows x NumCols and with domain Domain.
%%
new_matrix(NumRows, NumCols, Domain, Matrix) :-
        length(Cols,NumCols),
        length(Matrix,NumRows),
        maplist(same_length(Cols),Matrix),
        domain_matrix(Matrix,Domain).


%%
%% Ensure the domain of Domain
%%
domain_matrix([],_).
domain_matrix([L1|LRest],Domain) :-
        L1 ins Domain,
        domain_matrix(LRest, Domain).

%%
%% Nice print of a matrix.
%%
print_matrix(Matrix) :-
        maplist(writeln,Matrix),
        nl.

%%
%% Dimensions of a matrix.
%%
matrix_dimensions(Matrix, Rows, Cols) :-
        length(Matrix,Rows),
        transpose(Matrix, Transposed),
        length(Transposed, Cols).

%%
%% latin_square(X)
%%
%% Ensure that X (NxN matrix) is a Latin Square
%%
latin_square(X) :-
        maplist(all_different,X),
        transpose(X,XT),
        maplist(all_different,XT).


%%
%% Create a list of the domains in the
%% list of decision variables in list L.
%% (not reversible).
%%
list_domains(L,Domains) :-
        list_domains(L,[],Domains).
list_domains([], D,D).
list_domains([H|T],D0,[Dom|D]) :-
        fd_size(H,Size),
        fd_dom(H,Dom1),
        (Size > 1 -> 
         Dom = Dom1
        ;
          Dom..Dom = Dom1
        ),
        list_domains(T,D0,D).


%%
%% Matrix[I,J] = Val
%%
matrix_element(X, I, J, Val) :-
        matrix_element5(X,I,J,Val).

%%
%% Different approaches.
%% matrix_element2/4 and matrix_element5/4 seems to work best.
%%
matrix_element1(X, I, J, Val) :-
        element(I, X, Row),
        element(J, Row, Val).

matrix_element2(X, I, J, Val) :-
        nth1(I, X, Row),
        element(J, Row, Val).

matrix_element3(X, I, J, Val) :-
        freeze(I, (nth1(I, X, Row),freeze(J,nth1(J,Row,Val)))).

matrix_element4(X, I, J, Val) :-
        freeze(I, (element(I, X, Row),freeze(J,element(J,Row,Val)))).

matrix_element5(X, I, J, Val) :-
        nth1(I, X, Row),
        nth1(J, Row, Val).

%%
%% Y[X[I]] #= I (symmetry between two lists),
%% cf. inverse/2.
%% 
element2(I,X,Y) :-
   element(I,X,XI),
   element(XI,Y,XIY),
   XIY #= I.


%%
%% alldifferent_except_0(X)
%%
%% Ensure that all values in Xs which are != 0 are different.
%%                                %
%%
alldifferent_except_0(X) :-
        alldifferent_except_n(X,0).

%%
%% alldifferent except N.
%%
alldifferent_except_n(X,N) :-
        length(X,Len),
        findall([I,J], (between(2,Len,I), I1 #= I-1, between(1,I1,J)),L),
        alldifferent_except_n_(L,X,N).

alldifferent_except_n_([], _X,_N).
alldifferent_except_n_([[I,J]|L],X,N) :-
        element(I,X,XI),
        element(J,X,XJ),        
        (XI #\= N #/\ XJ #\= N) #==> (XI #\= XJ),
        alldifferent_except_n_(L,X,N).


%%
%% X must be a (strictly/not strictly) increasing/descreasing list
%%
increasing(X) :-
        chain(X, #=<).

increasing_strict(X) :-
        chain(X, #<).

decreasing(X) :-
        chain(X, #>=).

decreasing_strict(X) :-
        chain(X, #>).

%%
%% In the list L, there must be exactly Count occurrences of Element
%%
count_occurrences(L,Element,Count) :-
        count_occurrences_(L,Element,0, Count).

count_occurrences_([],_Element,Count, Count).
count_occurrences_([H|T],Element,Count0, Count) :-
        H #= Element,
        Count1 #= Count0 + 1,
        count_occurrences_(T,Element,Count1, Count).
count_occurrences_([H|T],Element,Count0, Count) :-
        H #\= Element,
        count_occurrences_(T,Element,Count0, Count).


%%
%% Extract from indices in a list.
%% extract_from_indices2d([I1,I2,I3,...], X, ExtractedFromX)
%%
%% It seems to be reversible.
%%
extract_from_indices(Is,X,Xs) :-
        extract_from_indices(Is, X, [], Xs).
extract_from_indices([], _X, Xs, Xs).
extract_from_indices([I|Is], X, Xs0, [XI|Xs]) :-
        element(I,X,XI),
        extract_from_indices(Is, X, Xs0, Xs).


%%
%% Extract from indices in a matrix (2d list).
%% extract_from_indices2d([[I1,J1],[I2,J2],...], X,[], ExtractedFromXs)
%%
extract_from_indices2d(Is,X,Xs) :-
        extract_from_indices2d(Is, X, [], Xs).
extract_from_indices2d([], _X, Xs, Xs).
extract_from_indices2d([[I,J]|IJs], X, Xs0, [XIJ|Xs]) :-
        matrix_element(X,I,J,XIJ),
        extract_from_indices2d(IJs, X, Xs0, Xs).

%%
%% The built-in scalar_product/4 don't accept two lists of decision variables
%%
scalar_product2(Xs,Ys,Sum) :-
        scalar_product2_(Xs,Ys,0,Sum).
scalar_product2_([],[],Sum,Sum).
scalar_product2_([X|Xs],[Y|Ys],Sum0,Sum) :-
        Sum1 #= Sum0 + X*Y,
        scalar_product2_(Xs,Ys,Sum1,Sum).


%%
%% min_list_clp(List,MinElement)
%%
min_list_clp([H|T], Min) :-
    min_list_clp(T, H, Min).

min_list_clp([], Min, Min).
min_list_clp([H|T], Min0, Min) :-
    Min1 #= min(H, Min0),
    min_list_clp(T, Min1, Min).

%%
%% max_list_clp(List,MinElement)
%%
max_list_clp([H|T], Min) :-
    max_list_clp(T, H, Min).

max_list_clp([], Min, Min).
max_list_clp([H|T], Min0, Min) :-
    Min1 #= max(H, Min0),
    max_list_clp(T, Min1, Min).


%%
%% From https://github.com/sunilnandihalli/99-problems-in-prolog/blob/master/slice.pl
%%
%% slice(List,From,To,Slice)
%%
%% Note: It's 0 based!
%% Note2: It might be easier to use extract_from_indices/3 instead.
%%
slice([X|_],0,0,[X]).
slice([X|Xs],0,K,[X|Ys]):- K > 0, K1 is K - 1, slice(Xs,0,K1,Ys).
slice([_|Xs],I,K,Ys):- I > 0, I1 is I - 1, K1 is K - 1, slice(Xs,I1,K1,Ys).



%%
%% to_num(List, Base, Num)
%%
%% sum(List) #= Num
%%
to_num(List,Num) :-
        to_num(List,10,Num).
to_num(List, Base, Num) :-
        length(List,Len),
        to_num_(List,1,Len,Base,0, Num).

% Num #= sum([List[I]*Base**(Len-I) : I in 1..Len]).
to_num_([],_I,_Len,_Base,Num,Num).
to_num_([H|T],I,Len,Base,Num0,Num) :-
        Len1 #= Len-I,
        Num1 #= Num0 + H*(Base^Len1),
        I1 #= I+1,
        to_num_(T,I1,Len,Base,Num1,Num).

%%
%% zip2(List1,List2, ZippedList)
%%
%% ZippedList is the zipped list of List1 and List2.
%% Note: If List1 and List2 is of different length, zip2/3 fails.
%%
%% Examples:
%% ?- zip2([a,b,c],[1,2,3],[[a,1],[b,2],[c,3]])
%% true.
%% ?- make,zip2(L1,[1,2,3],[[a,1],[b,2],[c,3]]).
%% L1 = [a, b, c].
%%
%% ?- make,zip2([a,b,c],L2,[[a,1],[b,2],[c,3]]).
%% L2 = [1, 2, 3].
%% 
%% ?- make,zip2(L1,L2,[[a,1],[b,2],[c,3]]).
%% L1 = [a, b, c],
%% L2 = [1, 2, 3] ;
%% false.
%%
%% ?- make,zip2(L1,[1,2,3],[[a,1],[b,2],[c,X]]).
%% L1 = [a, b, c],
%% X = 3.
%%
zip2(L1,L2,L) :-
        zip2(L1,L2,[],L).
zip2([],[], L,L).
zip2([H1|T1],[H2|T2], L0,[L1|L]) :-
        L1 = [H1,H2],
        zip2(T1,T2, L0,L).


zip3(L1,L2,L3,L) :-
        zip3(L1,L2,L3,[],L).
zip3([],[],[],L,L).
zip3([H1|T1],[H2|T2], [H3|T3], L0,[L1|L]) :-
        L1 = [H1,H2,H3],
        zip3(T1,T2, T3, L0,L).



%%
%% inverse/1, a.k.a. "self-assignment"
%%
inverse(L) :-
        inverse(L,L).

%%
%% inverse(L1,L2), a.k.a. assignment
%%
%% For each element in L1 and L2
%%     - L1[I] = I
%%     or
%%     - X[I] = J <=> X[J] = I
%% 
inverse(L1,L2) :-
        %% same length
        length(L1,Len),
        length(L2,Len),
        findall([I,J],(between(1,Len,I),between(1,Len,J)),IJs),
        inverse_(IJs,L1,L2).


inverse_([],_L1,_L2).
inverse_([[I,J]|IJs],L1,L2) :-
        element(I,L1,L1I),
        element(J,L2,L2J),
        (J #= L1I) #<==> (I #= L2J),
        inverse_(IJs,L1,L2).

%%
%% between/4
%% As between/3 but with a step parameter
%%
between(From,Step,To,N) :-
        Div #= To div Step,
        between(From,Div,Tmp),
        TmpFrom #= Tmp-From,
        N #= TmpFrom*Step+From.

%%
%% All elements in the list must be the same.
%%
same(Xs) :-
        element(1,Xs,X),
        maplist(same(X),Xs).

same(X,X2) :-
        X2 #= X.

%%
%% X1 is lexicographic less or equal than X2
%%
lex_lte(X1,X2) :-
        X1 #=< X2.

%%
%% X1 is lexicographic less than X2
%%
lex_lt(X1,X2) :-
        X1 #=< X2.


%%
%% All combinations of 1..N1 x 1..N2 -> [[I1,J1],[I2,J2],....]
%%
numlist_cross2(N1,N2,IJs) :-
        findall([I,J],(between(1,N1,I),
                       between(1,N2,J)
                      ),
                IJs).

numlist_cross3(N1,N2,N3,IJKs) :-
        findall([I,J,K],(between(1,N1,I),
                       between(1,N2,J),
                       between(1,N3,K)
                      ),
                IJKs).


%%
%% Diagonal 1 slice.
%%
diagonal1_slice(M,Slice) :-
        length(M,N),
        findall([I,I],
                between(1,N,I),
                Ixs
               ),
        extract_from_indices2d(Ixs,M,Slice).


%%
%% Diagonal 2 slice.
%%
diagonal2_slice(M,Slice) :-
        length(M,N),
        findall([I,I2],
                (between(1,N,I),
                 I2 #= N-I+1)
               , Ixs
               ),
        extract_from_indices2d(Ixs,M,Slice).

%%
%% Helper for prod/2. (Not exported.)
%%
mult(X,Y,Z) :- Z #= X*Y.

%%
%% prod(List,Product)
%%
%% Product is the product of the number is a list.
%%
prod(L,Product) :-
        foldl(mult,L,1,Product).
           


/*

  regular(X, Q, S, D, Q0, F)
  
  This is a translation of MiniZinc's regular constraint (defined in
  lib/zinc/globals.mzn), via the Comet code refered above.
  All comments in '"""' are from the MiniZinc code.
  
  Note: This is a translation of my Picat implementation
        (http://hakank.org/picat/regular.pi)
  """
  The sequence of values in array 'x' (which must all be in the range 1..S)
  is accepted by the DFA of 'Q' states with input 1..S and transition
  function 'd' (which maps (1..Q, 1..S) -> 0..Q)) and initial state 'q0'
  (which must be in 1..Q) and accepting states 'F' (which all must be in
  1..Q).  We reserve state 0 to be an always failing state.
  """
  
  x : IntVar array
  Q : number of states
  S : input_max
  d : transition matrix
  q0: initial state
  F : accepting states
  
*/
regular(X, Q, S, D, Q0, F) :-

        %% """
        %% If x has index set m..n-1, then a[m] holds the initial state
        %% (q0), and a[i+1] holds the state we're in after  processing
        %% x[i].  If a[n] is in F, then we succeed (ie. accept the string).
        %% """
        M = 1,
        length(X,N),
        N2 #= N+1,
        length(A,N2),
        A ins 1..Q,

        X ins 1..S, %% """Do this in case it's a var."""

        element(M,A,AM),
        AM #= Q0,       %% Set a[0], initial state
        
        %% MiniZinc's infamous matrix element
        %%   a[i+1] = d[a[i], x[i]]
        numlist(1,N,Is),
        maplist(regular_loop(A,X,D),Is),
        
        %% member(A[N2], F). %% """Check the final state is in F."""
        %% A[N2] :: F.       %% """Check the final state is in F."""
        element(N2,A,AN2),
        element(_,F,AN2).


/*

  regular2/7 is the same as regular/6 but it also returns A, 
  the state list. This might be handy for debugging or
  explorations.


*/

regular2(X, Q, S, D, Q0, F, A) :-

        %% """
        %% If x has index set m..n-1, then a[m] holds the initial state
        %% (q0), and a[i+1] holds the state we're in after  processing
        %% x[i].  If a[n] is in F, then we succeed (ie. accept the string).
        %% """
        M = 1,
        length(X,N),
        N2 #= N+1,
        length(A,N2),
        A ins 1..Q,

        X ins 1..S, %% """Do this in case it's a var."""

        element(M,A,AM),
        AM #= Q0,       %% Set a[0], initial state
        
        %% MiniZinc's infamous matrix element
        %%   a[i+1] = d[a[i], x[i]]
        numlist(1,N,Is),
        maplist(regular_loop(A,X,D),Is),
        
        %% member(A[N2], F). %% """Check the final state is in F."""
        %% A[N2] :: F.       %% """Check the final state is in F."""
        element(N2,A,AN2),
        element(_,F,AN2).


%%
%% The matrix element loop
%%   a[i+1] = d[a[i], x[i]]
%%
regular_loop(A,X,D,I) :-
        element(I,A,AI),
        element(I,X,XI),
        I1 #= I+1,
        element(I1,A,AI1),
        matrix_element(D,AI,XI,AI1).

%%
%% rotate a list (put first element -> last)
%%
rotate(L,L2) :-
        L=[X|LRest], append(LRest,[X],L2).



%% For benchmarking different labelings
% Variable selection
variable_selection([leftmost,ff,ffc, min,max]).

% Value selection
value_selection([up,down]).

% Branching strategy
strategy_selection([step,enum,bisect]).

labelings(VariableSelection,ValueSelection,StrategySelection) :-
        variable_selection(VariableSelection),
        value_selection(ValueSelection),
        strategy_selection(StrategySelection).
          


%%% EXPERIMENTAL %%%
%%
%% Prints the get_attrs/2 value (attributed variables info)
%%
print_attrs_list([]).
print_attrs_list([V|Vs]) :-
        get_attrs(V,Attributes),
        writeln(v=V),
        writeln(attributes=Attributes),
        print_attrs_list(Vs).
