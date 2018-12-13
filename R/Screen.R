#' Screen 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Screen
#' @exportClass Screen
#' @seealso \linkS4class{OMERO}
#' @import rJava
Screen <- setClass( 
  'Screen',
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
    if(!.jinstanceof(object@dataobject, ScreenData)) {
      return("OMERO object is not an instance of ScreenData!")
    }
    return(TRUE)
  }
)

#' Get the plates of the specific screen
#'
#' @param object The screen
#' @return The plates @seealso \linkS4class{Plate}
#' @export getPlates
#' @exportMethod getPlates
#' @import rJava
setMethod(
  f = "getPlates",
  signature = "Screen",
  definition = function(object)
  {
    server <- object@server
    obj <- object@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    browse <- gateway$getFacility(BrowseFacility$class)
    
    if(is.null(obj$getPlates())) {
      jlist <- new(ArrayList)
      jlist$add(new(Long, .jlong(obj$getId())))
      set <- browse$loadHierarchy(ctx, ScreenData$class,
                                   jlist, .jnull())
      it <- set$iterator()
      loaded <- .jrcall(it, method = "next")
    }
    else
      loaded <- obj
    
    plates <- c()
    jplates <- loaded$getPlates()
    it <- jplates$iterator()
    while(it$hasNext()) {
      jplate <- .jrcall(it, method = "next")
      plate <- Plate(server = server, dataobject = jplate)
      plates <- c(plates, plate)
    }
    return(plates)
  }
)

#' Get all images of a screen
#'
#' @param omero The screen
#' @param fieldIndex The fieldIndex (default = 1)
#' @return A list of image arrays [[i, j]] (one array per plate)
#'        where i is the well index and j is the field index;
#'        unless fieldIndex was specified, then a list of
#'        images is returned. @seealso \linkS4class{Image}
#' @export getImages
#' @exportMethod getImages
#' @examples
#' \dontrun{
#' images <- getImages(screen)
#' }
setMethod(
  f = "getImages",
  signature = "Screen",
  definition = function(omero, fieldIndex = 1)
  {
    plates <- getPlates(omero)
    
    if (missing(fieldIndex))
      fieldIndex <- 1
    
    result <- c()
    for(plate in plates) {
      result <- c(result, getImages(plate, fieldIndex = fieldIndex)) 
    }
    return(result)
  }
)

