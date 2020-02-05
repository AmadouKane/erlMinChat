%% @author amkane
%% @doc @todo Add description to controleur.


-module(controleur).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/0]).

start() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


%% ====================================================================
%% API functions
%% ====================================================================
% Appeler apres une connection sur le serveur
init([]) ->
    Users = dict:new(), % Map le nom à la socket
    Messages = dict:new(),
    {ok, Users, Messages}.



%% ====================================================================
%% Internal functions
%% ====================================================================


