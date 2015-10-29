library(rJava)
.jinit()

files <- list.files(path="/home/dominik/workspace/rOMERO/lib", pattern="*.jar", full.names=T, recursive=FALSE)
lapply(files, function(f) {
  .jaddClassPath(f)
})

print(.jclassPath())
print(.jcall("java/lang/System", "S", "getProperty", "java.runtime.version"))

SimpleLogger <- J("omero.log.SimpleLogger")
LoginCredentials <- J("omero.gateway.LoginCredentials")
SecurityContext <- J("omero.gateway.SecurityContext")
Gateway <- J("omero.gateway.Gateway")

log <- new(SimpleLogger)
lc <- new(LoginCredentials)
u <- lc$getUser()
u$setUsername("root")
u$setPassword("omero")
s <- lc$getServer()
s$setHostname("localhost")

gw <- new (Gateway, log)

exp <- gw$connect(lc)

print(exp)