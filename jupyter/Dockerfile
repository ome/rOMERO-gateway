FROM jupyter/base-notebook:307ad2bb5fce
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

# The branch to build the romero.gateway from
ARG ROMERO_VERSION=
ARG ROMERO_BRANCH_USER=ome
ARG ROMERO_BRANCH=master
ARG INSTALL_SCRIPT_URL=https://raw.githubusercontent.com/ome/rOMERO-gateway/master/install.R
ARG OMERO_LIBS_DOWNLOAD=TRUE

USER root
RUN apt-get update -y && \
    apt-get install -y -q \
        build-essential \
        curl \
        git \
        libxrender1 \
        libsm6
RUN mkdir /opt/romero /opt/omero && \
    fix-permissions /opt/romero /opt/omero
USER $NB_UID

# Autoupdate notebooks https://github.com/data-8/nbgitpuller
RUN pip install git+https://github.com/data-8/gitautosync && \
    jupyter serverextension enable --py nbgitpuller

# R-kernel and R-OMERO prerequisites
ADD environment-r-omero.yml .setup/
RUN conda env update -n r-omero -q -f .setup/environment-r-omero.yml && \
    /opt/conda/envs/r-omero/bin/Rscript -e "IRkernel::installspec(displayname='OMERO R')"

# build/install rOMERO
ENV _JAVA_OPTIONS="-Xss2560k -Xmx2g"

RUN cd /opt/romero && \
    curl -sf $INSTALL_SCRIPT_URL --output install.R
RUN if [ -z ${ROMERO_VERSION} ]; then \
    bash -c "source activate r-omero && Rscript /opt/romero/install.R --user=$ROMERO_BRANCH_USER --branch=$ROMERO_BRANCH --quiet"; else \
    bash -c "source activate r-omero && Rscript /opt/romero/install.R --version=$ROMERO_VERSION --quiet"; fi

ENV OMERO_LIBS_DOWNLOAD=${OMERO_LIBS_DOWNLOAD}
RUN bash -c "source activate r-omero && echo \"library('romero.gateway')\" | R --no-save"

COPY --chown=1000:100 Get_Started.ipynb notebooks/

CMD ["start-notebook.sh"]

