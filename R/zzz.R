.onAttach <- function(libname, pkgname) {
  
  packageDir <- find.package(package='romero.gateway')
  packageDir <- paste(packageDir, "/java", sep = '')
  if (!file.exists(packageDir)) {
    # package doesn't exist yet, i.e. this method is probably
    # run by build task like document() or similar
    packageDir <- "inst/java"
  }
  
  .jinit(classpath = dir(packageDir, full.names=TRUE ))

  # Unfortunately have to add this stuff to base env
  # because romero.gateway env is locked
  env <- baseenv()
  
  # Genereal Java classes
  env$Collection <- J("java.util.Collection")
  env$Iterator <- J("java.util.Iterator")
  env$ArrayList <- J("java.util.ArrayList")
  env$JFile <- J("java.io.File")
  env$Integer <- J("java.lang.Integer")
  env$Long <- J("java.lang.Long")
  env$Double <- J("java.lang.Double")
  env$String <- J("java.lang.String")
  env$Boolean <- J("java.lang.Boolean")
  
  # General Gateway classes
  env$SimpleLogger <- J("omero.log.SimpleLogger")
  env$LoginCredentials <- J("omero.gateway.LoginCredentials")
  env$SecurityContext <- J("omero.gateway.SecurityContext")
  env$Gateway <- J("omero.gateway.Gateway")
  env$BrowseFacility <- J("omero.gateway.facility.BrowseFacility")
  env$ROIFacility <- J("omero.gateway.facility.ROIFacility")
  env$MetadataFacility <- J("omero.gateway.facility.MetadataFacility")
  env$DataManagerFacility <- J("omero.gateway.facility.DataManagerFacility")
  env$TablesFacility <- J("omero.gateway.facility.TablesFacility")
  
  # Gateway POJOs
  env$DataObject <- J("omero.gateway.model.DataObject")
  env$PlateData <- J("omero.gateway.model.PlateData")
  env$WellData <- J("omero.gateway.model.WellData")
  env$WellSampleData <- J("omero.gateway.model.WellSampleData")
  env$ExperimenterData <- J("omero.gateway.model.ExperimenterData")
  env$MapAnnotationData <- J("omero.gateway.model.MapAnnotationData")
  env$TagAnnotationData <- J("omero.gateway.model.TagAnnotationData")
  env$FileAnnotationData <- J("omero.gateway.model.FileAnnotationData")
  env$ImageData <- J("omero.gateway.model.ImageData")
  env$TableData <- J("omero.gateway.model.TableData")
  env$TableDataColumn <- J("omero.gateway.model.TableDataColumn")
  
  packageStartupMessage("\n*** Welcome to rOMERO ***\n")
}
