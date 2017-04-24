# OMERO R Gateway

R wrapper around the OMERO Java Gateway, to enable access to OMERO via R using [rJava](https://cran.r-project.org/web/packages/rJava/index.html)

## Prerequisites

* [R](https://www.r-project.org/)
* [Java](http://openjdk.java.net/)
* [rJava](https://cran.r-project.org/web/packages/rJava/index.html) [(Installation)](#Installing-rJava)
* [devtools](https://cran.r-project.org/web/packages/devtools/index.html)
* [Apache Maven](https://maven.apache.org/) (recommended)
* [Git](https://git-scm.com/) (recommended)

## Build/Install the romero.gateway R package
* Install/Setup the software mentioned above

### Automated

* Download and run [install.R](install.R) script:
  
  ```
  Rscript install.R
  ```
  
  You can specify a particular branch to build/install with `--user=[github username] --branch=[branch name]`
  or perform a local build of the cloned repository with `--local`

### Manual

* Download this repository: 
  * Using Git: ```git clone https://github.com/ome/rOMERO-gateway.git```
  * _Alternative_: Download as Zip and extract.
* ```cd``` into the ```rOMERO-gateway``` directory
* Download the dependencies
  * Using Maven: Run ```mvn install```
  * _Alternative_: Create ```inst/java``` directory. Download [OMERO.insight client](http://downloads.openmicroscopy.org/omero/5.3.0/). Extract the zip file. Copy all files within ```libs``` directory into the previously created ```rOMERO/inst/java``` directory
* Launch the ```R``` console
* Load devtools library ```library(devtools)```
* Build the package ```devtools::build()```
* Install the romero.gateway package into your local R repository
  ```
  install.packages([PATH TO romero.gateway_x.y.z.tar.gz], repos = NULL, type="source")
  ```

## Usage
* Like any other R package load the package ```library(romero.gateway)```
* Try some examples from the [examples directory](examples)

## Testing 
* Install [testthat](https://cran.r-project.org/web/packages/testthat/index.html)
* Modify [setup.csv](tests/testthat/setup.csv) to match your test server setup
* Run ```devtools::test()```

## Remarks

#### Installing rJava
Before installing the `rJava` package you probably have to set up Java for R first:
```
# as root
export $JAVA_HOME=[path to JDK/JRE]
R CMD javareconf
```
