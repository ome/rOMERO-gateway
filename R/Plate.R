#' Plate 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Plate
Plate <- setClass( 
  'Plate',
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
    if(!.jinstanceof(object@dataobject, PlateData)) {
      return("OMERO object is not an instance of PlateData!")
    }
    return(TRUE)
  }
)

setGeneric(
  name = "getWells",
  def = function(plate)
  {
    standardGeneric("getWells")
  }
)

#' Get the wells of the specific plate
#'
#' @param plate The plate
#' @return The wells
#' @export
#' @import rJava
setMethod(
  f = "getWells",
  signature = "Plate",
  definition = function(plate)
  {
    server <- plate@server
    gateway <- getGateway(server)
    ctx <- getContext(server)
    browse <- gateway$getFacility(BrowseFacility$class)
    jwells <- browse$getWells(ctx, .jlong(getOMEROID(plate)))
    
    wells <- c()
    it <- jwells$iterator()
    while(it$hasNext()) {
      jwell <- .jrcall(it, method = "next")
      if (jwell$asWell()$sizeOfWellSamples() > 0) {
        well <- Well(server=server, dataobject=jwell)
        wells <- c(wells, well)
      }
    }
    return(wells)
  }
)

#' Get all images of the specific plate
#'
#' @param omero The plate
#' @return The image ids as matrix [[i, j]] where
#'        i is the well index and j is the field index
#' @export
#' @import rJava
setMethod(
  f = "getImages",
  signature = "Plate",
  definition = function(omero)
  {
    wells <- getWells(omero)
    well <- wells[[1]]
    
    n <- length(getImages(well))
    m <- length(wells)
    
    result <- matrix(data=NA, nrow=m, ncol=n);
    i <- 1
    for(w in wells) {
      fields <- getImages(w)
      result[i, ] <- fields
      i <- i + 1
    }
    
    return(result)
  }
)
