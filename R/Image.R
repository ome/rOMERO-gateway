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
#' @examples
#' \dontrun{
#' jpegThumbnail <- getThumbnail(image)
#' }
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
#' @examples
#' \dontrun{
#' channelNames <- getChannelNames(image)
#' }
setGeneric(
  name = "getChannelNames",
  def = function(image)
  {
    standardGeneric("getChannelNames")
  }
)

#' Get the ROIs (Point, Ellipse or Rectangle) of an Image
#' x, y -> Point
#' x, y, rx, ry -> Ellipse
#' x, y, w, h -> Rectangle
#' theta: Rotation about theta
#' text: An optional comment
#' @param image The image
#' @param z The Z plane (default: 1)
#' @param t The timepoint (default: 1)
#' @return The coordinates as dataframe (x, y, rx, ry, w, h, theta, text)
#' @export getROIs
#' @exportMethod getROIs
#' @examples
#' \dontrun{
#' roi_coords <- getROIs(image)
#' }
setGeneric(
  name = "getROIs",
  def = function(image, z = 1, t = 1)
  {
    standardGeneric("getROIs")
  }
)

#' Add ROIs (Point, Ellipse or Rectangle) to an Image
#' x, y -> Point
#' x, y, rx, ry -> Ellipse
#' x, y, w, h -> Rectangle
#' theta: Rotation about theta
#' text: An optional comment
#' @param image The image
#' @param z The Z plane (default: 1)
#' @param t The timepoint (default: 1)
#' @param coords The coordinates as dataframe (x, y, rx, ry, w, h, theta, text)
#' @export addROIs
#' @exportMethod addROIs
#' @examples
#' \dontrun{
#' addROIs(image, coords = coordinates)
#' }
setGeneric(
  name = "addROIs",
  def = function(image, z = 1, t = 1, coords)
  {
    standardGeneric("addROIs")
  }
)

