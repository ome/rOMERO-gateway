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
    jwells <- browse$getWells(ctx, getOMEROID(plate))
    
    wells <- c()
    it <- jwells$iterator()
    while(it$hasNext()) {
      jwell <- .jrcall(it, method = "next")
      well <- OMERO(server=server, dataobject=jwell)
      wells <- c(wells, well)
    }
    
    return(wells)
  }
)
