help: note-prerequisites
	@echo >&2 "There is no default make target. Try 'make docker-test'"
	@false

note-prerequisites:
	@echo >&2
	@echo >&2 "*** Prerequisites for 'make docker-test' ***"
	@echo >&2
	@echo >&2 "In docker host                     => install mysql"
	@echo >&2 "In docker host's mysql             => create a tapestry user"
	@echo >&2 "In config/database.yml             => host: your.docker.host.name"
	@echo >&2 "In docker host's /etc/mysql/my.cnf => bind-address = 0.0.0.0"
	@echo >&2
	@echo >&2 "*** See https://dev.arvados.org/projects/tapestry/wiki ***"
	@echo >&2

docker-test: note-prerequisites
	git submodule init
	git submodule update
	docker build -t tapestry-test build
	docker run -it -v="$(shell pwd):/home/tapestry/tapestry" -v=tapestry-bundle:/home/tapestry/tapestry/vendor/bundle -v=/home/tapestry/tapestry/tmp --env=RAILS_ENV=test tapestry-test bash -login -xec 'time bundle; time rake db:setup; time rake test'
