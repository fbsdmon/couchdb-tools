A bash library for handling CouchDB from the command line

```
Function:    couchConnect
Description: usage: couchConnect [host=<hostname|ip_addr>] [port=<port_number>] [user=<user_name>] [pass=<password>] [protocol=<http|https>]

Function:    errCheck
Description: Check CouchDB output for errors
usage: errCheck <exit status> <output>

Function:    getDBs
Description: Get a list of databases
usage: getDBs <couchConnect>

Function:    getDocs
Description: Get a list of documents in a database
usage: getDocs <couchConnect> <database>

Function:    getDocsWithRevisions
Description: Get a list of documents with document revisions form a database
usage: getDocsWithRevisions <couchConnect> <database>

Function:    getDeletedDocs
Description: Get a list of deleted documents in a database
usage: getDeletedDocs <couchConnect> <database>

Function:    getDoc
Description: Get (download) a document
usage: getDoc <couchConnect> <database> <document>

Function:    getDocWithAttachment
Description: Get (download) a document with attachments
usage: getDoc <couchConnect> <database> <document>

Function:    getRevision
Description: Get a docummnet's revision
usage: getRevision <couchConnect> <database> <document>

Function:    getRevisionNumber
Description: Get the revision number from the revision string
usage: getRevisionNumber <revision>

Function:    getRevisionHash
Description: Get the revision hash from the revision string
usage: getRevisionHash <revision>

Function:    getAttachments
Description: Get a list of attachments for a document
usage: getAttachments <couchConnect> <database> <document>

Function:    getAttachment
Description: Get (download) attachment for a document
usage: getAttachment <couchConnect> <database> <document> <attachment>

Function:    delDB
Description: Dlete a database
usage: delDB <couchConnect> <database>

Function:    createDB
Description: Create a database
usage: createDB <couchConnect> <database>

Function:    delDoc
Description: Delete a document
usage: delDoc <couchConnect> <database> <document> [<revision>]

Function:    delAttachment
Description: Delete an attachment from document
usage: delAttachment <couchConnect> <database> <document> <attachment> [<revision>]

Function:    putDoc
Description: Create/update a document
usage: putDoc <couchConnect> <database> [<document>] <@file|'{json}'>

Function:    putAttachment
Description: Create/update attachment
usage: putAttachment <couchConnect> <database> <document> [<attachment name>] <file>

Function:    bomCheck
Description: Check if the input value contains the BOM character
usage: bomCheck <input>

Function:    formatJson
Description: Format Json output to make it look nice
usage: pipe output to formatJson function

Function:    compareRevisions
Description: Compare two CouchDB revision numbers
Legend:
   - Missing
   = Equal
   > Larger Then
   < Smaller Then
   ! Hash Mismatch
usage: compareRevisions <revision> <revision>

Function:    downloadDB
Description: Download a CouchDB database to local disk
usage: downloadDB <couchConnect> <database> [</path/to/download/dir>]

Function:    couchdbToolsDocumentation
Description: Create documentation for CouchDB Tools
usage: createDocumentation <couchdb-tools library>
```
