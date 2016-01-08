# Todo: There's definitely a better way to do this kind of stuff...
library(rJava)
.jinit(classpath = dir("lib", full.names=TRUE ))

source("R/initJavaClasses.R")
source("R/OMEROServer.R")
source("R/OMERO.R")
