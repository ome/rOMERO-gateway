#' Dataset 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Dataset
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
    if(!.jinstanceof(object@dataobject, DatasetData)) {
      return("OMERO object is not an instance of DatasetData!")
    }
    return(TRUE)
  }
)

#' Get all images of the dataset
#'
#' @param omero The dataset
#' @return The image ids
#' @export
#' @import rJava
setMethod(
  f = "getImages",
  signature = "Dataset",
  definition = function(omero)
  {
    server <- omero@server
    obj <- omero@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    fac <- gateway$getFacility(BrowseFacility$class)
    
    id <- new(Long, .jlong(obj$getId()))
    jlist <- Collections$singletonList(id)
    
    jimgs <- fac$getImagesForDatasets(ctx, jlist)
    result <- c()
    it <- jimgs$iterator()
    while(it$hasNext()) {
      jimg <- .jrcall(it, method = "next")
      result <- c(result, as.integer(jimg$getId()))
    }
    
    return(result)
  }
)