#!/usr/bin/env bash

PC_COMPOSE_ENV=""
TTY=""

# use docker-compose file according to env and if it exists
if [ ! -z "$PC_ENV" ] && [ -f "./docker-compose.$PC_ENV.yml" ]; then
    readonly PC_COMPOSE_ENV=".$PC_ENV"
fi

# # # # # # # # # # # # # # # # # # # #
# disable pseudo-TTY allocation for CI (Jenkins)
if [ ! -z "$BUILD_NUMBER" ]; then
    TTY="--tty"
fi

readonly COMPOSE="docker-compose -f docker-compose$PC_COMPOSE_ENV.yml"
readonly RUN="$COMPOSE run --rm $TTY -w /var/www"

# # # # # # # # # # # # # # # # # # # #
# show all containers status
if [ "$1" == "status" ]; then
    shift
    $COMPOSE ps $@
    exit

elif [ "$1" == "top" ]; then
    $COMPOSE ps | grep 'Up\|Exit' | awk '{print $1}' | tr "\\n" " " | xargs docker stats --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
    exit

# # # # # # # # # # # # # # # # # # # #
# create and start all or specific containers
elif [ "$1" == "up" ]; then
    shift
    $COMPOSE up -d $@
    exit

# # # # # # # # # # # # # # # # # # # #
# start all or specific containers
elif [ "$1" == "start" ]; then
    shift
    $COMPOSE start $@
    exit

# # # # # # # # # # # # # # # # # # # #
# stop all or specific containers
elif [ "$1" == "stop" ]; then
    shift
    $COMPOSE stop $@
    exit

# # # # # # # # # # # # # # # # # # # #
# stop and destroy all containers
elif [ "$1" == "down" ]; then
    $COMPOSE down
    exit

# # # # # # # # # # # # # # # # # # # #
# run docker-compose commands
elif [ "$1" == "compose" ]; then
    shift
    $COMPOSE $@
    exit

# # # # # # # # # # # # # # # # # # # #
# show logs of all or specific containers
elif [ "$1" == "logs" ]; then
    shift
    $COMPOSE logs $@
    exit
fi
