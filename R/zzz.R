#' @import methods
#' @importFrom utils packageVersion packageDescription unzip
#' @importFrom httr GET write_disk
.onAttach <- function(libname, pkgname) {
  romeroVersion <- utils::packageVersion("romero.gateway")
  omeroVersion <- utils::packageDescription("romero.gateway", fields = "Description")
  reg <- regexec('OMERO[[:space:]]version:[[:space:]](?<version>[0-9]+\\.[0-9]+)', omeroVersion, perl=TRUE)
  omeroVersion <- regmatches(omeroVersion, reg)
  omeroVersion <- omeroVersion[[1]][[2]]
  
  omeroLibs <- find.package(package='romero.gateway')
  omeroLibs <- paste(omeroLibs, 'java', sep = '/')
  if (!dir.exists(omeroLibs)) {
    # java libs dir doesn't exist yet
    dir.create(omeroLibs, recursive = TRUE)
  }
  
  if (!(file.exists(paste(omeroLibs, 'blitz.jar', sep = '/')) || 
        file.exists(paste(omeroLibs, 'omero-gateway.jar', sep = '/')))) {
    # OMERO java libraries haven't been downloaded yet.
    baseURL <- paste('https://downloads.openmicroscopy.org/latest/omero', omeroVersion, sep = '')
    zipFile <- 'OMERO.java.zip'
    
    getLibs <- Sys.getenv("OMERO_LIBS_DOWNLOAD", unset = NA)
    if (!is.na(getLibs) && startsWith(tolower(getLibs), 'http')) {
      # Allows using Java libs from merge-ci builds, e.g.
      # https://merge-ci.openmicroscopy.org/jenkins/job/OMERO-build/lastBuild/
      git_info <- GET(getLibs)
      status <- status_code(git_info)
      if (status != 200) {
        packageStartupMessage("Request failed. ", getLibs, " returned ", status)
        acc <- 'n'
      } else {
        git_info <- content(git_info, "text")
        ex <- ">(OMERO\\.java-\\S+\\.zip)<"
        r <- gregexpr(ex, git_info)
        res <- regmatches(git_info, r)
        zipFile <- substr(res[[1]], 2, nchar(res[[1]])-1)
        baseURL <- getLibs
        if (endsWith(getLibs, '/'))
          baseURL <- paste(baseURL, "artifact/src/target", sep = '')
        else
          baseURL <- paste(baseURL, "artifact/src/target", sep = '/') 
        acc <- 'y'
      }
    }
    else if (!is.na(getLibs) && as.logical(getLibs) == TRUE) {
      acc <- 'y'
    } else {
      packageStartupMessage('Have to download OMERO Java libraries from downloads.openmicroscopy.org.\nProceed? [y/n]')
      acc <- readLines(con = stdin(), n=1, ok=TRUE)
    }
    
    if (length(acc) > 0 && (acc[[1]] == 'y' || acc[[1]] == 'Y')) {
      dest <- paste(omeroLibs, zipFile, sep = '/')
      dlURL <- paste(baseURL, zipFile, sep = '/')
      packageStartupMessage(paste('Downloading', dlURL, '...'))
      GET(dlURL, write_disk(dest, overwrite=TRUE))
      packageStartupMessage('Extracting...')
      unzip(dest, exdir = omeroLibs)
      unzippedLibs <- NA
      for (dir in list.dirs(path = omeroLibs)) {
        x <- grep(paste(omeroLibs, "OMERO\\.java-.*", "libs", sep = '/'), dir)
        if (length(x)) {
          unzippedLibs <- dir
          break
        }
      }
      for (file in list.files(unzippedLibs)) {
        cpFrom <- paste(unzippedLibs, file, sep = '/')
        cpTo <- paste(omeroLibs, file, sep = '/')
        file.copy(from = cpFrom, to = cpTo)
      }
      file.remove(dest)
      toDelete <- sub('/libs', '', unzippedLibs)
      if (startsWith(toDelete, omeroLibs)) {
        # make sure to not accidentally delete something else
        unlink(toDelete, recursive = TRUE, force = TRUE)
      }
      packageStartupMessage('Finished. OMERO Java libraries saved in ', omeroLibs)
    } else {
      packageStartupMessage('Skipped. Note: romero.gateway will not work without the OMERO Java libraries.')
      return()
    }
  }
  
  .jinit(classpath = dir(omeroLibs, full.names=TRUE ))

  # Unfortunately have to add this stuff to base env
  # because romero.gateway env is locked
  env <- baseenv()
  
  # Genereal Java classes
  env$Collection <- J("java.util.Collection")
  env$Collections <- J("java.util.Collections")
  env$Iterator <- J("java.util.Iterator")
  env$ArrayList <- J("java.util.ArrayList")
  env$Set <- J("java.util.Set")
  env$HashSet <- J("java.util.HashSet")
  env$JFile <- J("java.io.File")
  env$Integer <- J("java.lang.Integer")
  env$Long <- J("java.lang.Long")
  env$Double <- J("java.lang.Double")
  env$String <- J("java.lang.String")
  env$Boolean <- J("java.lang.Boolean")
  env$Class <- J("java.lang.Class")
  
  # General Gateway classes
  env$rtypes <- J("omero.rtypes")
  env$SimpleLogger <- J("omero.log.SimpleLogger")
  env$LoginCredentials <- J("omero.gateway.LoginCredentials")
  env$SecurityContext <- J("omero.gateway.SecurityContext")
  env$Gateway <- J("omero.gateway.Gateway")
  env$AdminFacility <- J("omero.gateway.facility.AdminFacility")
  env$BrowseFacility <- J("omero.gateway.facility.BrowseFacility")
  env$ROIFacility <- J("omero.gateway.facility.ROIFacility")
  env$MetadataFacility <- J("omero.gateway.facility.MetadataFacility")
  env$DataManagerFacility <- J("omero.gateway.facility.DataManagerFacility")
  env$TablesFacility <- J("omero.gateway.facility.TablesFacility")
  env$SearchFacility <- J("omero.gateway.facility.SearchFacility")
  env$RawDataFacility <- J("omero.gateway.facility.RawDataFacility")
  env$ROIFacility <- J("omero.gateway.facility.ROIFacility")
  
  # Gateway POJOs
  env$DataObject <- J("omero.gateway.model.DataObject")
  env$PlateData <- J("omero.gateway.model.PlateData")
  env$ScreenData <- J("omero.gateway.model.ScreenData")
  env$DatasetData <- J("omero.gateway.model.DatasetData")
  env$ProjectData <- J("omero.gateway.model.ProjectData")
  env$WellData <- J("omero.gateway.model.WellData")
  env$WellSampleData <- J("omero.gateway.model.WellSampleData")
  env$ExperimenterData <- J("omero.gateway.model.ExperimenterData")
  env$GroupData <- J("omero.gateway.model.GroupData")
  env$AnnotationData <- J("omero.gateway.model.AnnotationData")
  env$MapAnnotationData <- J("omero.gateway.model.MapAnnotationData")
  env$TagAnnotationData <- J("omero.gateway.model.TagAnnotationData")
  env$FileAnnotationData <- J("omero.gateway.model.FileAnnotationData")
  env$ImageData <- J("omero.gateway.model.ImageData")
  env$ChannelData <- J("omero.gateway.model.ChannelData")
  env$TableData <- J("omero.gateway.model.TableData")
  env$TableDataColumn <- J("omero.gateway.model.TableDataColumn")
  env$SearchParameters <- J("omero.gateway.model.SearchParameters")
  env$SearchScope <- J("omero.gateway.model.SearchScope")
  env$SearchResultCollection <- J("omero.gateway.model.SearchResultCollection")
  env$Plane2D <- J("omero.gateway.rnd.Plane2D")
  env$ROIData <- J("omero.gateway.model.ROIData")
  env$PointData <- J("omero.gateway.model.PointData")
  env$EllipseData <- J("omero.gateway.model.EllipseData")
  env$RectangleData <- J("omero.gateway.model.RectangleData")
  env$AffineTransform <- J("omero.model.AffineTransformI")
  
  msg <- paste("\n*** Welcome to rOMERO ", romeroVersion, " ***\n", sep="")
  packageStartupMessage(msg)
}
