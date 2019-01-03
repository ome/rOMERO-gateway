#' Well 
#' @slot server Reference to the server
#' @slot dataobject The Java data object
#' @export Well
#' @exportClass Well
#' @seealso \linkS4class{OMERO}
#' @import rJava
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

#' Get the row index of the specific well
#'
#' @param well The well
#' @return The row index
#' @export getRow
#' @exportMethod getRow
#' @examples
#' \dontrun{
#' row <- getRow(well)
#' }
setGeneric(
  name = "getRow",
  def = function(well)
  {
    standardGeneric("getRow")
  }
)

#' Get the column index of the specific well
#'
#' @param well The well
#' @return The column index
#' @export getColumn
#' @exportMethod getColumn
#' @examples
#' \dontrun{
#' col <- getColumn(well)
#' }
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
#' @param fieldIndex The field index; if specified only the
#'    image of this field is returned
#' @return The field images @seealso \linkS4class{Image}
#' @export getImages
#' @exportMethod getImages
#' @import rJava
#' @examples
#' \dontrun{
#' images <- getImages(well)
#' }
setMethod(
  f = "getImages",
  signature = "Well",
  definition = function(omero, fieldIndex)
  {
    server <- omero@server
    obj <- omero@dataobject
    jfields <- obj$getWellSamples()
    
    if (missing(fieldIndex)) {
      size <- as.integer(jfields$size())
      fields <- list(size)
      it <- jfields$iterator()
      i <- 1
      while(it$hasNext()) {
        jfield <- .jrcall(it, method = "next")
        jimg <- jfield$getImage()
        img <- Image(server=server, dataobject=jimg)
        fields[[i]] <-img
        i <- i + 1
      }
      return(fields)
    }
    else {
      jfield <- jfields$get(as.integer(fieldIndex))
      jimg <- jfield$getImage()
      img <- Image(server=server, dataobject=jimg)
      return(img)
    }
  }
)

#' Get the row index of the specific well
#'
#' @param well The well
#' @return The row index
#' @export getRow
#' @exportMethod getRow
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
#' @export getColumn
#' @exportMethod getColumn
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
#' @param x The well
#' @return The number of fields
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
