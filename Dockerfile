FROM ubuntu:18.04

LABEL maintainer="Sammy Barasa <barsamms@gmail.com>"
LABEL version=3.6.1

ENV R_BASE_VERSION 3.6.3
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV R_USER akilimo
ENV R_GROUP akilimo
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Nairobi


RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd $R_USER \
	&& mkdir /home/$R_USER \
	&& mkdir /home/$R_USER/projects \
	&& chown $R_USER:$R_USER /home/$R_USER \
	&& usermod -aG $R_GROUP $R_USER

#RUN apt-get update && apt-get install -y software-properties-common

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	    software-properties-common \
	    apt-utils \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		apt-transport-https \
		gsfonts \
		gnupg2 \
		curl \
	&& rm -rf /var/lib/apt/lists/*

# Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
RUN add-apt-repository ppa:webupd8team/java

# update some packages, including sodium and apache2, then clean
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    wget \
    openjdk-8-jdk \
    file \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    libxml2-dev \
    libpq-dev \
    libbz2-dev \
    libpng-dev \
    libssh2-1-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libxft-dev \
    ca-certificates \
    libglib2.0-0 \
	libxext6 \
	libsm6  \
	libxrender1 \
	bzip2 \
	libsodium-dev \
	libcairo2-dev \
    zlib1g-dev \
    build-essential \
    chrpath \
    libfreetype6 \
    libfreetype6-dev \
    libfontconfig1 \
    libfontconfig1-dev \
    pandoc \
    littler \
    r-cran-littler \
    r-base=${R_BASE_VERSION}* \
    r-base-dev=${R_BASE_VERSION}* \
    r-recommended=${R_BASE_VERSION}* \
    && echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
        && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
    && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && install.r docopt \
    && apt-get clean \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && rm -rf /var/lib/apt/lists/


#Reconfigure java
RUN R CMD javareconf
RUN R --version

#Do phantom js install
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share

RUN ln -sf /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin

RUN phantomjs --version
# copy the setup script, run it, then delete it
COPY setup.R /
RUN Rscript setup.R && rm setup.R


RUN which pandoc

CMD ["R"]

