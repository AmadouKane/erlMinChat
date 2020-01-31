%% @author amkane
%% @doc @todo Add description to base.


-module(base). 
-author('Amadou KANE'). 

%% ====================================================================
%% API functions
%% ====================================================================
-export([ecoute/1]). 

-define(OPTIONS_TCP, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]). 

% Pour démarrer le service appeler la fonction base:ecoute(Port)
ecoute(Port) ->
	{ok, LSocket} = gen_tcp:listen(Port, ?OPTIONS_TCP),
	accept(LSocket). 





%% ====================================================================
%% Internal functions
%% ====================================================================


% 
%Attend les connexions entrantes pour lancer base:loop/1
%
accept(LSocket) ->
	{ok, Socket} = gen_tcp:accept(LSocket),
	spawn(fun() -> loop(Socket) end),
	accept(LSocket). 

%
% Affiche les informations saisies
%
loop(Socket) ->
	%reception ds données de la socket
	case gen_tcp:recv(Socket, 0) of
		{ok, Data} ->
			%affichage
			gen_tcp:send(Socket, Data),
			loop(Socket);
		{error, closed} ->
			ok
	end. 


