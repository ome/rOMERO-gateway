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


