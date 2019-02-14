# PyCharm SDK using Docker

The image is built by defining the user of the host system. We could use `/etc/passwd` and `/etc/group` but if home path of users is exotic or shell not defined in image, it could not work. For shake of simplicity, we define a user inside the docker. If a volume is mounted, the user should have same uid/gid than on the host.

> The command `id` helps to find user's informations :

    id -un # name of user
    id -u  # UID
    id -gn # name of main group
    id -g  # GID    

To build the image (behind a proxy) :

    docker build -t pycharm \
      --build-arg http_proxy=${http_proxy} \
      --build-arg https_proxy=${https_proxy} \
      --build-arg ftp_proxy=${ftp_proxy} \
      --build-arg no_proxy=${no_proxy} \
      --build-arg user=$(id -un) \
      --build-arg uid=$(id -u) \
      --build-arg group=$(id -gn) \
      --build-arg gid=$(id -g) \
      .

> We can use `docker-compose` but variables are not expanded.

To run the image :

    docker run -it --rm \
      --name pycharm
      -e DISPLAY=$(uname -n):0.0 \
      -v ${HOME}:/home/$(id -un) \
      pycharm

> X server should be enabled 

    xhost +
