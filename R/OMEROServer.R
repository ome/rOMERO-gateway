setClassUnion("jclassOrNULL", c("jobjRef", "NULL"))

#' OMEROServer class
#' Provides access to an OMERO server
#' 
#' @slot host The host name
#' @slot port The port number
#' @slot username The username
#' @slot password The password
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
    gateway = "jclassOrNULL",
    user = "jclassOrNULL",
    ctx = "jclassOrNULL"
  ),
  
  prototype = list(
    host = "localhost",
    port= 4064L,
    username = "root",
    password = "omero",
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
#' @return The server in "connected" state (if successful)
#' @examples
#' connect(server)
setMethod(f="connect",
          signature="OMEROServer",
          definition=function(server)
          {
            log <- new(SimpleLogger)
            gateway <- new (Gateway, log)
            
            lc <- new(LoginCredentials, server@username, server@password, server@host, server@port)
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

