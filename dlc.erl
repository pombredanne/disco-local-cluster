-module(dlc).

-export([go/0]).
-export([add_a_new_blob/2, add_blobs_to_a_tag/2, delete_tag/1]).
-export([gc/0]).

go() ->
    setup_environment(),
    inets:start(),
    start_disco().

add_a_new_blob(BlobPrefix, BlobContent) ->
    A = new_blob(BlobPrefix),
    B = push_blob(A, BlobContent),
    B.

add_blobs_to_a_tag(Blobs, Tag) ->
    add_tag(Blobs, Tag).

delete_tag(Tag) ->
    {ok, {_, _, _Res}} = httpc:request(delete, {"http://localhost:8900/ddfs/tag/" ++ Tag, []}, [], []).

start_disco() ->
    application:start(disco).

setup_environment() ->
    {ok, Cwd} = file:get_cwd(),
    RootDir = Cwd ++ "/dlc",
    filelib:ensure_dir(RootDir ++ "/run/"),
    filelib:ensure_dir(RootDir ++ "/ddfs/"),
    filelib:ensure_dir(RootDir ++ "/data/"),
    filelib:ensure_dir(RootDir ++ "/log/"),
    file:write_file(RootDir ++ "/disco_8989.config", "{\"hosts\":[[\"jedi01:08\",\"2\"]],\"blacklist\":[],\"gc_blacklist\":[]}"),
    os:putenv("DISCO_MASTER_PID", RootDir ++ "/run/Master-ada_8989.pid"),
    os:putenv("DISCO_PORT", "8989"),
    os:putenv("DISCO_PROXY_ENABLED", "on"),
    os:putenv("DISCO_PROXY_PID", RootDir ++ "/disco_8989-proxy.pid"),
    os:putenv("DDFS_PUT_PORT", "8990"),
    os:putenv("DDFS_DATA", RootDir ++ "/ddfs"),
    os:putenv("DISCO_MASTER_CONFIG", RootDir ++ "/disco_8989.config"),
    os:putenv("DDFS_TAG_MIN_REPLICAS", "3"),
    os:putenv("DISCO_NAME", "disco_8989"),
    os:putenv("DISCO_HTTPD", "lighttpd -f $DISCO_PROXY_CONFIG"),
    os:putenv("DISCO_PROXY_PORT", "8900"),
    os:putenv("DISCO_LOCAL_CLUSTER", "1"),
    os:putenv("DISCO_PROXY_CONFIG", RootDir ++ "/disco_8989-proxy.conf"),
    os:putenv("DDFS_DATA", RootDir ++ "/ddfs"),
    os:putenv("DISCO_DATA", RootDir ++ "/data"),
    os:putenv("DISCO_LOG_DIR", RootDir ++ "/log"),
    os:putenv("DISCO_PID_DIR", RootDir ++ "/run"),
    os:putenv("DISCO_SETTINGS", "DISCO_PROXY,DISCO_DEBUG,DISCO_MASTER_ROOT,DDFS_PUT_MAX,DISCO_TEST_PURGE,DISCO_PORT,DISCO_JOB_OWNER,DISCO_PROXY_PID,DISCO_TEST_HOST,DISCO_TEST_DISCODB,DISCO_NAME,DDFS_PARANOID_DELETE,DISCO_PROXY_PORT,DDFS_WRITE_TOKEN,DISCO_TEST_PORT,DISCO_MASTER_HOME,DDFS_BLOB_REPLICAS,DDFS_PUT_PORT,DISCO_ERLANG,DDFS_GC_INITIAL_WAIT,DISCO_ROOT,DDFS_READ_TOKEN,DISCO_DATA,DISCO_USER,DISCO_SCHEDULER_ALPHA,DDFS_GET_MAX,DISCO_ROTATE_LOG,DISCO_FLAGS,DISCO_PROXY_ENABLED,DISCO_LOG_DIR,DDFS_TAG_MIN_REPLICAS,DISCO_SCHEDULER,DDFS_TAG_REPLICAS,DISCO_HTTPD,DISCO_EVENTS,DISCO_SETTINGS_FILE,DISCO_MASTER_HOST,DISCO_PID_DIR,DISCO_PROXY_CONFIG,DISCO_WWW_ROOT,DDFS_ROOT,DISCO_TEST_PROFILE,DDFS_DATA,DISCO_MASTER,DISCO_HOME,DISCO_WORKER_MAX_MEM,DISCO_GC_AFTER,DISCO_ULIMIT,DISCO_MASTER_CONFIG,DISCO_SETTINGS"),
    os:putenv("DISCO_ERLANG", "erl"),
    os:putenv("DDFS_GC_INITIAL_WAIT", "1024"),
    os:putenv("DDFS_TAG_REPLICAS", "3"),
    os:putenv("DDFS_BLOB_REPLICAS", "3").

new_blob(Blob) ->
    {ok, {_, _, Res}} = httpc:request("http://localhost:8900/ddfs/new_blob/" ++ Blob),
    L = mochijson2:decode(Res),
    L2 = [{binary_to_list(E), re:run(binary_to_list(E), "http\\://(.*)\\:.*/ddfs/(.*)", [{capture, all_but_first}])} || E <- L],
    [{string:substr(Host, A+1, B), string:substr(Host, C+1, D)} || {Host, {match, [{A, B}, {C, D}]}} <- L2].

push_blob(Where, What) ->
    L = lists:foldl(fun({A, B}, Acc) ->
                            R = httpc:request(put, {"http://localhost:8900/proxy/" ++ A ++ "/PUT/ddfs/" ++ B,
                                                    [], "application/x-www-form-urlencoded", What}, [], []),
                            [R | Acc]
                    end, [], Where),
    [binary_to_list(mochijson2:decode(Res)) || {ok, {_, _, Res}} <- L].

add_tag(List, Tag) ->
    {ok, {_, _, Res}} = httpc:request(post, {"http://localhost:8900/ddfs/tag/" ++ Tag, [], "", "[[\"" ++ string:join(List, "\", \"") ++ "\"]]"}, [], []),
    L = mochijson2:decode(Res),
    [binary_to_list(E) || E <- L].

gc() ->
    {ok, Pid} = ddfs_gc_main:start_link(disco:get_setting("DDFS_DATA"), ets:new(some_ets_table, [])),
    unlink(Pid),
    Pid.
