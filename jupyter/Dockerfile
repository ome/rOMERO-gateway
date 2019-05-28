FROM imagedata/jupyter-docker:0.9.0
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

# The branch to build the romero.gateway from
ARG ROMERO_BRANCH_USER=ome
ARG ROMERO_BRANCH=master

# R-kernel and R-OMERO prerequisites
ADD environment-r-omero.yml .setup/
RUN conda env update -n r-omero -q -f .setup/environment-r-omero.yml && \
    /opt/conda/envs/r-omero/bin/Rscript -e "IRkernel::installspec(displayname='OMERO R')"

USER root
RUN mkdir /opt/romero /opt/omero && \
    fix-permissions /opt/romero /opt/omero
# R requires these two packages at runtime
RUN apt-get install -y -q \
    libxrender1 \
    libsm6
USER $NB_UID

# build/install rOMERO
ENV _JAVA_OPTIONS="-Xss2560k -Xmx2g"
RUN cd /opt/romero && \
    curl -sf https://raw.githubusercontent.com/ome/rOMERO-gateway/master/install.R --output install.R && \
    bash -c "source activate r-omero && Rscript install.R --user=$ROMERO_BRANCH_USER --branch=$ROMERO_BRANCH --quiet"

ENV OMERO_LIBS_DOWNLOAD=TRUE
RUN bash -c "source activate r-omero && echo \"library('romero.gateway')\" | R --no-save"

# OMERO full CLI
# This currently uses the python2 environment, should we move it to its own?
ARG OMERO_VERSION=5.4.10
RUN cd /opt/omero && \
    /opt/conda/envs/python2/bin/pip install -q omego && \
    /opt/conda/envs/python2/bin/omego download -q --sym OMERO.server server --release $OMERO_VERSION && \
    rm OMERO.server-*.zip
ADD docker/omero-bin.sh /usr/local/bin/omero

# Clone the source git repo into notebooks (keep this at the end of the file)
COPY --chown=1000:100 . notebooks

