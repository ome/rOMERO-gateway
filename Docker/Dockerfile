# R base with all necessary libraries installed to connect
# to an OMERO server 

FROM r-base:latest
MAINTAINER d.lindner@dundee.ac.uk

RUN apt-get update && apt-get -y install maven git r-cran-rjava

RUN git clone --depth 1 "https://github.com/dominikl/rOMERO.git" /home/docker/rOMERO

WORKDIR /home/docker/rOMERO
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
RUN mvn install

ENTRYPOINT ["/usr/bin/R"]
CMD ["source('init.R')"]
