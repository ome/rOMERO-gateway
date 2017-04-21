#' Image 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Image
Image <- setClass( 
  'Image',
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
    if(!.jinstanceof(object@dataobject, ImageData)) {
      return("OMERO object is not an instance of ImageData!")
    }
    return(TRUE)
  }
)

