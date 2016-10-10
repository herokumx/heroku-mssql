# Ubuntu 16.04 with ODBC Drivers for SQL Server or Azure SQL DB
FROM ubuntu:16.04
# MSSQL Running on Heroku
MAINTAINER David Baliles

# Install required packages and remove the apt packages cache when done.
RUN export DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y build-essential debconf-utils apt-transport-https && rm -rf /var/lib/apt/lists/*

# Configure locales.
RUN export LC_ALL="en_US.UTF-8"
RUN locale-gen en_US en_US.UTF-8
RUN echo 'export LANG=C' >> /etc/profile && echo 'export LC_ALL=C' >> /etc/profile
RUN echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale
RUN dpkg-reconfigure --frontend=noninteractive locales && update-locale LANG=en_US.UTF-8

# let's make apt list package versions, since those are handy during devel
#RUN mkdir -p /app/mssql
WORKDIR .
#curl -O https://s3.amazonaws.com/herokudocker/configure-mssql-repo-2.sh
#curl -O https://s3.amazonaws.com/herokudocker/config-6823a30c-64e1-4464-9e99-41239213b795.tar.gz

RUN https://s3.amazonaws.com/herokudocker/configure-mssql-repo-2.sh
#RUN chmod a+x /app/mssql/configure-mssql-repo-2.sh
#RUN /app/mssql/configure-mssql-repo-2.sh config-6823a30c-64e1-4464-9e99-41239213b795.tar.gz ACCEPT_EULA=Y MSSQL_SERVER_SA_PASSWORD=mfede613 apt-get install mssql-server -y

#Run MSSQL & Expose it on port 8080
#docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=mfede613" -p 8080:1433 -v :/var/opt/mssql-d private-repo.microsoft.com/mssql-private-preview/mssql-server:latest

#Run MSSQL & Expose it on port 1433
#docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=mfede613" -p 8888:1433 -v :/app/mssql-d registry.heroku.com/mssql/worker