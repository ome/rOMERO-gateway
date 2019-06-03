FROM imagedata/jupyter-docker:0.9.0
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

# The branch to build the romero.gateway from
ARG ROMERO_VERSION=
ARG ROMERO_BRANCH_USER=ome
ARG ROMERO_BRANCH=master
ARG INSTALL_SCRIPT_URL=https://raw.githubusercontent.com/ome/rOMERO-gateway/master/install.R

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
    curl -sf $INSTALL_SCRIPT_URL --output install.R
RUN if [ -z ${ROMERO_VERSION} ]; then \
    bash -c "source activate r-omero && Rscript /opt/romero/install.R --user=$ROMERO_BRANCH_USER --branch=$ROMERO_BRANCH --quiet"; else \
    bash -c "source activate r-omero && Rscript /opt/romero/install.R --version=$ROMERO_VERSION --quiet"; fi

ENV OMERO_LIBS_DOWNLOAD=TRUE
RUN bash -c "source activate r-omero && echo \"library('romero.gateway')\" | R --no-save"