#' Add a Mask ROI to an Image
#' @param image The image
#' @param z The Z plane (default: 1)
#' @param t The timepoint (default: 1)
#' @param binmask The mask as binary array
#' @export addMask
#' @exportMethod addMask
#' @examples
#' \dontrun{
#' addMask(image, binmask = maskdata)
#' }
setGeneric(
  name = "addMask",
  def = function(image, z = 1, t = 1, binmask)
  {
    standardGeneric("addMask")
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
#' @examples
#' \dontrun{
#' pixel_values <- getPixelValues(image)
#' }
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

#' Get the ROIs (Point, Ellipse or Rectangle) of an Image
#' x, y -> Point
#' x, y, rx, ry -> Ellipse
#' x, y, w, h -> Rectangle
#' theta: Rotation about theta
#' text: An optional comment
#' @param image The image
#' @param z The Z plane (default: 1)
#' @param t The timepoint (default: 1)
#' @return The coordinates as dataframe (x, y, rx, ry, w, h, theta, text)
#' @export getROIs
#' @exportMethod getROIs
setMethod(
  f = "getROIs",
  signature = "Image",
  definition = function(image, z = 1, t = 1)
  {
    server <- image@server
    obj <- image@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    fac <- gateway$getFacility(ROIFacility$class)
    iid <- obj$getId()
    iid <- .jlong(iid)
    
    z <- as.integer(z - 1)
    t <- as.integer(t - 1)
    
    roiresults <- fac$loadROIsByPlane(ctx, iid, z, t)
    rois <- data.frame(x = c(0), y = c(0), rx = c(0), ry = c(0), w = c(0), h = c(0), theta = c(0), text = c('remove'), stringsAsFactors = FALSE)
    it <- roiresults$iterator()
    while (it$hasNext()) {
      roiresult <- .jrcall(it, method = "next")
      roidatas <- roiresult$getROIs()
      it2 <- roidatas$iterator()
      while (it2$hasNext()) {
        roidata <- .jrcall(it2, method = "next")
        shapes <- roidata$getShapes(z, t)
        it3 <- shapes$iterator()
        while (it3$hasNext()) {
          shape <- .jrcall(it3, method = "next")
          shape <- .jcast(shape, new.class = "omero.gateway.model.ShapeData")
          trans <- shape$getTransform()
          th <- NA
          if (!is.null(trans)) {
            # Assumption: The affine transform is a rotation about
            # an angle theta
            th <- trans$getA00()$getValue()
            th <- acos(as.numeric(th))
          }
          
          if (.jinstanceof(shape, PointData)) {
            p <- .jcast(shape, new.class = "omero.gateway.model.PointData")
            x <- p$getX()
            x <- as.numeric(x)
            y <- p$getY()
            y <- as.numeric(y)
            text <- tryCatch( {
              p$getText()},
              error=function(err) {
                return(NA)
              })
            text <- as.character(text)
            rois <- rbind(rois, c(x, y, NA, NA, NA, NA, th, text))
          }
          if (.jinstanceof(shape, EllipseData)) {
            p <- .jcast(shape, new.class = "omero.gateway.model.EllipseData")
            x <- p$getX()
            x <- as.numeric(x)
            y <- p$getY()
            y <- as.numeric(y)
            rx <- p$getRadiusX()
            rx <- as.numeric(rx)
            ry <- p$getRadiusY()
            ry <- as.numeric(ry)
            text <- tryCatch( {
              p$getText()},
              error=function(err) {
                return(NA)
              })
            text <- as.character(text)
            rois <- rbind(rois, c(x, y, rx, ry, NA, NA, th, text))
          }
          if (.jinstanceof(shape, RectangleData)) {
            p <- .jcast(shape, new.class = "omero.gateway.model.RectangleData")
            x <- p$getX()
            x <- as.numeric(x)
            y <- p$getY()
            y <- as.numeric(y)
            w <- p$getWidth()
            w <- as.numeric(w)
            h <- p$getHeight()
            h <- as.numeric(h)
            text <- tryCatch( {
              p$getText()},
              error=function(err) {
                return(NA)
              })
            text <- as.character(text)
            rois <- rbind(rois, c(x, y, NA, NA, w, h, th, text))
          }
        }
      }
    }
    rois <- rois[-1,]
    rownames(rois) <- c()
    return(rois)
  }
)

#' Add ROIs (Point, Ellipse or Rectangle) to an Image
#' x, y -> Point
#' x, y, rx, ry -> Ellipse
#' x, y, w, h -> Rectangle
#' theta: Rotation about theta
#' text: An optional comment
#' @param image The image
#' @param z The Z plane (default: 1)
#' @param t The timepoint (default: 1)
#' @param coords The coordinates as dataframe (x, y, rx, ry, w, h, theta, text)
#' @export addROIs
#' @exportMethod addROIs
setMethod(
  f = "addROIs",
  signature = "Image",
  definition = function(image, z = 1, t = 1, coords)
  {
    server <- image@server
    obj <- image@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    fac <- gateway$getFacility(ROIFacility$class)
    iid <- obj$getId()
    iid <- .jlong(iid)
    
    z <- as.integer(z - 1)
    t <- as.integer(t - 1)
    
    rois <- new(ArrayList)
    for (row in 1:nrow(coords)) {
      
      x <- coords[row, "x"]
      y <- coords[row, "y"]
      if ("rx" %in% colnames(coords))
        rx <- coords[row, "rx"]
      else
        rx <- NA
      if ("ry" %in% colnames(coords))
        ry <- coords[row, "ry"]
      else
        ry <- NA
      if ("w" %in% colnames(coords))
        w <- coords[row, "w"]
      else
        w <- NA
      if ("h" %in% colnames(coords))
        h <- coords[row, "h"]
      else
        h <- NA
      if ("theta" %in% colnames(coords))
        th <- coords[row, "theta"]
      else
        th <- NA
      if ("text" %in% colnames(coords))
        text <- coords[row, "text"]
      else
        text <- NA
      
      shape <- .jnew(class = "omero.gateway.model.PointData")
      
      if (!is.na(rx) || !is.na(ry)) {
        shape <- .jnew(class = "omero.gateway.model.EllipseData")
        radX <- if (!is.na(rx)) rx else ry
        radY <- if (!is.na(ry)) ry else rx
        shape$setRadiusX(as.numeric(radX))
        shape$setRadiusY(as.numeric(radY))
      }
      
      if (!is.na(w) && !is.na(h)) {
        shape <- .jnew(class = "omero.gateway.model.RectangleData")
        shape$setWidth(as.numeric(w))
        shape$setHeight(as.numeric(h))
      }
      
      shape$setX(as.numeric(x))
      shape$setY(as.numeric(y))
      
      if (!is.na(th)) {
        trans <- .jnew(class = "omero.model.AffineTransformI")
        th <- as.numeric(th)
        val <- cos(th)
        val <- as.numeric(val)
        val2 <- sin(th)
        val2 <- as.numeric(val2)
        trans$setA00(J("omero.rtypes")$rdouble(val))
        trans$setA11(J("omero.rtypes")$rdouble(val))
        trans$setA01(J("omero.rtypes")$rdouble(val2))
        trans$setA10(J("omero.rtypes")$rdouble(-val2))
        x <- as.numeric(x)
        y <- as.numeric(y)
        translateX <- (x - val * x - val2 * y)
        translateY <- (y + val2 * x - val * y)
        trans$setA02(J("omero.rtypes")$rdouble(translateX))
        trans$setA12(J("omero.rtypes")$rdouble(translateY))
        shape$setTransform(trans)
      }
      
      if (!is.na(text)) 
        shape$setText(text)
      
      shape$setZ(z)
      shape$setT(t)
      
      roi <- .jnew(class = "omero.gateway.model.ROIData")
      roi$setImage(obj$asImage())
      roi$addShapeData(shape)
      
      rois$add(roi)
    }
    invisible(fac$saveROIs(ctx, iid, rois))
  }
)

#' Add Mask ROIs to an Image. Expects a binary
#' mask array binmask covering the whole image.
#' @param image The image
#' @param z The Z plane (default: 1)
#' @param t The timepoint (default: 1)
#' @param binmask The mask as binary array
#' @export addMask
#' @exportMethod addMask
setMethod(
  f = "addMask",
  signature = "Image",
  definition = function(image, z = 1, t = 1, binmask)
  {
    server <- image@server
    obj <- image@dataobject
    gateway <- getGateway(server)
    ctx <- getContext(server)
    
    fac <- gateway$getFacility(ROIFacility$class)
    iid <- obj$getId()
    iid <- .jlong(iid)
    
    z <- as.integer(z - 1)
    t <- as.integer(t - 1)
    
    
    w <- dim(binmask)[1]
    binmask <- t(binmask)
    binmaskVector <- as.vector(binmask)
    jarray <- .jarray(binmaskVector,"[I")
    util <- J("omero/gateway/util/Mask")
    masks <- util$createCroppedMasks(jarray, w)
    
    rois <- new(ArrayList)
    
    it <- masks$iterator()
    while (it$hasNext()) {
      shape <- .jrcall(it, method = "next")
      roi <- .jnew(class = "omero.gateway.model.ROIData")
      roi$setImage(obj$asImage())
      roi$addShapeData(shape)
      rois$add(roi)
    }
    invisible(fac$saveROIs(ctx, iid, rois))
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
    width <- length(res)
    height <- res[[1]]$length
    pixelArray <- array(NA, dim = c(width,height))
    
    for (i in 1:width) {
      col <- .jevalArray(res[[i]])
      for (j in 1:height)
        pixelArray[i,j] <- col[j]
    }
    
    return(pixelArray)
  }
)

