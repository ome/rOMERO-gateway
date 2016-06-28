#' OME remote object class
#' This is basically a wrapper around the Pojo's of the Java Gateway
#' with a reference to the server.
#' 
#' @slot server Reference to the server
#' @slot server The Java data object
OMERO <- setClass(
  
  "OMERO",
  
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
    if(!.jinstanceof(object@dataobject, DataObject)) {
      return("OMERO object is not an instance of DataObject!")
    }
    return(TRUE)
  }
)
