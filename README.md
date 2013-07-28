Disco Local Cluster
===================

How to
------

    $ export PATH=$PATH:/usr/sbin #whereis lighttpd, if not in the path
    
    $ export DISCO_MASTER_HOME=/home/to/disco/master #for the erl command below and for disco
    
    $ pkill lighttpd #if proxy cannot be started because of address already in use from previous run
    
    $ erl -pa $DISCO_MASTER_HOME/ebin $DISCO_MASTER_HOME/ebin/ddfs $DISCO_MASTER_HOME/deps/lager/ebin $DISCO_MASTER_HOME/deps/mochiweb/ebin -sname disco_8989_master #:-)
    
    (disco_8989_master@doe)1> c(dlc).
    
    (disco_8989_master@doe)2> dlc:go().
    
    (disco_8989_master@doe)3> BL = dlc:add_a_new_blob("hey", "been trying to meet you").
    
    (disco_8989_master@doe)4> dlc:add_blobs_to_a_tag(BL, "pixies").
    
    (disco_8989_master@doe)5> dlc:gc().
    
    $ cd dlc/ddfs/
    
    $ tree
    .
    |-- jedi01
    |   `-- vol0
    |       |-- blob
    |       `-- tag
    |-- jedi02
    |   `-- vol0
    |       |-- blob
    |       `-- tag
    |-- jedi03
    |   `-- vol0
    |       |-- blob
    |       `-- tag
    |           `-- 93
    |               `-- pixies$55f-35f7-1acbd
    |-- jedi04
    |   `-- vol0
    |       |-- blob
    |       |   `-- c7
    |       |       `-- hey$55f-3546-18049
    |       `-- tag
    |-- jedi05
    |   `-- vol0
    |       |-- blob
    |       `-- tag
    |           `-- 93
    |               `-- pixies$55f-35f7-1acbd
    |-- jedi06
    |   `-- vol0
    |       |-- blob
    |       `-- tag
    |           `-- 93
    |               `-- pixies$55f-35f7-1acbd
    |-- jedi07
    |   `-- vol0
    |       |-- blob
    |       |   `-- c7
    |       |       `-- hey$55f-3546-18049
    |       `-- tag
    `-- jedi08
        `-- vol0
            |-- blob
            |   `-- c7
            |       `-- hey$55f-3546-18049
            `-- tag

    38 directories, 6 files
