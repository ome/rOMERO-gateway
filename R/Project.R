#' Project 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Project
#' @exportClass Project
#' @seealso \linkS4class{OMERO}
#' @import rJava
Project <- setClass( 
  'Project',
  contains = 'OMERO',
  
  slots = c(
    server = "OMEROServer",
    dataobject = "jobjRef"
  ),
  
  validity=function(object)
  {
    if(is.null(object@server)) {
      return("OMEROserver is missing!")
    }
    if(is.null(object@dataobject)) {
      return("OMERO object is missing!")
    }
    if(!.jinstanceof(object@dataobject, ProjectData)) {
      return("OMERO object is not an instance of ProjectData!")
    }
    return(TRUE)
  }
)


#' Get all images of a project
#'
#' @param omero The project
#' @return The images @seealso \linkS4class{Image}
#' @export getImages
#' @exportMethod getImages
#' @examples
#' \dontrun{
#' images <- getImages(project)
#' }
setMethod(
  f = "getImages",
  signature = "Project",
  definition = function(omero)
  {
    server <- omero@server
    obj <- omero@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    fac <- gateway$getFacility(BrowseFacility$class)
    
    id <- new(Long, .jlong(obj$getId()))
    jlist <- Collections$singletonList(id)
    
    jimgs <- fac$getImagesForProjects(ctx, jlist)
    result <- c()
    it <- jimgs$iterator()
    while(it$hasNext()) {
      jimg <- .jrcall(it, method = "next")
      img <- Image(server=server, dataobject=jimg)
      result <- c(result, img)
    }
    
    return(result)
  }
)

#' Get all datasets of a project
#' 
#' @param object The project
#' @return The datasets @seealso \linkS4class{Dataset}
#' @export getDatasets
#' @exportMethod getDatasets
setMethod(f="getDatasets",
          signature=("Project"),
          definition=function(object)
          {
            obj <- object@dataobject
            
            gateway <- getGateway(object@server)
            ctx <- getContext(object@server)
            
            fac <- gateway$getFacility(BrowseFacility$class)
            
            id <- new(Long, .jlong(obj$getId()))
            jlist <- Collections$singletonList(id)
            jprojects <- fac$getHierarchy(ctx, ProjectData$class, jlist, .jnull())
            
            it <- jprojects$iterator()
            jproject <- .jrcall(it, method = "next")
            datasets <- c()
            it <- jproject$getDatasets()$iterator()
            while(it$hasNext()) {
              jdataset <- .jrcall(it, method = "next")
              if(.jinstanceof(jdataset, DatasetData)) {
                dataset <- Dataset(server=object@server, dataobject=jdataset)
                datasets <- c(datasets, dataset)
              }
            }
            
            return(datasets)
          }
)
