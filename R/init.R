library("rJava")
.jinit(classpath = dir("lib", full.names=TRUE ))

source("R/initJavaClasses.R")
source("R/OMEROServer.R")
source("R/OMERO.R")

message("\n*** Welcome to rOMERO ***\n")
