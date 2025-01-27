FROM rocker/geospatial:4

ENV HOST 0.0.0.0
ENV SHINY_LOG_STDERR=1
ENV SHINY_LOG_LEVEL='INFO'

# Install system dependencies and shiny-server
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    ca-certificates \
    libudunits2-0 \
    gdebi-core \
    && curl -L -O https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb \
    && gdebi -n shiny-server-1.5.20.1002-amd64.deb \
    && rm shiny-server-1.5.20.1002-amd64.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install R package 'shiny'
RUN install2.r --error --skipinstalled -n 2 shiny

# Create necessary directories
RUN mkdir -p /srv/shiny-server/www/vendor \
    && mkdir -p /var/cache/shiny \
    && mkdir -p /var/log/shiny-server \
    && mkdir -p /var/lib/shiny-server/bookmarks

# Download and cache JavaScript dependencies locally
RUN cd /srv/shiny-server/www/vendor && \
    curl -L -o apexcharts.min.js https://cdn.jsdelivr.net/npm/apexcharts@3.26.2/dist/apexcharts.min.js && \
    curl -L -o jquery.min.js https://code.jquery.com/jquery-3.6.0.min.js && \
    curl -L -o tabler.min.css https://unpkg.com/@tabler/core@1.0.0-beta21/dist/css/tabler.min.css && \
    curl -L -o tabler.min.js https://unpkg.com/@tabler/core@1.0.0-beta21/dist/js/tabler.min.js

# Extra R packages
RUN install2.r --error --skipinstalled -n 2 \
    remotes \
    dplyr \
    reactable \
    htmltools \
    memoise \
    apexcharter \
    reactablefmtr \
    magrittr \
    scales \
    rlang \
    purrr \
    viridisLite \
    config \
    httr2 \
    golem \
    shinyjs \
    V8 \
    leaflet \
    leaflet.extras

# Install system dependencies for R packages that require them
RUN apt-get update && apt-get install --no-install-recommends -y \
    libudunits2-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy application files
COPY inst /srv/shiny-server/inst
COPY R /srv/shiny-server/R
COPY DESCRIPTION /srv/shiny-server/DESCRIPTION
COPY NAMESPACE /srv/shiny-server/NAMESPACE
COPY data /srv/shiny-server/data
COPY www /srv/shiny-server/www/

RUN Rscript -e 'remotes::install_local("/srv/shiny-server", dependencies = FALSE)'

# Copy configuration and app entry point
COPY shiny.config /etc/shiny-server/shiny-server.conf
COPY app.R /srv/shiny-server/app.R

# Create shiny user and group if they don't exist
RUN if ! id -u shiny > /dev/null 2>&1; then \
    groupadd -r shiny && useradd -r -g shiny shiny; \
fi

# Set proper permissions
RUN chown -R shiny:shiny /srv/shiny-server \
    && chown -R shiny:shiny /var/cache/shiny \
    && chown -R shiny:shiny /var/log/shiny-server \
    && chown -R shiny:shiny /var/lib/shiny-server \
    && chmod -R 755 /srv/shiny-server/www/vendor \
    && chmod -R 1777 /var/lib/shiny-server/bookmarks

# Add health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

EXPOSE 8080

USER shiny

CMD ["/usr/bin/shiny-server"]