%%%-------------------------------------------------------------------
%% @doc ddb_connection top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(ddb_connection_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(POOL, backend_connection).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, {Host, Port}} = application:get_env(ddb_connection, backend),
    {ok, PoolSize} = application:get_env(ddb_connection, pool_size),
    {ok, PoolMax} = application:get_env(ddb_connection, pool_max),
    SizeArgs = [
                {size, PoolSize},
                {max_overflow, PoolMax}
               ],
    PoolArgs = [{name, {local, ?POOL}},
                {worker_module, ddb_connection}] ++ SizeArgs,
    WorkerArgs = [Host, Port],
    {ok, {{one_for_one, 5, 10},
          [poolboy:child_spec(?POOL, PoolArgs, WorkerArgs)]}}.
