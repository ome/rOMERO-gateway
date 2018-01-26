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
#' @export OMEROServer
#' @exportClass OMEROServer
#' @import rJava
#' @importFrom utils read.csv read.table
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

#' Connect to an OMERO server
#' 
#' @param server The server
#' @return The server in "connected" state (if successful)
#' @export connect
#' @exportMethod connect
setGeneric(name="connect",
           def=function(server)
           {
             standardGeneric("connect")
           }
)

#' Disconnect from an OMERO server
#' 
#' @param server The server
#' @return The server in "disconnected" state (if successful)
#' @export disconnect
#' @exportMethod disconnect
setGeneric(name="disconnect",
           def=function(server)
           {
             standardGeneric("disconnect")
           }
)

#' Get the reference to the Java Gatway
#' 
#' @param server The server
#' @return The Java Gateway
#' @export getGateway
#' @exportMethod getGateway
setGeneric(name="getGateway",
           def=function(server)
           {
             standardGeneric("getGateway")
           }
)

#' Get the current SecurityContext
#' 
#' @param server The server
#' @return The SecurityContext
#' @export getContext
#' @exportMethod getContext
setGeneric(name="getContext",
           def=function(server)
           {
             standardGeneric("getContext")
           }
)

#' Load an object from the server
#' 
#' @param server The server
#' @param type The object type
#' @param id The object ID
#' @return The OME remote object @seealso \linkS4class{OMERO}
#' @export loadObject
#' @exportMethod loadObject
setGeneric(name="loadObject",
           def=function(server, type, id)
           {
             standardGeneric("loadObject")
           }
)

#' Load a CSV file from the server
#' 
#' @param server The server 
#' @param id The original file ID
#' @param header Flag to indicate that the file starts with a header line
#' @param sep The separator character
#' @param quote The quote character
#' @param dec The decimal point character
#' @param fill Flag to indicate if blank fields should be added for rows with unequals length
#' @param comment.char The comment character
#' @return The dataframe constructed from the CSV file
#' @export loadCSV
#' @exportMethod loadCSV
setGeneric(name="loadCSV",
           def=function(server, id, header = TRUE, sep = ",", quote = "\"",
                        dec = ".", fill = TRUE, comment.char = "")
           {
             standardGeneric("loadCSV")
           }
)

#' Get annotations attached to an OME object.
#' Type, Namespace, Name, Content, ID, FileID (in case of file annotations)
#' 
#' @param object The OME object
#' @param type  The object type
#' @param id  The object id
#' @param typeFilter Optional annotation type filter, e.g. FileAnnotation
#' @param nameFilter Optional name filter, e.g. file name of a FileAnnotation
#' @return The annotations
#' @export getAnnotations
#' @exportMethod getAnnotations
setGeneric(name="getAnnotations",
           def=function(object, type, id, typeFilter, nameFilter)
           {
             standardGeneric("getAnnotations")
           }
)

#' Search for OMERO objects
#' 
#' @param server The server 
#' @param type The type of the objects to search for, e.g. Image (default: Image)
#' @param scope Limit the scope to 'Name', 'Description' or 'Annotation' (optional)
#' @param query The search query
#' @return The search results (collection of OMERO objects) @seealso \linkS4class{OMERO}
#' @export searchFor
#' @exportMethod searchFor
setGeneric(name="searchFor",
           def=function(server, type, scope, query)
           {
             standardGeneric("searchFor")
           }
)

#' Get all screens of the logged in user
#' 
#' @param server The server 
#' @return The screens @seealso \linkS4class{Screen}
#' @export getScreens
#' @exportMethod getScreens
setGeneric(name="getScreens",
           def=function(server)
           {
             standardGeneric("getScreens")
           }
)

#' Get all plates of the logged in user
#' 
#' @param object The server or screen
#' @return The plates @seealso \linkS4class{Plate}
#' @export getPlates
#' @exportMethod getPlates
setGeneric(name="getPlates",
           def=function(object)
           {
             standardGeneric("getPlates")
           }
)

#' Get all projects of the logged in user
#' 
#' @param server The server 
#' @return The projects @seealso \linkS4class{Project}
#' @export getProjects
#' @exportMethod getProjects
setGeneric(name="getProjects",
           def=function(server)
           {
             standardGeneric("getProjects")
           }
)

#' Get all datasets of the logged in user
#' 
#' @param object The server or project
#' @return The datasets @seealso \linkS4class{Dataset}
#' @export getDatasets
#' @exportMethod getDatasets
setGeneric(name="getDatasets",
           def=function(object)
           {
             standardGeneric("getDatasets")
           }
)

