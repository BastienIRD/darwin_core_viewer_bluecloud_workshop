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

# Set the working directory to /root/darwin_core_data_viewer
WORKDIR /root/darwin_core_data_viewer

# Clone the repository
RUN git clone -b CWP_database https://github.com/bastienird/darwin_core_data_viewer.git /root/darwin_core_data_viewer && \
    echo "OK!"

# Create a symbolic link to the cloned repository
RUN ln -s /root/darwin_core_data_viewer /srv/darwin_core_data_viewer

# Install renv package
RUN R -e "install.packages('renv', repos='https://cran.r-project.org/')"

# Activate and restore renv environment
RUN R -e 'library(renv); renv::activate();renv::repair(); renv::restore()'

# Expose port 3838 for the Shiny app
EXPOSE 3838

CMD ["R", "-e shiny::runApp('/srv/darwin_core_data_viewer',port=3838,host='0.0.0.0')"]


