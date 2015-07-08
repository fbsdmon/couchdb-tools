#!/bin/bash
couchdbToolsInfo() {
cat << EOF
################################################################################
#
#   couchdb-tools.sh v1.14
#
# A bash library for handling CouchDB from the command line
#
#
#                                       Perica Veljanovski, February 2014
#                                       fBSDmon@gmail.com
#
################################################################################
EOF
}

# Text color & formating
#
# usage: ${r}this text is red ${X}this text has no formatting
b=$(tput setaf 0)    # Black
r=$(tput setaf 1)    # Red
g=$(tput setaf 2)    # Green
y=$(tput setaf 3)    # Yellow
m=$(tput setaf 5)    # Magenta
c=$(tput setaf 6)    # Cyan
w=$(tput setaf 7)    # White
B=$(tput bold)       # Bold
D=$(tput dim)        # Half-bright/Dim
U=$(tput smul)       # Underline
S=$(tput smso)       # Standout
X=$(tput sgr0)       # Text reset

# Returns a CouchDB connection string used by all other functions
#
# usage: couchConnect [host=<hostname|ip_addr>] [port=<port_number>] [user=<user_name>] [pass=<password>] [protocol=<http|https>]
couchConnect() {
    for _param in "$@"; do
        case "${_param%%=*}" in
            'host') local _couchdb_host="${_param##*=}";;
            'port') local _couchdb_port="${_param##*=}";;
            'user') local _couchdb_user="${_param##*=}";;
            'pass') local _couchdb_pass="${_param##*=}";;
            'protocol') local _couchdb_protocol="${_param##*=}";;
            '-h'|'--help') echo "usage: couchConnect [host=<hostname|ip_addr>] [port=<port_number>] [user=<user_name>] [pass=<password>] [protocol=<http|https>]"; return 0;;
        esac;
    done;
    # set defaults if empty
    local _couchdb_host=${_couchdb_host:-localhost};
    local _couchdb_port=${_couchdb_port:-5984};
    local _couchdb_user=${_couchdb_user:-$(whoami)};
    local _couchdb_protocol=${_couchdb_protocol:-http};
    # coing the connection string
    local _couchdb_conn="$_couchdb_protocol://$_couchdb_user"
    [ -n "$_couchdb_pass" ] && _couchdb_conn="$_couchdb_conn:$_couchdb_pass";
    _couchdb_conn="$_couchdb_conn@$_couchdb_host:$_couchdb_port"
    # unset variables so they don't interfire with other functions
    unset _couchdb_host;
    unset _couchdb_port;
    unset _couchdb_user;
    unset _couchdb_pass;
    unset _couchdb_protocol;
    # return the connection string
    echo $_couchdb_conn;
    unset _couchdb_conn;
}


# Check CouchDB output for errors
#
# usage: errCheck <exit status> <output>
errCheck() {
    if [ "$1" == "-h" ]; then
        echo "Check CouchDB output for errors";
        echo "usage: errCheck <exit status> <output>";
        return 5;
    else
        local _status=$1;
        shift 1;
        local _res="$@";
        #[ $_status -ne 0 ] && { echo "${r}ERROR[${X}$_status${r}]:${X} $_res"; return $_status; } || return 0;
        # handle general (curl) error
        if [ $_status -ne 0 ]; then
            echo "${r}ERROR[${X}$_status${r}]:${X} $_res";
            return $_status;
        # handle couchdb errors as warrnign
        elif [ -z "${_res##{\"error\":*}" ]; then
            echo "${r}ERROR[${X}1${r}]:${X} $_res";
            return 1;
        # handle couchdb success message
        #elif [ -z "${_res##{\"ok\":*}" ]; then
            #echo "[${g}OK${X}]: $_res";
            #return 0;
        else
            return 0;
        fi;
    fi;
}