#' Connect to an OMERO server
#' 
#' @param server The server
#' @return The server in "connected" state (if successful)
#' @export connect
#' @exportMethod connect
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
#' @param server The server
#' @return The server in "disconnected" state (if successful)
#' @export disconnect
#' @exportMethod disconnect
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
#' @param server The server
#' @return The Java Gateway
#' @export getGateway
#' @exportMethod getGateway
setMethod(f="getGateway",
          signature="OMEROServer",
          definition=function(server)
          {
            return(server@gateway)
          }
)

#' Get the current SecurityContext
#' 
#' @param server The server
#' @return The SecurityContext
#' @export getContext
#' @exportMethod getContext
setMethod(f="getContext",
          signature="OMEROServer",
          definition=function(server)
          {
            return(server@ctx)
          }
)

#' Load an object from the server
#' 
#' @param server The server
#' @param type The object type
#' @param id The object ID
#' @return The OME remote object @seealso \linkS4class{OMERO}
#' @export loadObject
#' @exportMethod loadObject
setMethod(f="loadObject",
          signature="OMEROServer",
          definition=function(server, type, id)
          {
            gateway <- getGateway(server)
            ctx <- getContext(server)
            browse <- gateway$getFacility(BrowseFacility$class)
            if (type == 'ImageData') {
              object <- browse$getImage(ctx, .jlong(id))
            }
            else if (type == 'ProjectData' || type == 'DatasetData' || type == 'PlateData' || type == 'ScreenData') {
              ids <- new (ArrayList)
              ids$add(new (Long, .jlong(id)))
              if (type == 'ProjectData')
                clazz <- ProjectData$class
              if (type == 'DatasetData')
                clazz <- DatasetData$class
              if (type == 'ScreenData')
                clazz <- ScreenData$class
              if (type == 'PlateData')
                clazz <- PlateData$class
              tmp <- browse$getHierarchy(ctx, clazz, ids, .jnull(class = 'omero/sys/Parameters'))
              it <- tmp$iterator()
              object <- .jrcall(it, method = "next")
            }
            else if(type == 'WellData') {
              ids <- new (ArrayList)
              ids$add(new (Long, .jlong(id)))
              tmp <- browse$getWells(ctx, ids)
              it <- tmp$iterator()
              object <- .jrcall(it, method = "next")
            }
            else { 
              object <- browse$findObject(ctx, type, .jlong(id))
            }
            ome <- OMERO(server=server, dataobject=object)
            return(cast(ome))
          }
)

#' Load a CSV file from the server
#' 
#' @param server The server 
#' @param id The original file ID
#' @param header Flag to indicate that the file starts with a header line
#' @param sep The separator character
#' @param quote The quote character
#' @param dec The decimal point character
#' @param fill Flag to indicate if blank fields should be added for rows with unequals length
#' @param comment.char The comment character
#' @return The dataframe constructed from the CSV file
#' @export loadCSV
#' @exportMethod loadCSV
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
            
            df <- utils::read.csv(path, header = header, sep = sep, quote = quote,
                           dec = dec, fill = fill, comment.char = comment.char)
            
            file$delete()
            
            return(df)
          }
)

#' Get annotations attached to an OME object.
#' Type, Namespace, Name, Content, ID, FileID (in case of file annotations)
#' 
#' @param object The server
#' @param type The object type
#' @param id The object id
#' @param typeFilter Optional annotation type filter, e.g. FileAnnotation
#' @param nameFilter Optional name filter, e.g. file name of a FileAnnotation
#' @return The annotations
#' @export getAnnotations
#' @exportMethod getAnnotations
setMethod(f="getAnnotations",
          signature=("OMEROServer"),
          definition=function(object, type, id, typeFilter, nameFilter)
          {
            obj <- loadObject(object, type, id)
            annos <- getAnnotations(obj, typeFilter = typeFilter, nameFilter = nameFilter)
            return(annos)
          }
)

