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

#' Get the channel names of an Image
#'
#' @param image The image
#' @return The channel names
#' @export getChannelNames
#' @exportMethod getChannelNames
setGeneric(
  name = "getChannelNames",
  def = function(image)
  {
    standardGeneric("getChannelNames")
  }
)


#' Get the pixel values of an Image.
#' An error will be thrown if invalid z, t or c values 
#' are specified.
#' @param image The image
#' @param z Z plane index (default: 1)
#' @param t T plane index (default: 1)
#' @param c Channel index (default: 1)
#' @return The pixel values as two-dimensional array [x][y]
#' @export getPixelValues
#' @exportMethod getPixelValues
setGeneric(
  name = "getPixelValues",
  def = function(image, z, t, c)
  {
    standardGeneric("getPixelValues")
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
    
    store <- gateway$getThumbnailService(ctx)
    
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

#' Get the channel names of an Image
#'
#' @param image The image
#' @return The channel names
#' @export getChannelNames
#' @exportMethod getChannelNames
setMethod(
  f = "getChannelNames",
  signature = "Image",
  definition = function(image)
  {
    server <- image@server
    obj <- image@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    fac <- gateway$getFacility(MetadataFacility$class)
    iid <- image@dataobject$getId()
    jchannels <- fac$getChannelData(ctx, .jlong(iid))
    channels <- c()
    it <- jchannels$iterator()
    while(it$hasNext()) {
      jchannel <- .jrcall(it, method = "next")
      channels <- c(channels, jchannel$getName())
    }
    return(channels)
  }
)

#' Get the pixel values of an Image.
#' An error will be thrown if invalid z, t or c values 
#' are specified.
#' @param image The image
#' @param z Z plane index (default: 1)
#' @param t T plane index (default: 1)
#' @param c Channel index (default: 1)
#' @return The pixel values as two-dimensional array [x][y]
#' @export getPixelValues
#' @exportMethod getPixelValues
setMethod(
  f = "getPixelValues",
  signature = "Image",
  definition = function(image, z, t, c)
  {
    server <- image@server
    obj <- image@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)

    if (missing(z)) {
      z <- 1
    }

    if (missing(t)) {
      t <- 1
    }

    if (missing(c)) {
      c <- 1
    }
    
    fac <- gateway$getFacility(RawDataFacility$class)
    pixelsObj <- obj$getDefaultPixels()
    
    plane <- fac$getPlane(ctx, pixelsObj, as.integer(z-1), as.integer(t-1), as.integer(c-1))
    jpixels = plane$getPixelValues()
    res <- .jevalArray(jpixels)
    data <- c()
    width <- length(res)
    height <- 0
    for (row in res) {
      col <- .jevalArray(row)
      data <- c(data, col)
      if (height == 0) 
        height <- length(col)
    }
    
    pixelArray <- array(data, dim=c(width, height))
    pixelArray <- aperm(pixelArray, c(2,1))
    return(pixelArray)
  }
)

