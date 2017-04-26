# Specifiy a branch to build/install:
user <- 'ome'
branchName <- 'master'

# -- Don't edit anything below this line --

# Install necessary packages
libs <- c('rJava', 'devtools', 'testthat', 'roxygen2', 'xml2', 'httr', 'git2r')
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
    if (arg == '--local')
      localBuild <- TRUE
    if (startsWith(arg, '--user='))
      user <- gsub("--user=", "", arg)
    if (startsWith(arg, '--branch='))
      branchName <- gsub("--branch=", "", arg)
  }
}
if (!localBuild) {
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

# Install it
install.packages(packageFile, repos = NULL, type = "source")

