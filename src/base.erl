%% @author amkane
%% @doc @todo Add description to base.


-module(base). 
-author('Amadou KANE'). 
-export([start/1, accueil/1]).
%% ====================================================================
%% API functions
%% ====================================================================
start(Port) ->
    controleur:start(),
    serveur_tcp:start(?MODULE, Port, {?MODULE, accueil}).

accueil(Socket) ->
    gen_tcp:send(Socket, "\n********BIENVENU DANS MiNiMaL CHaT*******\n***********************************************\n"),
    gen_tcp:send(Socket, "TAPER: CHAT, POUR DEMMARER!\n"),
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
            io:format("Data: ~p~n", [binary_to_list(Data)]),
            MessageDeDemmarage = binary_to_list(Data),           
            case MessageDeDemmarage of
                "CHAT" ->
                    try_connection(pick_nickname(), Socket);
                _ ->
                    gen_tcp:send(Socket, "VOUS DEVEZ SAISIR: CHAT, POUR DEMMARER!\n"),
                    ok
            end;
        {error, closed} ->
            ok
    end.



%% ====================================================================
%% Internal functions
%% ====================================================================


% 
%Attend les connexions entrantes pour lancer base:loop/1
%
try_connection(Nick, Socket) ->
    Response = gen_server:call(controller, {connect, Nick, Socket}),
    case Response of
        {ok, List, NouveauMessages} ->
            gen_tcp:send(Socket, "VOUS AVEZ REJOINT LE CHAT AVEC SUCCES :" ++ List ++ "\n"),
            %affiche les messages éhangé
            gen_tcp:send(Socket, "-------------------ICI LES MESSAGES ECHANGES-------------------------\n" ++ NouveauMessages ++ "\n"),
            gen_server:cast(controller, {join, Nick}),
            loop(Nick, Socket);
        nick_in_use ->
            gen_tcp:send(Socket, "CONNECT:ERROR:NOM DEJA PRIS.\n"),
            ok
    end.


loop(Nick, Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
            io:format("Data: ~p~n", [binary_to_list(Data)]),
            Message = binary_to_list(Data),
            {Command, [_|Content]} = lists:splitwith(fun(T) -> [T] =/= ":" end, Message),
            case Command of
                "SAY" ->
                    say(Nick, Socket, clean(Content));                
                "QUIT" ->
                    quit(Nick, Socket)
            end;
        {error, closed} ->
            ok
    end.  

say(Nick, Socket, Content) ->
    gen_server:cast(controller, {say, Nick, Content}),
    loop(Nick, Socket).

quit(Nick, Socket) ->
    Response = gen_server:call(controller, {disconnect, Nick}),
    case Response of
        ok ->
            gen_tcp:send(Socket, "--------------------Bye!------------------\n"),
            gen_server:cast(controller, {left, Nick}),
            ok;
        user_not_found ->
            gen_tcp:send(Socket, "---------------------Error, Bye!-----------\n"),
            ok
    end.

pick_nickname() ->
lists:nth(random:uniform(12), firstnames())
++ " " ++
lists:nth(random:uniform(12), lastnames()).
 
firstnames() ->
["Amadou", "Salif", "Valerie", "Arnold", "Carlos", "Dorothy", "Keesha",
"Phoebe", "Ralphie", "Tim", "Wanda", "Janet"].
 
lastnames() ->
["Kane", "Ba", "Frizzle", "Perlstein", "Ramon", "Ann", "Franklin",
"Terese", "Tennelli", "Jamal", "Li", "Perlstein"].


clean(Data) ->
    string:strip(Data, both, $\n).

