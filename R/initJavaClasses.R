# Genereal Java classes
Collection <- J("java.util.Collection")
Iterator <- J("java.util.Iterator")
ArrayList <- J("java.util.ArrayList")
JFile <- J("java.io.File")
Integer <- J("java.lang.Integer")
Long <- J("java.lang.Long")
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

# Gateway POJOs
DataObject <- J("omero.gateway.model.DataObject")
ExperimenterData <- J("omero.gateway.model.ExperimenterData")
MapAnnotationData <- J("omero.gateway.model.MapAnnotationData")
TagAnnotationData <- J("omero.gateway.model.TagAnnotationData")
FileAnnotationData <- J("omero.gateway.model.FileAnnotationData")
ImageData <- J("omero.gateway.model.ImageData")