#' Search for OMERO objects
#' 
#' @param server The server 
#' @param type The type of the objects to search for, e.g. Image (default: Image)
#' @param scope Limit the scope to 'Name', 'Description' or 'Annotation' (optional)
#' @param query The search query
#' @return The search results (collection of OMERO objects) @seealso \linkS4class{OMERO}
#' @export searchFor
#' @exportMethod searchFor
setMethod(f="searchFor",
          signature=("OMEROServer"),
          definition=function(server, type, scope, query)
          {
            gateway <- getGateway(server)
            ctx <- getContext(server)
            sf <- gateway$getFacility(SearchFacility$class)
            
            types <- new(ArrayList)
            scopes <- new(HashSet)

            typeName <- attr(type, 'className')[1]
            clazz <- ImageData$class
            if(typeName == 'Project')
              clazz <- ProjectData$class
            else if(typeName == 'Dataset')
              clazz <- DatasetData$class
            else if(typeName == 'Screen')
              clazz <- ScreenData$class
            else if(typeName == 'Plate')
              clazz <- PlateData$class
            else if(typeName == 'Well')
              clazz <- WellData$class
            types$add(clazz)
            
            sscope <- NA
            if(!missing(scope)) {
              if(scope == 'Name')
                sscope <- SearchScope$NAME
              else if(scope == 'Description')
                sscope <- SearchScope$DESCRIPTION
              else if(scope == 'Annotation')
                sscope <- SearchScope$ANNOTATION
              
              if(!missing(sscope))
                scopes$add(sscope)
            }
          
            params <- new(SearchParameters, scopes,  types, query)
            
            src <- sf$search(ctx, params)
            jlist <- src$getDataObjects(as.integer(-1), .jnull(class = 'java/lang/Class'))
            
            result <- c()
            it <- jlist$iterator()
            while(it$hasNext()) {
              dataobj <- .jrcall(it, method = "next")
              obj <- OMERO(server=server, dataobject=dataobj)
              result <- c(result, cast(obj))
            }
            
            return(result)
          }
)

#' Get all screens of the logged in user
#' 
#' @param server The server 
#' @return The screens @seealso \linkS4class{Screen}
#' @export getScreens
#' @exportMethod getScreens
setMethod(f="getScreens",
          signature=("OMEROServer"),
          definition=function(server)
          {
            gateway <- getGateway(server)
            ctx <- getContext(server)
            
            browse <- gateway$getFacility(BrowseFacility$class)
            
            jscreens <- browse$getHierarchy(ctx, ScreenData$class, .jlong(-1))
            
            screens <- c()
            it <- jscreens$iterator()
            while(it$hasNext()) {
              jscreen <- .jrcall(it, method = "next")
              if(.jinstanceof(jscreen, ScreenData)) {
                screen <- Screen(server=server, dataobject=jscreen)
                screens <- c(screens, screen)
              }
            }
            return(screens)
           }
)

#' Get all plates of the logged in user
#' 
#' @param object The server
#' @return The plates @seealso \linkS4class{Plate}
#' @export getPlates
#' @exportMethod getPlates
setMethod(f="getPlates",
          signature=("OMEROServer"),
          definition=function(object)
          {
            gateway <- getGateway(object)
            ctx <- getContext(object)
            
            browse <- gateway$getFacility(BrowseFacility$class)
            
            jplates <- browse$getHierarchy(ctx, PlateData$class, .jlong(-1))
            
            plates <- c()
            it <- jplates$iterator()
            while(it$hasNext()) {
              jplate <- .jrcall(it, method = "next")
              if(.jinstanceof(jplate, PlateData)) {
                jscreens <- jplate$getScreens()
                if (is.jnull(jscreens)) {
                  plate <- Plate(server=object, dataobject=jplate)
                  plates <- c(plates, plate)
                }
              }
            }
            
            return(plates)
          }
)

#' Get all projects of the logged in user
#' 
#' @param server The server 
#' @return The projects @seealso \linkS4class{Project}
#' @export getProjects
#' @exportMethod getProjects
setMethod(f="getProjects",
          signature=("OMEROServer"),
          definition=function(server)
          {
            gateway <- getGateway(server)
            ctx <- getContext(server)
            
            browse <- gateway$getFacility(BrowseFacility$class)
            
            jprojects <- browse$getHierarchy(ctx, ProjectData$class, .jlong(-1))
            
            projects <- c()
            it <- jprojects$iterator()
            while(it$hasNext()) {
              jproject <- .jrcall(it, method = "next")
              if(.jinstanceof(jproject, ProjectData)) {
                project <- Project(server=server, dataobject=jproject)
                projects <- c(projects, project)
              }
            }
            
            return(projects)
          }
)

#' Get all datasets of the logged in user
#' 
#' @param object The server
#' @return The datasets @seealso \linkS4class{Dataset}
#' @export getDatasets
#' @exportMethod getDatasets
setMethod(f="getDatasets",
          signature=("OMEROServer"),
          definition=function(object)
          {
            gateway <- getGateway(object)
            ctx <- getContext(object)
            
            browse <- gateway$getFacility(BrowseFacility$class)
            
            jdatasets <- browse$getHierarchy(ctx, DatasetData$class, .jlong(-1))
            
            datasets <- c()
            it <- jdatasets$iterator()
            while(it$hasNext()) {
              jdataset <- .jrcall(it, method = "next")
              if(.jinstanceof(jdataset, DatasetData)) {
                dataset <- Dataset(server=object, dataobject=jdataset)
                datasets <- c(datasets, dataset)
              }
            }
            
            return(datasets)
          }
)

