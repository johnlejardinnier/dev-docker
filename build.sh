#!/usr/bin/env bash

BASE_PATH="$(dirname "$0")"
source $BASE_PATH/inc/init

# run docker-machine VM if necessary
if [ -x "$DOCKERMACHINE_PATH" ]; then
    if [ "$($DOCKERMACHINE status $DEVDOCKER_VM 2>&1)" != "Running" ]; then
        . ./vm-start.sh
    fi
    # set environment variables
    source $BASE_PATH/inc/vm-eval
    eval "$DOCKER_ENV_VARS"
fi

BUILD_OK=0
# bust cache if git repository updated
export CACHEBUST="`git ls-remote https://github.com/pa-de-solminihac/configuration.git | grep refs/heads/master | cut -f 1`"
BUILD_CMD="docker build $@ --build-arg CACHEBUST=$CACHEBUST -f devdocker/Dockerfile -t $DEVDOCKER_IMAGE:latest devdocker_php7"
$BUILD_CMD && BUILD_OK=1
if [ "$BUILD_OK" == "1" ]; then
    if [ -x "$DOCKERMACHINE_PATH" ]; then
        echo
        echo -ne "\033$TERM_COLOR_YELLOW"
        echo "# Run this command to configure your shell:"
        echo -ne "\033$TERM_COLOR_NORMAL"
        echo "eval \"\$($DOCKER_ENV_VARS_CMD)\""
        echo
    fi
    echo -ne "\033$TERM_COLOR_GREEN"
    echo "# Now you can tag and push the image:"
    echo -ne "\033$TERM_COLOR_NORMAL"
    echo "docker push $DEVDOCKER_IMAGE"
else
    echo
    echo -ne "\033$TERM_COLOR_RED"
    echo "# Build failed... there is something wrong with this build command:"
    echo "$BUILD_CMD"
    echo -ne "\033$TERM_COLOR_NORMAL"
fi
