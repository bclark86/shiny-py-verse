FROM mdancho/shinyauth:latest

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadb-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    && install2.r --error --deps TRUE \
        reticulate \ 
        scales

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# System packages 
RUN apt-get update && apt-get install -y curl

ENV PATH /opt/conda/envs/env/bin:$PATH

# Install miniconda to /miniconda
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda

# create conda environment
ADD environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml

# activate
RUN echo "conda activate $(head -1 /tmp/environment.yml | cut -d' ' -f2)" >> ~/.bashrc
ENV PATH /opt/conda/envs/$(head -1 /tmp/environment.yml | cut -d' ' -f2)/bin:$PATH

# set as default
ENV CONDA_DEFAULT_ENV $(head -1 /tmp/environment.yml | cut -d' ' -f2)