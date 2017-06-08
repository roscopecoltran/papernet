
## #################################################################
## TITLE
## #################################################################

generate-certs:
	@mkdir -p $(CONFIG_CERTS_PATH)
	@openssl req -out $(CURDIR)/certs/server.csr -subj "/C=US/ST=California/L=Los Angeles/O=Default Company Ltd" -new -newkey rsa:2048 -nodes -keyout $(CURDIR)/certs/server.key
	@openssl req -x509 -sha256 -nodes -days 365 -subj "/C=US/ST=California/L=Los Angeles/O=Default Company Ltd" -newkey rsa:2048 -keyout $(CURDIR)/certs/server.key -out $(CURDIR)/certs/server.crt
	@chmod 600 $(CURDIR)/certs/server*
	# @openssl x509 -in $(CURDIR)/certs/server.pem -text -noout

