DOCKER_SRV_NAME=mpd-srv
MUSIC_PATH=${HOME}/Música
PGID=1000
PUID=1000

##@ OPCOES

pull:  ## atualiza os binarios do mpd daemon
	docker pull woahbase/alpine-mpd:x86_64

run:  ## atualiza, encerra e executa o mpd daemon
	-make pull
	-make _rm
	docker run --restart on-failure --name ${DOCKER_SRV_NAME} --hostname mpd \
		-c 256 -m 256m \
		-p 6600:6600 -p 8000:8000 -p 64801:64801 \
		-e PGID=${PGID} -e PUID=${PUID} \
		-e PULSE_SERVER=unix:/run/user/${PUID}/pulse/native \
		-v /dev/shm:/dev/shm \
		-v /run/user/${PUID}/pulse:/run/user/${PUID}/pulse \
		-v ${HOME}/.pulse-cookie:/home/mpd/.pulse-cookie \
		-v ${PWD}/mpd.conf:/etc/mpd.conf \
		-v ${PWD}/data:/var/lib/mpd \
		-v ${MUSIC_PATH}:/var/lib/mpd/music \
		-v /tmp:/tmp \
	-d woahbase/alpine-mpd:x86_64

stop:  ## para o mpd daemon
	docker stop -t 2 ${DOCKER_SRV_NAME}

start:  ## inicia o mpd daemon
	docker start ${DOCKER_SRV_NAME}

restart:  ## reinicia o mpd daemon
	-make stop
	make start

_rm:  ## para e remove o container que executa o mpd daemon
	-make stop
	docker rm ${DOCKER_SRV_NAME}

log:  ## exibe o log de execucao do mpd daemon
	docker logs -f ${DOCKER_SRV_NAME}

##@ GERAL

.DEFAULT_GOAL := help
.PHONY: help

help:  ## exibe esta ajuda
	@awk 'BEGIN {FS = ":.*##"; printf "\nUtilizacao:\n  make \033[36m<opcao>\033[0m [\033[36m<opcao>\033[0m] [\033[36m<opcao>\033[0m] [...]\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo
	@echo http://localhost:64801 frontend web player
	@echo
	@echo https://hub.docker.com/r/woahbase/alpine-mpd
	@echo https://github.com/MusicPlayerDaemon/MPD
	@echo https://github.com/notandy/ympd
	@echo
	@echo https://github.com/ncmpcpp/ncmpcpp
	@echo https://github.com/CDrummond/cantata
