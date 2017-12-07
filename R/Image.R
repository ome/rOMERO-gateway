#' Image 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Image
#' @exportClass Image
#' @seealso \linkS4class{OMERO}
#' @import rJava
#' @importFrom jpeg readJPEG
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

#' Get the thumbnail for an Image (as JPEG)
#'
#' @param image The image
#' @param width The width (optional, default = 96)
#' @param height The height (optional, default = 96)
#' @return The thumbnail
#' @export getThumbnail
#' @exportMethod getThumbnail
setGeneric(
  name = "getThumbnail",
  def = function(image, width = 96, height = 96)
  {
    standardGeneric("getThumbnail")
  }
)

#' Get the thumbnail for an Image (as JPEG)
#'
#' @param image The image
#' @param width The width (optional, default = 96)
#' @param height The height (optional, default = 96)
#' @return The thumbnail
#' @export getThumbnail
#' @exportMethod getThumbnail
setMethod(
  f = "getThumbnail",
  signature = "Image",
  definition = function(image, width, height)
  {
    server <- image@server
    obj <- image@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    store <- gateway$getThumbnailService(ctx);
    
    dpix <- obj$getDefaultPixels()
    
    pixId <- dpix$getId()
    store$setPixelsId(.jlong(pixId))
    
    x <- rtypes$rint(as.integer(width))
    y <- rtypes$rint(as.integer(height))
    bytes <- store$getThumbnail(x, y)
    
    img <- readJPEG(bytes)
    return(img)
  }
)
