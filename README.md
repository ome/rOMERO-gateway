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

* Download and run [install.R](install.R) script (requires Maven and Git):
  
  ```
  Rscript install.R
  ```
  
  You can specify a particular branch or version to build/install or perform a local build of the cloned repository. Run `Rscript install.R --help` to see more details.

### Manual

* Download this repository: 
  * Using Git: ```git clone https://github.com/ome/rOMERO-gateway.git```
  * _Alternative_: Download as Zip and extract.
* ```cd``` into the ```rOMERO-gateway``` directory
* Download the dependencies
  * Using Maven: Run ```mvn install```
  * _Alternative_: Create ```inst/java``` directory. Download [OMERO.insight client](https://downloads.openmicroscopy.org/latest/omero/). Extract the zip file. Copy all files within ```libs``` directory into the previously created ```rOMERO/inst/java``` directory
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
* Spin up an OMERO server to test against
* Adjust and run [test-data](.omeroci/test-data) script to populate 
the test server
* Adjust [setup.csv](tests/testthat/setup.csv) to match your test server setup (mostly `omero.host` etc; the various ids should be ok if you used the `test-data` script
to populate the server)
* Run ```devtools::test()```

## Remarks

#### Installing rJava
Before installing the `rJava` package you probably have to set up Java for R first:
```
# as root
export $JAVA_HOME=[path to JDK/JRE]
R CMD javareconf
```

#### Additional dependencies
In order to build/install some necessary R packages, additional system libraries may
have to be installed first. E.g. the R packages `httr` and `xml2` need the development libraries for
`curl` and `xml2`, so for example on a Debian system you most likely have to install `libcurl4-dev`
and `libxml2-dev` first.

