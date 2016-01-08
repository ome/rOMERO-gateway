source("../R/initJavaClasses.R")

e <- new.env()

connect <- function(username, password, host, port=4064) {
  log = new(SimpleLogger)
  gateway = new (Gateway, log)

  lc <- new(LoginCredentials)
  u <- lc$getUser()
  u$setUsername(as.character(username))
  u$setPassword(as.character(password))
  s <- lc$getServer()
  s$setHostname(as.character(host))
  s$setPort(as.integer(port))
  user <- gateway$connect(lc)

  ctx = new (SecurityContext, .jlong(user$getGroupId()))

  assign("gateway", gateway, env=e)
  assign("user", user, env=e)
  assign("ctx", ctx, env=e)
}

disconnect <- function() {
  gateway <- get("gateway", e)
  gateway$disconnect()
}

getUserId <- function() {
  return(get("user", e)$getId())
}

listDatasets <- function() {
  gateway <- get("gateway", e)
  ctx <- get("ctx", e)
  browse <- gateway$getFacility(BrowseFacility$class)
  datasets <- browse$getDatasets(ctx);
  return(as.list(datasets))
}

getDataset <- function(datasetId) {
  gateway <- get("gateway", e)
  ctx <- get("ctx", e)
  browse <- gateway$getFacility(BrowseFacility$class)
  ids <- new(ArrayList)
  ids$add( .jnew("java/lang/Long", .jlong(datasetId)) )
  datasets <- browse$getDatasets(ctx, ids)
  return(datasets$get(as.integer(0)))
}

listImages <- function(datasetId) {
  gateway <- get("gateway", e)
  ctx <- get("ctx", e)
  browse <- gateway$getFacility(BrowseFacility$class)
  
  ids <- new(ArrayList)
  ids$add( .jnew("java/lang/Long", .jlong(datasetId)) )
  images <- browse$getImagesForDatasets(ctx, ids)
  return(as.list(images))
}

listROIs <- function(image) {
  gateway <- get("gateway", e)
  ctx <- get("ctx", e)
  roifac <- gateway$getFacility(ROIFacility$class);
  rois <- roifac$loadShapes(ctx, .jlong(image$getId()));
  return(as.list(rois))
}

listImageAnnotations <- function(image) {
  gateway <- get("gateway", e)
  ctx <- get("ctx", e)
  mf <- gateway$getFacility(MetadataFacility$class);
  annos <- mf$getAnnotations(ctx, .jcast(image, "omero/gateway/model/ImageData"))
  return(as.list(annos))
}

addFile <- function(file, dataset) {
  gateway <- get("gateway", e)
  ctx <- get("ctx", e)
  dm <- gateway$getFacility(DataManagerFacility$class);
  jf <- new(JFile, as.character(file))
  anno <- dm$attachFile(ctx, jf, .jnull(), .jnull(), .jnull(), .jcast(dataset, "omero/gateway/model/DatasetData"), .jnull())
  return(anno) 
}