validate_version:
ifndef VERSION
	$(error VERSION is undefined)
endif

db:
	cockroach demo --insecure --no-example-database

tables:
	cockroach sql --insecure < examples/many_to_many/create.sql

data:
	go run dg.go -c ./examples/many_to_many/config.yaml -o ./csvs/many_to_many

file_server:
	python3 -m http.server 3000 -d csvs/many_to_many

import:
	cockroach sql --insecure < examples/many_to_many/insert.sql

test:
	go test ./... -v -cover

release: validate_version
	# linux
	GOOS=linux go build -ldflags "-X main.version=${VERSION}" -o dg ;\
	tar -zcvf ./releases/dg_${VERSION}_linux.tar.gz ./dg ;\

	# macos
	GOOS=darwin go build -ldflags "-X main.version=${VERSION}" -o dg ;\
	tar -zcvf ./releases/dg_${VERSION}_macOS.tar.gz ./dg ;\

	# windows
	GOOS=windows go build -ldflags "-X main.version=${VERSION}" -o dg ;\
	tar -zcvf ./releases/dg_${VERSION}_windows.tar.gz ./dg ;\

	rm ./dg