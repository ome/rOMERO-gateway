# rOMERO

This repository provides some examples for how to connect to OMERO in R (using rJava and the OMERO Java Gateway)

## Prerequisites

* [R](https://www.r-project.org/)
* [Java](http://openjdk.java.net/)
* [rJava](https://cran.r-project.org/web/packages/rJava/index.html)
* [Apache Maven](https://maven.apache.org/) (recommended)
* [Git](https://git-scm.com/) (recommended)

## Setup
* Install/Setup the software mentioned above
* Download this repository: 
  * Using Git: ```git clone https://github.com/ome/rOMERO-gateway.git```
  * _Alternative_: Download as Zip and extract.
* ```cd``` into the ```rOMERO``` directory
* Download the dependencies
  * Using Maven: Run ```mvn install```
  * _Alternative_: Create ```lib``` directory. Download [OMERO.Insight client](http://downloads.openmicroscopy.org/omero/5.3.0/). Extract the zip file. Copy all files within ```libs``` directory into the previously created ```rOMERO/lib``` directory

## Usage
Just ```cd``` into the ```rOMERO``` directory and launch ```R``` ([.Rprofile](.Rprofile) will do all the initialization for you)

Try some examples from the [examples directory](examples)

(Note: If you use RStudio please comment out the last line in [.Rprofile](.Rprofile) and run [init.R](R/init.R) yourself after you started RStudio.)

## Alternative
Create a __Docker__ image:
* Install [Docker](https://www.docker.com/)
* Download this repository (see above)
* Follow the steps mentioned on the [rOMERO Docker](https://github.com/ome/rOMERO-gateway/tree/master/Docker) page
