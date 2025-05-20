#!/bin/bash
# Launch ros web applications
source ${ROS_WS}/devel/setup.bash
roscore &

# Start MongoDB and save data on working directory
MONGODB_URL=mongodb://127.0.0.1:27017
# Store MongoDB data under directory ${HOME}/data/db
mongod --fork --logpath ${HOME}/mongod.log

# Launch Knowrob
export KNOWROB_MONGODB_URI=${MONGODB_URL}/?appname=knowrob
roslaunch --wait knowrob knowrob.launch &

exec "$@"