################################################################################
#
#   couchdb-tools.sh v1.14
#
# A set of functions for handling CouchDB from the command line
#
#
#                                       Perica Veljanovski, February 2014
#                                       fBSDmon@gmail.com
#
################################################################################
Function:    [33mcouchConnect(B[m
Description: usage: couchConnect [host=<hostname|ip_addr>] [port=<port_number>] [user=<user_name>] [pass=<password>] [protocol=<http|https>]

Function:    [33merrCheck(B[m
Description: Check CouchDB output for errors
usage: errCheck <exit status> <output>

Function:    [33mgetDBs(B[m
Description: Get a list of databases
usage: getDBs <couchConnect>

Function:    [33mgetDocs(B[m
Description: Get a list of documents in a database
usage: getDocs <couchConnect> <database>

Function:    [33mgetDocsWithRevisions(B[m
Description: Get a list of documents with document revisions form a database
usage: getDocsWithRevisions <couchConnect> <database>

Function:    [33mgetDeletedDocs(B[m
Description: Get a list of deleted documents in a database
usage: getDeletedDocs <couchConnect> <database>

Function:    [33mgetDoc(B[m
Description: Get (download) a document
usage: getDoc <couchConnect> <database> <document>

Function:    [33mgetDocWithAttachment(B[m
Description: Get (download) a document with attachments
usage: getDoc <couchConnect> <database> <document>

Function:    [33mgetRevision(B[m
Description: Get a docummnet's revision
usage: getRevision <couchConnect> <database> <document>

Function:    [33mgetRevisionNumber(B[m
Description: Get the revision number from the revision string
usage: getRevisionNumber <revision>

Function:    [33mgetRevisionHash(B[m
Description: Get the revision hash from the revision string
usage: getRevisionHash <revision>

Function:    [33mgetAttachments(B[m
Description: Get a list of attachments for a document
usage: getAttachments <couchConnect> <database> <document>

Function:    [33mgetAttachment(B[m
Description: Get (download) attachment for a document
usage: getAttachment <couchConnect> <database> <document> <attachment>

Function:    [33mdelDB(B[m
Description: Dlete a database
usage: delDB <couchConnect> <database>

Function:    [33mcreateDB(B[m
Description: Create a database
usage: createDB <couchConnect> <database>

Function:    [33mdelDoc(B[m
Description: Delete a document
usage: delDoc <couchConnect> <database> <document> [<revision>]

Function:    [33mdelAttachment(B[m
Description: Delete an attachment from document
usage: delAttachment <couchConnect> <database> <document> <attachment> [<revision>]

Function:    [33mputDoc(B[m
Description: Create/update a document
usage: putDoc <couchConnect> <database> [<document>] <@file|'{json}'>

Function:    [33mputAttachment(B[m
Description: Create/update attachment
usage: putAttachment <couchConnect> <database> <document> [<attachment name>] <file>

Function:    [33mbomCheck(B[m
Description: Check if the input value contains the BOM character
usage: bomCheck <input>

Function:    [33mformatJson(B[m
Description: Format Json output to make it look nice
usage: pipe output to formatJson function

Function:    [33mcompareRevisions(B[m
Description: Compare two CouchDB revision numbers
Legend:
   - Missing
   = Equal
   > Larger Then
   < Smaller Then
   ! Hash Mismatch
usage: compareRevisions <revision> <revision>

Function:    [33mdownloadDB(B[m
Description: Download a CouchDB database to local disk
usage: downloadDB <couchConnect> <database> [</path/to/download/dir>]

Function:    [33mcouchdbToolsDocumentation(B[m
Description: Create documentation for CouchDB Tools
usage: createDocumentation <couchdb-tools library>

