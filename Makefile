all:
	@printf "Launch docker configuration\n"
	@mkdir -p /home/gcerrete/data/mariadb
	@mkdir -p /home/gcerrete/data/wordpress
	@docker compose -f ./srcs/docker-compose.yml up -d --build

build:
	@docker compose -f ./srcs/docker-compose.yml build

down:
	@docker compose -f ./srcs/docker-compose.yml down

re: down
	@docker compose -f ./srcs/docker-compose.yml up -d --build

clean:
	@docker compose -f ./srcs/docker-compose.yml down --rmi all -v

fclean: clean
	@sudo rm -rf /home/gcerrete/data/*

.PHONY: all build down re clean fclean
