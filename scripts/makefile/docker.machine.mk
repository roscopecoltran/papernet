
## #################################################################
## TITLE
## #################################################################

# xhyve, virtualbox
DOCKER_MACHINE_DRIVER=virtualbox 
DOCKER_MACHINE_SIZE=25g 
DOCKER_MACHINE_NAME=default

DOCKER_MACHINE_IP=$(shell docker-machine ip $(DOCKER_MACHINE_NAME))
DOCKER_MACHINE_STATUS=$(shell docker-machine status $(DOCKER_MACHINE_NAME) 2> /dev/null)

docker_machine_checks: check_docker_machine check_docker_compose

check_docker_machine:
	@case $$(docker-machine status $(DOCKER_MACHINE_NAME) 2> /dev/null) in \
        "")      echo "Creating Docker machine" && docker-machine create --driver virtualbox $(DOCKER_MACHINE_NAME);; \
        Stopped) echo "Starting machine" && docker-machine start $(DOCKER_MACHINE_NAME) ;; \
        Running) echo "Docker machine is running at $(shell docker-machine ip $(DOCKER_MACHINE_NAME))" ;; \
        *)         echo "Unknown Docker machine state" ;; \
    esac

check_docker_machine_env:
	@eval $$(docker-machine env $(DOCKER_MACHINE_NAME))

check_docker_compose: check_docker_machine check_docker_machine_env
	@if [ $(DOCKER_COMPOSE_PROCESSES) -eq 0 ]; then\
		echo "Starting docker-compose containers" && docker-compose up -d;\
	else\
	    echo "docker-compose containers are running";\
	fi

