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
    if(!.jinstanceof(object@dataobject, J("omero.gateway.model.ProjectData"))) {
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
    
    fac <- gateway$getFacility(J("omero.gateway.facility.BrowseFacility")$class)
    
    id <- new(J("java.lang.Long"), .jlong(obj$getId()))
    jlist <- J("java.util.Collections")$singletonList(id)
    
    jimgs <- fac$getImagesForProjects(ctx, jlist)
    result <- c()
    jimgslist <- as.list(jimgs)
    for (jimg in jimgslist) {
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
            
            fac <- gateway$getFacility(J("omero.gateway.facility.BrowseFacility")$class)
            
            id <- new(J("java.lang.Long"), .jlong(obj$getId()))
            jlist <- J("java.util.Collections")$singletonList(id)
            jprojects <- fac$getHierarchy(ctx, J("omero.gateway.model.ProjectData")$class, jlist, .jnull())
            
            tmplist <- as.list(jprojects)
            jproject <- tmplist[[1]]
            datasets <- c()
            jdatasetlist <- as.list(jproject$getDatasets())
            for (jdataset in jdatasetlist) {
              if(.jinstanceof(jdataset, J("omero.gateway.model.DatasetData"))) {
                dataset <- Dataset(server=object@server, dataobject=jdataset)
                datasets <- c(datasets, dataset)
              }
            }
            
            return(datasets)
          }
)
