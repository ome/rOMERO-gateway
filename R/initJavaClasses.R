library(rJava)
.jinit()
.jaddClassPath(dir( "lib", full.names=TRUE ))

# Genereal Java classes
ArrayList <- J("java.util.ArrayList")
JFile <- J("java.io.File")
Integer <- J("java.lang.Integer")
Double <- J("java.lang.Double")
String <- J("java.lang.String")
Boolean <- J("java.lang.Boolean")


# General Gateway classes
SimpleLogger <- J("omero.log.SimpleLogger")
LoginCredentials <- J("omero.gateway.LoginCredentials")
SecurityContext <- J("omero.gateway.SecurityContext")
Gateway <- J("omero.gateway.Gateway")
BrowseFacility <- J("omero.gateway.facility.BrowseFacility")
ROIFacility <- J("omero.gateway.facility.ROIFacility")
MetadataFacility <- J("omero.gateway.facility.MetadataFacility")
DataManagerFacility <- J("omero.gateway.facility.DataManagerFacility")
TablesFacility <- J("omero.gateway.facility.TablesFacility")

# Gateway POJOs
DataObject <- J("omero.gateway.model.DataObject")
ExperimenterData <- J("omero.gateway.model.ExperimenterData")
MapAnnotationData <- J("omero.gateway.model.MapAnnotationData")
TagAnnotationData <- J("omero.gateway.model.TagAnnotationData")
FileAnnotationData <- J("omero.gateway.model.FileAnnotationData")
TableData <- J("omero.gateway.model.TableData")
