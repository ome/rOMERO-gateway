setClassUnion("jclassOrNULL", c("jobjRef", "NULL"))

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

setMethod(f="connect",
          signature="OMEROServer",
          definition=function(server)
          {
            log <- new(SimpleLogger)
            gateway <- new (Gateway, log)
            
            lc <- new(LoginCredentials, server@username, server@password, server@host, server@port)
            
            user <- gateway$connect(lc)
            
            ctx <- new (SecurityContext, .jlong(user$getGroupId()))
            
            server@gateway <- gateway
            server@user <-user
            server@ctx <- ctx
            
            return(server)
          }
)

setMethod(f="disconnect",
          signature="OMEROServer",
          definition=function(server)
          {
            gateway <- getGateway(server)
            gateway$disconnect()
            return(server)
          }
)

setMethod(f="getGateway",
          signature="OMEROServer",
          definition=function(server)
          {
            return(server@gateway)
          }
)

setMethod(f="getContext",
          signature="OMEROServer",
          definition=function(server)
          {
            return(server@ctx)
          }
)

setMethod(f="loadObject",
          signature="OMEROServer",
          definition=function(server, type, id)
          {
            gateway <- getGateway(server)
            ctx <- getContext(server)
            browse <- gateway$getFacility(BrowseFacility$class)

            object <- browse$findObject(ctx, type, .jlong(id))
            return(object)
          }
)

# Test
# test <- OMEROServer(username = "user", password = "test")
# test <- connect(test)
# object <- loadObject(test, "omero.gateway.model.DatasetData", 101L)
# object
# test <- disconnect(test)

