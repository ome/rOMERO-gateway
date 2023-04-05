#' Dataset 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Dataset
#' @exportClass Dataset
#' @seealso \linkS4class{OMERO}
#' @import rJava
Dataset <- setClass( 
  'Dataset',
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
    if(!.jinstanceof(object@dataobject, J("omero.gateway.model.DatasetData"))) {
      return("OMERO object is not an instance of DatasetData!")
    }
    return(TRUE)
  }
)

#' Get all images of a dataset
#'
#' @param omero The dataset
#' @return The images @seealso \linkS4class{Image}
#' @export getImages
#' @exportMethod getImages
setMethod(
  f = "getImages",
  signature = "Dataset",
  definition = function(omero)
  {
    server <- omero@server
    obj <- omero@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    fac <- gateway$getFacility(J("omero.gateway.facility.BrowseFacility")$class)
    
    id <- new(J("java.lang.Long"), .jlong(obj$getId()))
    jlist <- J("java.util.Collections")$singletonList(id)
    
    jimgs <- fac$getImagesForDatasets(ctx, jlist)
    result <- c()
    jimgslist <- as.list(jimgs)
    for (jimg in jimgslist) {
      img <- Image(server=server, dataobject=jimg)
      result <- c(result, img)
    }
    
    return(result)
  }
)