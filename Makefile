start:
	docker compose up

stop:
	docker compose stop

clean:
	docker compose down
	rm -rf localstack
	sudo rm -rf volume