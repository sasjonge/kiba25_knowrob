# Dockerfile of the base image: https://github.com/IntEL4CoRo/docker-stacks/blob/master/Dockerfile
FROM intel4coro/base-notebook:20.04-noetic

# Path to the default ROS workspace
ENV ROS_WS=${HOME}/workspace/ros

#============= Install extra software packages =============#
# Install SWI Prolog 
# Source: https://www.swi-prolog.org/build/PPA.html
USER root
RUN apt install -y software-properties-common && \
    apt-add-repository -y ppa:swi-prolog/stable
RUN apt update && \
    apt install -y swi-prolog
ENV SWI_HOME_DIR=/usr/lib/swi-prolog

# Install MongoDB Community Edition
# Source: https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/#std-label-install-mdb-community-ubuntu
ARG MONGODEB_VERSION=4.4
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-${MONGODEB_VERSION}.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-${MONGODEB_VERSION}.gpg --dearmor
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${MONGODEB_VERSION}.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${MONGODEB_VERSION} multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-${MONGODEB_VERSION}.list
RUN apt update && apt install -y mongodb-org
RUN mkdir -p /data/db && \
    chown -R ${NB_USER}:users /data/db 

# Install Knowrob
# Source: https://knowrob.github.io/knowrob/
USER ${NB_USER}
WORKDIR ${ROS_WS}/src
RUN wstool merge https://raw.github.com/knowrob/knowrob/master/rosinstall/knowrob-base.rosinstall && \
    wstool update

# Switch to root user to install ROS dependencies
# Source: http://wiki.ros.org/rosdep
USER root
RUN rosdep update && rosdep install -y -r --ignore-src --from-paths . && \
    rosdep fix-permissions

# Install jupyter knowrob kernel
# Source: https://github.com/sasjonge/jupyter-knowrob
# Install Knowrob kernel 
RUN pip3 install git+https://github.com/sasjonge/jupyter-knowrob.git
WORKDIR ~/.local/share/jupyter/kernels/
RUN mkdir jknowrob
RUN wget https://raw.githubusercontent.com/sasjonge/jupyter-knowrob/master/kernel.json -P ~/.local/share/jupyter/kernels/jknowrob


WORKDIR ${ROS_WS}/src/
RUN git clone https://github.com/sasjonge/knowrob_cloud.git
COPY --chown=${NB_USER}:users prolog /prolog

# Build catkin workspace
# Source: https://catkin-tools.readthedocs.io/en/latest/verbs/catkin_build.html
USER ${NB_USER}
WORKDIR ${ROS_WS}
RUN catkin build

# Copy content to the image
ENV REPO_DIR=${HOME}/work
WORKDIR ${REPO_DIR}
COPY --chown=${NB_USER}:users . ${REPO_DIR}/

# Create a symbolic link to the ROS workspace under the working directory
RUN ln -s ${ROS_WS} ${PWD}/ROS_WS

# The entrypoint of the docker image
COPY --chown=${NB_USER}:users binder/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]