# Get a list of databases
#
# usage: getDBs <couchConnect>
getDBs () {
    if [ $# -ne 1 ] || [ "$1" == "-h" ]; then
        echo "Get a list of databases";
        echo "usage: getDBs <couchConnect>";
        return 5;
    else
        local _couchdb_conn=$1;
        #echo $(curl -sS --connect-timeout 3 -X GET --insecure $_couchdb_conn/_all_dbs | tr -d '[]"' | sed -e 's/,/ /g')
        _res=$(curl -sS -X GET --insecure $_couchdb_conn/_all_dbs 2>&1);
        errCheck $? "$_res"
        [ "$?" -eq 0 ] && echo $(echo "$_res" | tr -d '[]"' | sed -e 's/,/ /g');
    fi;
}

# Get a list of documents in a database
#
# usage: getDocs <couchConnect> <database>
getDocs() {
    if [ $# -ne 2 ] || [ "$1" == "-h" ]; then
        echo "Get a list of documents in a database";
        echo "usage: getDocs <couchConnect> <database>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        _res=$(curl -sS -X GET --insecure $_couchdb_conn/$_couchdb_db/_all_docs 2>&1);
        errCheck $? "$_res";
        [ "$?" -eq 0 ] && echo $(echo "$_res" | tr "," "\n" | grep -e "\"id\":" | sed -e 's/.*:\"\(.*\)\".*/\1/g');
    fi;
}

# Get a list of documents with document revisions from a database
#
# usage: getDocsWithRevisions <couchConnect> <database>
getDocsWithRevisions() {
    if [ $# -ne 2 ] || [ "$1" == "-h" ]; then
        echo "Get a list of documents with document revisions form a database";
        echo "usage: getDocsWithRevisions <couchConnect> <database>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        _res=$(curl -sS -X GET --insecure $_couchdb_conn/$_couchdb_db/_all_docs 2>&1);
        errCheck $? "$_res";
        [ "$?" -eq 0 ] && echo "$_res" | grep -e "\"id\":" | sed -e 's/.*\"id\":\"\(.*\)\",\"key\":.*\"rev\":\"\(.*\)\".*/\1 \2/g'
    fi;
}

# Get a list of deleted documents in a database
#
# usage: getDeletedDocs <couchConnect> <database>
getDeletedDocs() {
    if [ $# -ne 2 ] || [ "$1" == "-h" ]; then
        echo "Get a list of deleted documents in a database";
        echo "usage: getDeletedDocs <couchConnect> <database>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        _res=$(curl -sS -X GET --insecure $_couchdb_conn/$_couchdb_db/_changes 2>&1);
        errCheck $? "$_res";
        [ "$?" -eq 0 ] && echo $(echo "$_res" | grep -v '^{"total_rows"' | tr -d '[{}]' | grep deleted | awk -v RS=',' -F: '/"id"/ {print $2}' | tr -d '"');
    fi;
}

# Get/download a document
#
# usage: getDoc <couchConnect> <database> <document>
getDoc() {
    if [ $# -ne 3 ] || [ "$1" == "-h" ]; then
        echo "Get (download) a document";
        echo "usage: getDoc <couchConnect> <database> <document>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        local _couchdb_doc=$3;
        _res=$(curl -sS -X GET --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc 2>&1);
        errCheck $? "$_res";
        [ "$?" -eq 0 ] && echo "$_res";
    fi;
}

# Get/download a document with attachments
#
# usage: getDoc <couchConnect> <database> <document>
getDocWithAttachment() {
    if [ $# -ne 3 ] || [ "$1" == "-h" ]; then
        echo "Get (download) a document with attachments";
        echo "usage: getDoc <couchConnect> <database> <document>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        local _couchdb_doc=$3;
        _res=$(curl -sS -X GET --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc?attachments=true 2>&1);
        errCheck $? "$_res";
        [ "$?" -eq 0 ] && echo "$_res";
    fi;
}

# Get a docummnet's revision
#
# usage: getRevision <couchConnect> <database> <document>
getRevision() {
    if [ $# -ne 3 ] || [ "$1" == "-h" ]; then
        echo "Get a docummnet's revision";
        echo "usage: getRevision <couchConnect> <database> <document>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        local _couchdb_doc=$3;
        #_res=$(curl -sS -X GET --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc 2>&1);
        #errCheck $? "$_res";
        #[ "$?" -eq 0 ] && echo $(echo "$_res" | tr -d '[{}]' | awk -v RS=',' -F: '/"_rev"/ {print $2}'|tr -d '"'|grep -v '^$');
        getDocsWithRevisions $_couchdb_conn $_couchdb_db | grep -e "^$_couchdb_doc " | cut -d" " -f2;
    fi;
}

# Get the revision number from the revision string
#
# usage: getRevisionNumber <revision>
getRevisionNumber() {
    if [ $# -ne 1 ] || [ "$1" == "-h" ]; then
        echo "Get the revision number from the revision string";
        echo "usage: getRevisionNumber <revision>";
        return 5;
    else
        local _var=$1
        echo ${_var%%-*};
    fi;
}

# Get the revision hash from the revision string
#
# usage: getRevisionHash <revision>
getRevisionHash() {
    if [ $# -ne 1 ] || [ "$1" == "-h" ]; then
        echo "Get the revision hash from the revision string";
        echo "usage: getRevisionHash <revision>";
        return 5;
    else
        local _var=$1;
        echo ${_var##*-};
    fi;
}

# Get a list of attachments for a document
#
# usage: getAttachments <couchConnect> <database> <document>
getAttachments() {
    if [ $# -ne 3 ] || [ "$1" == "-h" ]; then
        echo "Get a list of attachments for a document";
        echo "usage: getAttachments <couchConnect> <database> <document>"
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        local _couchdb_doc=$3;
        _doc=$(curl -sS -X GET --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc 2>&1);
        errCheck $? "$_doc";
        [[ $_doc == *_attachments* ]] && echo $(echo $_doc | sed -e 's/.*_attachments\":{\(.*\)}.*/\1/g' | tr "{}" "\n" | grep -e ":$" | sed -e 's/[,\":]//g');
    fi;
}

# Get (download) attachment for a document
#
# usage: getAttachment <couchConnect> <database> <document> <attachment>
getAttachment() {
    if [ $# -ne 4 ] || [ "$1" == "-h" ]; then
        echo "Get (download) attachment for a document";
        echo "usage: getAttachment <couchConnect> <database> <document> <attachment>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        local _couchdb_doc=$3;
        local _couchdb_attachment=$4;
        _res=$(curl -sS -X GET --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc/$_couchdb_attachment 2>&1);
        errCheck $? "$_res";
        [ "$?" -eq 0 ] && echo "$_res";
    fi;
}

# Delete a database
#
# usage: delDB <couchConnect> <database>
delDB() {
    if [ $# -ne 2 ] || [ "$1" == "-h" ]; then
        echo "Dlete a database";
        echo "usage: delDB <couchConnect> <database>"
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        _res=$(curl -sS -X DELETE --insecure $_couchdb_conn/$_couchdb_db 2>&1);
        errCheck $? "$_res";
    fi;
}

# Create a database
#
# usage: createDB <couchConnect> <database>
createDB() {
    if [ $# -ne 2 ] || [ "$1" == "-h" ]; then
        echo "Create a database";
        echo "usage: createDB <couchConnect> <database>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        _res=$(curl -sS -X PUT --insecure $_couchdb_conn/$_couchdb_db 2>&1);
        errCheck $? "$_res";
    fi;
}

# Delete a document
#
# usage: delDoc <couchConnect> <database> <document> [<revision>]
delDoc() {
    if [ $# -ne 3 -a $# -ne 4 ] || [ "$1" == "-h" ]; then
        echo "Delete a document";
        echo "usage: delDoc <couchConnect> <database> <document> [<revision>]"
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        local _couchdb_doc=$3;
        [ -z $4 ] && local _couchdb_doc_rev=$(getRevision $_couchdb_conn $_couchdb_db $_couchdb_doc) || _couchdb_doc_rev=$4;
        _res=$(curl -sS -X DELETE --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc?rev=$_couchdb_doc_rev 2>&1);
        errCheck $? "$_res";
    fi;
}

# Delete an attachment from document
#
# usage: delAttachment <couchConnect> <database> <document> <attachment> [<revision>]
delAttachment() {
     if [ $# -ne 4 -a $# -ne 5 ] || [ "$1" == "-h" ]; then
        echo "Delete an attachment from document";
        echo "usage: delAttachment <couchConnect> <database> <document> <attachment> [<revision>]";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        local _couchdb_doc=$3;
        local _couchdb_doc_att=$4;
        # couch always returns 0 for deleting a document, so we must check if the documents exists before deleting
        _attachments=$(getAttachments $_couchdb_conn $_couchdb_db $_couchdb_doc);
        if [[ $_attachments =~ (^|[[:space:]])"$_couchdb_doc_att"($|[[:space:]]) ]]; then
            [ -z $5 ] && local _couchdb_doc_rev=$(getRevision $_couchdb_conn $_couchdb_db $_couchdb_doc) || _couchdb_doc_rev=$5;
            _res=$(curl -sS -X DELETE --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc/$_couchdb_doc_att?rev=$_couchdb_doc_rev 2>&1);
            errCheck $? "$_res";
        else
            echo "${r}ERROR[${X}$?${r}]:${X} Attachment /$_couchdb_db/$_couchdb_doc/$_couchdb_doc_att does not exist! "
        fi;
    fi;
}

# Create/update a document
#
# usage: putDoc <couchConnect> <database> [<document>] <@file|'{json}'>
putDoc() {
    if [ $# -ne 3 -a $# -ne 4 ] || [ "$1" == "-h" ]; then
        echo "Create/update a document";
        echo "usage: putDoc <couchConnect> <database> [<document>] <@file|'{json}'>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        if [ $# -eq 4 ]; then
            local _couchdb_doc=$3;
            local _couchdb_doc_json=$4;
            [[ "$_couchdb_doc_json" != @* ]] || [ -f ${_couchdb_doc_json#@} ] || { echo "${r}ERROR[${X}$?${r}]:${X} File does not exist: $_couchdb_doc_json"; return 1; };
            _res=$(curl -sS -X PUT --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc -d $_couchdb_doc_json 2>&1);
            errCheck $? "$_res";
        else
            _couchdb_doc_json=$3
            if [[ "$3" == @* ]]; then
                local _couchdb_doc_json=${_couchdb_doc_json#@}
                [ -f $_couchdb_doc_json ] && _couchdb_doc_json=$(cat $_couchdb_doc_json) || { echo "${r}ERROR[${X}$?${r}]:${X} File does not exist: $_couchdb_doc_json"; return 1; };
            else
                local _couchdb_doc_json=$3;
            fi;
            _res=$(curl -sS -X POST --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc -H "Content-Type: application/json" -d $_couchdb_doc_json 2>&1);
            errCheck $? "$_res";
        fi
    fi;
}

# Create/update attachment
#
# usage: putAttachment <couchConnect> <database> <document> [<attachment name>] <file>
putAttachment() {
    if [ $# -ne 4 -a $# -ne 5 ] || [ "$1" == "-h" ]; then
        echo "Create/update attachment";
        echo "usage: putAttachment <couchConnect> <database> <document> [<attachment name>] <file>";
        return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        local _couchdb_doc=$3;
        if [ $# -eq 4 ]; then
            local _couchdb_att_name=$4;
            local _couchdb_att=$4;
        else
            local _couchdb_att_name=$4;
            local _couchdb_att=$5;
        fi
        if [ -f $_couchdb_att ]; then
            _couchdb_doc_rev=$(getRevision $_couchdb_conn $_couchdb_db $_couchdb_doc);
            _res=$(curl -sS -X PUT --insecure $_couchdb_conn/$_couchdb_db/$_couchdb_doc/$_couchdb_att_name?rev=$_couchdb_doc_rev --data-binary @$_couchdb_att 2>&1);
            errCheck $? "$_res";
        else
            echo "${r}ERROR[${X}$?${r}]:${X} File does not exist: $_couchdb_att";
            return 1;
        fi
    fi;
}

# Check if the input value contains the BOM character
#
# usage: bomCheck <input>
bomCheck() {
    if [ "$1" == "-h" ]; then
        echo "Check if the input value contains the BOM character";
        echo "usage: bomCheck <input>";
        return 5;
    else
        $(echo "$@" | grep -q -e '\xEF\xBB\xBF' && return 1 || return 0)
    fi;
}

# Format Json output to make it look nice
#
# usage: pipe output to formatJson function
formatJson() {
    if [ "$1" == "-h" ]; then
        echo "Format Json output to make it look nice";
        echo "usage: pipe output to formatJson function";
    else
        read _var
        echo $_var| python -mjson.tool
    fi;
}

# Compare two CouchDB revision numbers
# Legend:
#   - Missing
#   = Equal
#   > Larger Then
#   < Smaller Then
#   ! Hash Mismatch
#
# usage: compareRevisions <revision> <revision>
compareRevisions() {
    if [ $# -ne 1 -a $# -ne 2 ] || [ "$1" == "-h" ]; then
        echo "Compare two CouchDB revision numbers";
        echo "Legend:";
        echo "   - Missing";
        echo "   = Equal";
        echo "   > Larger Then";
        echo "   < Smaller Then";
        echo "   ! Hash Mismatch";
        echo "usage: compareRevisions <revision> <revision>";
        return 5;
    else
        local _rev1=$1;
        local _rev2=$2;
        if [ -z $_rev2 ]; then
            echo "-";
        else
            if [ "$_rev1" == "$_rev2" ]; then
                echo "=";
            else
                local _rev1_num=$(getRevisionNumber $_rev1);
                local _rev2_num=$(getRevisionNumber $_rev2);
                local _rev1_hash=$(getRevisionHash $_rev1);
                local _rev2_hash=$(getRevisionHash $_rev2);
                if [ $_rev1_num -gt $_rev2_num ]; then
                    echo ">";
                elif [ $_rev1_num -lt $_rev2_num ]; then
                    echo "<"
                elif [ "$_rev1_has" != "$_rev2_hash" ]; then
                    echo "!"
                fi;
            fi;
        fi;
    fi;
}

# Download a CouchDB database to local disk
#
# usage: downloadDB <couchConnect> <database> [</path/to/download/dir>]
downloadDB() {
    if [ $# -ne 2 -a $# -ne 3 ] || [ "$1" == "-h" ]; then
        echo "Download a CouchDB database to local disk";
        echo "usage: downloadDB <couchConnect> <database> [</path/to/download/dir>]";
    return 5;
    else
        local _couchdb_conn=$1;
        local _couchdb_db=$2;
        # download db in current dir by default
        [ -n "$3" ] && local _target_dir=${3%/} || local _target_dir=.;
        mkdir -p $_target_dir/$_couchdb_db;
        local _couchdb_doc;
        local _couchdb_att;
        # format progress
        _format="%-16s %-30s %-38s %-38s\n"
        echo "==================================================================================================================================";
        printf "$_format" "DATABASE" "DOCUMENT" "ATTACHMENT" "LOCATION";
        echo "==================================================================================================================================";
        # download documents
        for _couchdb_doc in $(getDocs $_couchdb_conn $_couchdb_db); do
            # handle documents with forward slash "/" in the name
            if [[ $_couchdb_doc == */* ]]; then
                local _doc_dir=${_couchdb_doc%/*};
                _doc_dir=${_doc_dir#/};
                mkdir -p $_target_dir/$_couchdb_db/$_doc_dir;
            fi;
            printf "$_format" "$_couchdb_db" "$_couchdb_doc" " " "$_target_dir/$_couchdb_db/$_couchdb_doc.json"
            getDoc $_couchdb_conn $_couchdb_db "$_couchdb_doc" > $_target_dir/$_couchdb_db/$_couchdb_doc.json;
            # download attachments
            for _couchdb_att in $(getAttachments $_couchdb_conn $_couchdb_db "$_couchdb_doc"); do
                # handle attachments with forward slash "/" in the name
                if [[ $_couchdb_att == */* ]]; then
                    local _att_dir=${_couchdb_att%/*};
                    _att_dir=${_att_dir#/};
                    mkdir -p $_target_dir/$_couchdb_db/$_couchdb_doc/$_att_dir;
                else
                    mkdir -p $_target_dir/$_couchdb_db/$_couchdb_doc;
                fi;
                printf "$_format" "$_couchdb_db" "$_couchdb_doc" "$_couchdb_att" "$_target_dir/$_couchdb_db/$_couchdb_doc/$_couchdb_att"
                getAttachment $_couchdb_conn $_couchdb_db $_couchdb_doc $_couchdb_att > $_target_dir/$_couchdb_db/$_couchdb_doc/$_couchdb_att;
            done;
        done;
    fi;
}

# Creates documentation from the couchdb-tools.sh description/comments
#
# usage: couchdbToolsDocumentation <couchdb-tools library>
couchdbToolsDocumentation() {
    _couchdb_lib=$(which couchdb-tools.sh);
    [ -z "$_couchdb_lib" ] && _couchdb_lib="$1"
    if [ "$1" == "-h" ] || [ -z "$_couchdb_lib" ]; then
        echo "Create documentation for CouchDB Tools";
        echo "usage: createDocumentation <couchdb-tools library>";
    else
        [ -f "$_couchdb_lib" ] || { echo "CouchDB library file not found: $_couchdb_lib"; return 1; }
        couchdbToolsInfo;
        local _functions=$(cat $_couchdb_lib | grep -e ".*()[[:space:]]*{$" | grep -v "couchdbToolsInfo" | sed -e 's/\(.*\)()[[:space:]]*{.*/\1/g');
        local _function;
        for _function in $_functions; do
            echo "Function:    ${y}$_function${X}"
            echo -n "Description: "
            $_function -h;
            echo
        done;
    fi;
}

################################################################################
