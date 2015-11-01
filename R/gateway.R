library(rJava)
.jinit()

files <- list.files(path="/home/dominik/workspace/rOMERO/lib", pattern="*.jar", full.names=T, recursive=FALSE)
lapply(files, function(f) {
  .jaddClassPath(f)
})

SimpleLogger <- J("omero.log.SimpleLogger")
LoginCredentials <- J("omero.gateway.LoginCredentials")
SecurityContext <- J("omero.gateway.SecurityContext")
Gateway <- J("omero.gateway.Gateway")
ExperimenterData <- J("omero.gateway.model.ExperimenterData")
BrowseFacility <- J("omero.gateway.facility.BrowseFacility")

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

listDatasets <- function() {
  gateway <- get("gateway", e)
  ctx <- get("ctx", e)
  browse <- gateway$getFacility(BrowseFacility$class)
  datasets <- browse$getDatasets(ctx);
  return(datasets)
}

