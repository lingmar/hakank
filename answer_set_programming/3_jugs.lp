% 
% 3 jugs problem in ASP.
% 
% Problem from Taha "Introduction to Operations Research", page 245f .
% 
% Also see http://mathworld.wolfram.com/ThreeJugProblem.html
% 
% This was created by Hakan Kjellerstrand, hakank@bonetmail.com
% See also http://www.hakank.org/answer_set_programming/
%

%
% We want to take us from state 1 to state 15 
% in smallest amount of steps.
% 
% g(EdgeId, From, To).
%
g(1, 1, 2).
g(2, 1, 9).
g(3, 2, 3).
g(4, 3, 4).
g(5, 3, 9).
g(6, 4, 5).
g(7, 5, 6).
g(8, 5, 9).
g(9, 6, 7).
g(10, 7, 8).
g(11, 7, 9).
g(12, 8, 15).
g(13, 9, 10).
g(14, 10, 2).
g(15, 10, 11).
g(16, 11, 12).
g(17, 12, 2).
g(18, 12, 13).
g(19, 13, 14).
g(20, 14, 2).
g(21, 14, 15).

#const start = 1.
#const end = 15.

edges(1..21).
ix(1..21).

% ensure that the index is unique
{ selected(Ix, Edge) : edges(Edge) } 1 :- ix(Ix).
% ensure that we visit an edge atmost once
{ selected(Ix, Edge) : ix(Ix) } 1 :- edges(Edge).

% define adjacency and add the Edge to selected
adj(X, Y, I) :- g(Edge, X, Y), selected(I, Edge).
adj(X, Y, I) :- g(Edge, X, Z), adj(Z, Y, I+1), selected(I, Edge).

% init the problem: from start to end 
% with index 1)
:- not adj(start, end, 1).

% Here we check which nodes was involved
% in the edges.
selected_nodes(Ix, X, Y) :- selected(Ix, Edge), g(Edge, X, Y).

% minimize the number of edges
#minimize [ selected(Ix, Edge) : edges(Edge) : ix(Ix) ].

#hide.
#show selected(Ix, Edge).
#show selected_nodes(Ix, X, Y).