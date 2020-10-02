0.4.10 (October 2020)
---------------------

- fix issue that login password could accidentally be printed
  in console

0.4.9 (February 2020)
---------------------

- fix issue when connection to websocket URLs

0.4.8 (January 2020)
--------------------

- updated to OMERO 5.6
- attachDataframe method supports setting the namespace
- OMERO_LIBS_DOWNLOAD environment variable can be used to specify
  a custom URL from where to download the OMERO Java libs
- OMEROServer supports the 'sudo' functionality

0.4.7 (June 2019)
-----------------

- updated to OMERO 5.5
- preserved backward compatibility to OMERO 5.4

0.4.6 (June 2019)
-----------------

- fixed bug in Image.getPixelValues() method which returned
  distorted array of pixel values for images with non-square
  dimensions (PR #66)
- added a Dockerfile to the repository to spin up a Jupyter server 
  with R kernel and romero.gateway to make it easier to test R/OMERO
  code snippets, see 'jupyter' directory (PR #68)

0.4.5 (May 2019)
----------------

- improved the download process for the OMERO
  Java libraries
- disabled staged install for R 3.6 compatibility

0.4.4 (January 2019)
--------------------

This release includes:

- removed Java Libraries

0.4.3 (November 2018)
---------------------

This release includes:

- added method to get channel names
- added methods to get and add ROIs
- improved the usage examples
- bumped OMERO version to 5.4.9

0.4.2 (July 2018)
-----------------

This release includes:

- bumped OMERO version to 5.4.7
- reduced maven output using --quiet flag

0.4.1 (July 2018)
-----------------

This release includes:

- checked git2r version to handle S3 syntax and S4 one

0.4.0 (May 2018)
----------------

This release includes:

- added methods to specify group context
- added method to retrieve the Pixels values of a given plane
- fixed issue when running the tests in Travis CI
- bumped OMERO version to 5.4.6 and Bio-Formats to 5.8.2

0.3.0 (February 2018)
---------------------

This release includes:

 - added option to install different versions
 - added option to skip the installation steps
 - added CRAN compatibility check for Travis CI

0.2.0 (December 2017)
---------------------

This release includes:

 - added more methods to browse data
 - run the tests using Travis CI
 - fixed the documentation
 - bumped OMERO version to 5.4.1 and Bio-Formats to 5.7.2

0.1.0 (November 2017)
---------------------

This is the first public release of the gateway.
This version is compatible with OMERO 5.4.0.
