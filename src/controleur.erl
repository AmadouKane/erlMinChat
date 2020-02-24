%% @author amkane
%% @doc @todo Add description to controleur.


-module(controleur).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/0]).

%% ====================================================================
%% API functions
%% ====================================================================
% Appeler apres une connection sur le serveur
start() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

% Appeler apres une connection sur le serveur
init([]) ->
    Users = dict:new(), % Map le nom à la socket
    Tous_les_messages = dict:new(),
    {ok, {Users, Tous_les_messages}}.

% handle_call is invoked in response to gen_server:call
handle_call({connect, Nick, Socket}, _From, {Users, Tous_les_messages}) ->
    Response = case dict:is_key(Nick, Users) of
        true ->
            NewUsers = Users,
            nick_in_use;
        false ->
            NewUsers = dict:append(Nick, Socket, Users),
            {ok, user_list(NewUsers)}
    end,
    {reply, Response, NewUsers};



handle_call({disconnect, Nick}, _From, {Users, Tous_les_messages}) ->
    Response = case dict:is_key(Nick, Users) of
        true ->
            NewUsers = dict:erase(Nick, Users),
            ok;
        false ->
            NewUsers = Users,
            user_not_found
    end,
    {reply, Response, NewUsers};

handle_call(_Message, _From, State) ->
    {reply, error, State}.


% handle_cast is invoked in response to gen_server:cast
handle_cast({say, Nick, Tous_les_messages}, {Users, Tous_les_messages}) ->
    broadcast(Nick, "DIT:" ++ Nick ++ ":" ++ Tous_les_messages ++ "\n", Users),
    %Rassembler les messages
    Nouveau_message = dict:append(Nick, " Dit: ", Tous_les_messages),
    {noreply, {Users, message_liste(Nouveau_message)}};


handle_cast({join, Nick}, {Users, Tous_les_messages}) ->
    broadcast(Nick, "JOIN:" ++ Nick ++ "\n", Users),
    {noreply, Users};

handle_cast({left, Nick}, {Users, Tous_les_messages}) ->
    broadcast(Nick, "LEFT:" ++ Nick ++ "\n", Users),
    {noreply, Users};

handle_cast(_Message, State) ->
    {noreply, State}.



%% ====================================================================
%% Internal functions
%% ====================================================================


% auxiliary functions
broadcast(Nick, Msg, Users) ->
    Sockets = lists:map(fun({_, [Value|_]}) -> Value end, dict:to_list(dict:erase(Nick, Users))),
    lists:foreach(fun(Sock) -> gen_tcp:send(Sock, Msg) end, Sockets).

user_list(Users) ->
    User_list = dict:fetch_keys(Users),
    string:join(User_list, ":").

message_liste(Message) ->
	Message_liste = dict:fetch_keys(Message),
	string:join(Message_liste, ":").

% Definitions to avoid gen_server compile warnings
handle_info(_Message, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVersion, State, _Extra) -> {ok, State}.
