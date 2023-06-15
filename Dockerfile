FROM rocker/r-ver:4.2.1

MAINTAINER Julien Barde "julien.barde@ird.fr"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libv8-dev \
	libsodium-dev \
    libsecret-1-dev \
    git
    
#geospatial
RUN /rocker_scripts/install_geospatial.sh

# install R core package dependencies
RUN install2.r --error --skipinstalled --ncpus -1 httpuv
RUN R -e "install.packages(c('remotes','jsonlite','yaml'), repos='https://cran.r-project.org/')"
# clone app
RUN git -C /root/ clone https://github.com/bastienird/darwin_core_viewer_bluecloud_workshop && echo "OK!"
RUN ln -s /root/darwin_core_viewer_bluecloud_workshop /srv/darwin_core_viewer_bluecloud_workshop
# install R app package dependencies
ENV RENV_VERSION 0.17.3
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"
WORKDIR /project
COPY renv.lock renv.lock

# approach one
ENV RENV_PATHS_LIBRARY renv/library

RUN R -e "renv::restore()"

#etc dirs (for config)
RUN mkdir -p /etc/darwin_core_viewer_bluecloud_workshop/

EXPOSE 3838

CMD ["R", "-e shiny::runApp('/srv/darwin_core_viewer_bluecloud_workshop',port=3838,host='0.0.0.0')"]


