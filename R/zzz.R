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
  
  msg <- paste("\n*** Welcome to rOMERO ", romeroVersion, " ***\n", sep="")
  packageStartupMessage(msg)
}
