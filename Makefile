help:
	@echo >&2 "There is no default make target. Try 'make docker-test'"
	@false

docker-test:
	git submodule init
	git submodule update
	docker build -t tapestry-test build
	docker run -it -v="$(shell pwd):/home/tapestry/tapestry" -v=tapestry-bundle:/home/tapestry/tapestry/vendor/bundle -v=/home/tapestry/tapestry/tmp --env=RAILS_ENV=test tapestry-test bash -login -xec 'time bundle; time rake db:setup; time rake test'
