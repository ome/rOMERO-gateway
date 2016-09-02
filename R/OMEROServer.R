setClassUnion("jclassOrNULL", c("jobjRef", "NULL"))

#' OMEROServer class
#' Provides access to an OMERO server
#' 
#' @slot host The host name
#' @slot port The port number
#' @slot username The username
#' @slot password The password
#' @slot credentialsFile Text file providing username and password
#' @slot gateway Reference to the Gateway
#' @slot user The logged in user
#' @slot ctx The current SecurityContext
OMEROServer <- setClass(
  
  "OMEROServer",
  
  slots = c(
    host = "character",
    port = "integer",
    username = "character",
    password = "character",
    credentialsFile = "character",
    gateway = "jclassOrNULL",
    user = "jclassOrNULL",
    ctx = "jclassOrNULL"
  ),
  
  prototype = list(
    host = character(0),
    port= 0L,
    username = character(0),
    password = character(0),
    credentialsFile = character(0),
    gateway = NULL,
    user = NULL,
    ctx = NULL
  )
  
)

setGeneric(name="connect",
           def=function(server)
           {
             standardGeneric("connect")
           }
)

setGeneric(name="disconnect",
           def=function(server)
           {
             standardGeneric("disconnect")
           }
)

setGeneric(name="getGateway",
           def=function(server)
           {
             standardGeneric("getGateway")
           }
)

setGeneric(name="getContext",
           def=function(server)
           {
             standardGeneric("getContext")
           }
)

setGeneric(name="loadObject",
           def=function(server, type, id)
           {
             standardGeneric("loadObject")
           }
)

setGeneric(name="loadCSV",
           def=function(server, id, header = TRUE, sep = ",", quote = "\"",
                        dec = ".", fill = TRUE, comment.char = "")
           {
             standardGeneric("loadCSV")
           }
)

setGeneric(name="attachFile",
           def=function(server, omero, file)
           {
             standardGeneric("attachFile")
           }
)

#' Connect to an OMERO server
#' 
#' @param server The server.
#' @param credentialsFile An optional text file, providing the login credentials.
#' @return The server in "connected" state (if successful)
#' @examples
#' connect(server)
setMethod(f="connect",
          signature="OMEROServer",
          definition=function(server)
          {
            log <- new(SimpleLogger)
            gateway <- new (Gateway, log)

            if (length(server@credentialsFile)>0) {
              cred <- read.table(server@credentialsFile, header=FALSE, sep="=", row.names=1, strip.white=TRUE, na.strings="NA", stringsAsFactors=FALSE)
              username <- cred["omero.user", 1]
              password <- cred["omero.pass", 1]
              hostname <- cred["omero.host", 1]
              portnumber <- cred["omero.port", 1]
            }
            
            if (length(server@username)>0)
              username <- server@username
            if (length(server@password)>0)
              password <- server@password
            if (length(server@host)>0)
              hostname <- server@host
            if (server@port>0)
              portnumber <- server@port
            
            lc <- new(LoginCredentials, username, password, hostname, as.integer(portnumber))
            lc$setApplicationName("rOMERO")
            
            user <- gateway$connect(lc)
            
            server@gateway <- gateway
            server@user <- user
            server@ctx <- new (SecurityContext, .jlong(user$getGroupId()))
            
            return(server)
          }
)

#' Disconnect from an OMERO server
#' 
#' @param server The server.
#' @return The server in "disconnected" state (if successful)
#' @examples
#' disconnect(server)
setMethod(f="disconnect",
          signature="OMEROServer",
          definition=function(server)
          {
            gateway <- getGateway(server)
            gateway$disconnect()
            return(server)
          }
)

#' Get the reference to the Java Gatway
#' 
#' @param server The server.
#' @return The Java Gateway
#' @examples
#' getGateway(server)
setMethod(f="getGateway",
          signature="OMEROServer",
          definition=function(server)
          {
            return(server@gateway)
          }
)

#' Get the current SecurityContext
#' 
#' @param server The server.
#' @return The SecurityContext
#' @examples
#' getContext(server)
setMethod(f="getContext",
          signature="OMEROServer",
          definition=function(server)
          {
            return(server@ctx)
          }
)

#' Load an object from the server
#' 
#' @param OMEROServer 
#'
#' @return The OME remote object @seealso \linkS4class{OMERO}
#' @examples
#' loadObject(server, "DatasetData", 100)
setMethod(f="loadObject",
          signature="OMEROServer",
          definition=function(server, type, id)
          {
            gateway <- getGateway(server)
            ctx <- getContext(server)
            browse <- gateway$getFacility(BrowseFacility$class)

            object <- browse$findObject(ctx, type, .jlong(id))
            return(OMERO(server=server, dataobject=object))
          }
)

#' Load a CSV file from the server
#' 
#' @param OMEROServer 
#' @param id The original file ID
#' @param header Flag to indicate that the file starts with a header line
#' @param sep The separator character
#' @param quote The quote character
#' @param dec The decimal point character
#' @param fill Flag to indicate if blank fields should be added for rows with unequals length
#' @param comment.char The comment character
#' @return The dataframe constructed from the CSV file
#' @examples
#' loadCSV(server, 100)
setMethod(f="loadCSV",
          signature="OMEROServer",
          definition=function(server, id, header, sep, quote,
                              dec, fill, comment.char)
          {
            gateway <- getGateway(server)
            ctx <- getContext(server)
            browse <- gateway$getFacility(BrowseFacility$class)
            
            orgFile <- browse$findIObject(ctx, "OriginalFile", .jlong(id))
            
            store <- gateway$getRawFileService(ctx);
            store$setFileId(.jlong(id))
            
            file <- J("java.io.File")$createTempFile("attachment_", ".csv")
            stream <- new(J("java.io.FileOutputStream"), file)
            offset <- as.integer(0)
            size <- as.integer(orgFile$getSize()$getValue())
            INC <- as.integer(4096)
            while ((offset+INC) < size) {
              data <- store$read(.jlong(offset), INC)
              stream$write(.jarray(data, "java/lang/Byte"))
              offset <- offset + INC
            }
            data <- store$read(.jlong(offset), (size-offset))
            stream$write(.jarray(data, contents.class = "java/lang/Byte"))
            stream$close()

            path <- file$getPath()
            
            df <- read.csv(path, header = header, sep = sep, quote = quote,
                           dec = dec, fill = fill, comment.char = comment.char)
            
            file$delete()
            
            return(df)
          }
)

#' Attach a file to an OME object
#' 
#' @param OMEROServer 
#' @param omero The OME object
#' @param file The file to attach
#' @return The file annotation
#' @examples
#' attachFile(server, omero, file)
setMethod(f="attachFile",
          signature="OMEROServer",
          definition=function(server, omero, file)
          {
            gateway <- getGateway(server)
            ctx <- getContext(server)
            
            dm <- gateway$getFacility(DataManagerFacility$class)
            
            jf <- new(JFile, as.character(file))
            
            future <- dm$attachFile(ctx, jf, .jnull(), .jnull(), .jnull(), omero@dataobject)
            anno <- future$get()
            
            return(anno) 
          }
)

