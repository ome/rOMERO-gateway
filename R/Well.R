#' Well 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Well
Well <- setClass( 
  'Well',
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
    if(!.jinstanceof(object@dataobject, WellData)) {
      return("OMERO object is not an instance of WellData!")
    }
    return(TRUE)
  }
)

setGeneric(
  name = "getRow",
  def = function(well)
  {
    standardGeneric("getRow")
  }
)

setGeneric(
  name = "getColumn",
  def = function(well)
  {
    standardGeneric("getColumn")
  }
)


#' Get the fields of the specific well
#'
#' @param omero The well
#' @return The fields (image ids)
#' @export
#' @import rJava
setMethod(
  f = "getImages",
  signature = "Well",
  definition = function(omero)
  {
    server <- omero@server
    obj <- omero@dataobject
    jfields <- obj$getWellSamples()
    
    fields <- c()
    it <- jfields$iterator()
    while(it$hasNext()) {
      jfield <- .jrcall(it, method = "next")
      img <- jfield$getImage()$getId()
      fields <- c(fields, as.integer(img))
    }

    return(fields)
  }
)

#' Get the row index of the specific well
#'
#' @param well The well
#' @return The row index
#' @export
#' @import rJava
setMethod(
  f = "getRow",
  signature = "Well",
  definition = function(well)
  {
    obj <- well@dataobject
    row <- obj$getRow()
    return(as.integer(row))
  }
)

#' Get the column index of the specific well
#'
#' @param well The well
#' @return The column index
#' @export
#' @import rJava
setMethod(
  f = "getColumn",
  signature = "Well",
  definition = function(well)
  {
    obj <- well@dataobject
    column <- obj$getColumn()
    return(as.integer(column))
  }
)

#' Get the number of fields
#'
#' @param well The well
#' @return The number of fields
#' @export
#' @import rJava
setMethod(
  f = "length",
  signature = "Well",
  definition = function(x)
  {
    images <- getImages(x)
    return(length(images))
  }
)
