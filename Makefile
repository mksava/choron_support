help:
	cat Makefile
	echo ""

build:
	bundle exec rake build

release:
	bundle exec rake release

run:
	docker-compose up

web:
	eval "docker exec -it `docker ps | grep _web_ | cut -d' ' -f1` /bin/bash"

clean:
	docker system prune
	docker system prune --volumes

down:
	docker-compose down

d-build:
	docker-compose build

d-build-no-cache:
	docker-compose build --no-cache

install:
	docker-compose run web bash -c "gem uninstall bundler && gem install bundler -v 2.3.13 && bundle install && yarn install"

spec-db-create:
	DB_CREATE=true bundle exec rspec spec/*

spec-table-create:
	bundle exec ridgepole --config ./spec/rails/config/database.yml --file ./spec/rails/config/schemafile --apply