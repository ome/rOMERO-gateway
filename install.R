# Specifiy a branch to build/install:
user <- 'ome'
branchName <- 'master'
version <- NULL
buildonly <- NULL

# -- Don't edit anything below this line --

# Install necessary packages
libs <- c('rJava', 'devtools', 'testthat', 'roxygen2', 'xml2', 'httr', 'git2r', 'jpeg')
toInstall <- libs[!(libs %in% installed.packages()[,"Package"])]
if (length(toInstall) > 0) {
  install.packages(toInstall, repos='http://cran.us.r-project.org')
}

# Load packages
library(devtools)
library(git2r)

args <- commandArgs(trailingOnly = TRUE)
localBuild <- FALSE
if (length(args) > 0) {
  for (arg in args) {
    if (arg == '--help') {
      cat('\n', 'Downloads, builds and installs the romero-gateway package', '\n', '\n')
      cat('Options:', '\n', '\n')
      cat('--local              Build local branch', '\n')
      cat('--version=[VERSION]  Build a specific version (see github tags), e.g. v0.2.0', '\n')
      cat('--buildonly=[PATH]   Directory where the romero.gateway_x.y.z.tar.gz package should be saved (if specified the package is only built, not installed), e. g. ~/ (for the user\'s home directory)', '\n', '\n')
      cat('Specify a user repository and/or branch:', '\n')
      cat('--user=[USER]        Use forked repository of a certain user (default: ome)', '\n')
      cat('--branch=[BRANCH]    Use branch within the specified user repository (default: master)', '\n', '\n')
      cat('When no options are specified the \'master\' branch (i.e. the current development snapshot) https://github.com/ome/rOMERO-gateway/tree/master will used.', '\n', '\n')
      quit(save = 'no', status = 0, runLast = FALSE)
    }
    if (arg == '--local')
      localBuild <- TRUE
    if (startsWith(arg, '--user='))
      user <- gsub("--user=", "", arg)
    if (startsWith(arg, '--branch='))
      branchName <- gsub("--branch=", "", arg)
    if (startsWith(arg, '--version='))
      version <- gsub("--version=", "", arg)
    if (startsWith(arg, '--buildonly='))
      buildonly <- gsub("--buildonly=", "", arg)
  }
}
if (!localBuild) {
  if( !is.null(version)) {
    user <- 'ome'
    branchName <- 'master'
  }
  cat('Building romero.gateway based on branch', branchName, 'from user', user, '\n')
  # Clone the git repository
  repoDir <- paste(tempdir(),'romero-gateway', sep="/")
  dir.create(repoDir)
  repoURL <- paste('https://github.com/', user, '/rOMERO-gateway.git', sep = '')
  ret <- git2r::clone(repoURL, branch=branchName, local_path = repoDir)
  if (is.null(ret)) {
    print('Git clone failed.')
    quit(save = 'no', status = 1, runLast = FALSE)
  }
  if( !is.null(version)) {
    for( tag in tags(ret)) {
      if (tag@name == version) {
        print(paste('Checking out version', tag@name))
        git2r::checkout(tag)
        break
      }
    }
  }
  setwd(repoDir)
} else {
  print('Performing local romero.gateway build')
}

# Run Maven to fetch the java dependencies
ret <- system2('mvn', args = c('install'))
if ( ret != 0) {
  print('Maven execution failed.')
  quit(save = 'no', status = ret, runLast = FALSE)
}

# Build the romero.gateway package
packageFile <- devtools::build(path = '.')
if (is.null(packageFile)) {
  print('Build failed.')
  quit(save = 'no', status = 1, runLast = FALSE)
}

if (!is.null(buildonly)) {
  res <- file.copy(packageFile, buildonly)
  if (res)
    quit(save = 'no', status = 0, runLast = FALSE)
  else {
    print('Copy package failed.')
    quit(save = 'no', status = 1, runLast = FALSE)
  }
}

# Install it
install.packages(packageFile, repos = NULL, type = "source")

