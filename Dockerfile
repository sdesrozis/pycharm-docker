# NVidia stack is used by default

ARG BASE_IMAGE=nvidia/cuda:9.0-base-ubuntu16.04

FROM $BASE_IMAGE

LABEL name="PyCharm CE Base Image" \
      maintainer="Sylvain Desroziers <sylvain.desroziers@gmail.fr>"

# Installation is done with root privilege
USER root

# System updating
RUN apt-get update && \
    apt-get -y dist-upgrade && \ 
    apt-get install -y curl bzip2 libxext-dev libxrender-dev libxtst-dev libfreetype6-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# PyCharm installation
RUN cd /opt && \
    curl -sSL https://download.jetbrains.com/python/pycharm-community-2018.2.3.tar.gz -o pycharm.tar.gz && \
    tar -zxf pycharm.tar.gz && \
    rm -rf pycharm.tar.gz

ARG user="user"
ARG uid="1000"
ARG group="users"
ARG gid="100"
 
# Create the user (do not be root)
RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $uid $user && \
    groupadd -g $gid -o ${group:-${user}} && \
    usermod -g $gid -a -G $gid,100 $user && \
    mkdir -p /opt/conda && \
    chown $user:$gid /opt/conda

USER $uid

# Conda installation
RUN curl -sSL https://repo.continuum.io/miniconda/Miniconda3-4.5.1-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -bfp /opt/conda && \
    rm -rf /tmp/miniconda.sh

ENV PATH /opt/conda/bin:/opt/pycharm-community-2018.2.3/bin:${PATH}

RUN conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda install --quiet --yes conda=4.5.4 python=3.6 && \
    conda update --all --quiet --yes && \
    conda clean -tipsy && \
    pip install --upgrade pip

CMD ["pycharm.sh"]
