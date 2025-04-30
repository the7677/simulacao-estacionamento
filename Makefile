all:
	@odin build src -out:estacionamento
	@chmod +x estacionamento
	@printf "\033[1;32marquivo \"estacionamento\" criado com sucesso!\033[m\n"