# Configuration
user <- 'ome'
branchName <- 'master'

# Install necessary packages
libs <- c('rJava', 'devtools', 'git2r', 'testthat', 'roxygen2')
toInstall <- libs[!(libs %in% installed.packages()[,"Package"])]
if (length(toInstall) > 0) {
  install.packages(toInstall, repos='http://cran.us.r-project.org')
}

# Load packages
library(devtools)
library(git2r)

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

# Run Maven to fetch the java dependencies
ret <- system2('mvn', args = c('install'))
if ( ret != 0) {
  print('Maven execution failed.')
  quit(save = 'no', status = ret, runLast = FALSE)
}

# Build the romero.gateway package
packageFile <- devtools::build()
if (is.null(packageFile)) {
  print('Build failed.')
  quit(save = 'no', status = 1, runLast = FALSE)
}

# Install it
install.packages(packageFile, repos = NULL, type = "source")

