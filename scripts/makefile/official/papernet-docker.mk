
## #################################################################
## TITLE
## #################################################################

# dcb: docker-compose-backend
papernet-docker-dev-back:
	@echo "Running docker `development` container for $(APP_NAME), component `back-end`"
	@docker-compose -f docker-compose.dev.yml run backend_dev bashpp

# dcb: docker-compose-frontend
papernet-docker-dev-front: 
	@echo "Running docker `development` container for $(APP_NAME), component `front-end`"
	@docker-compose -f docker-compose.dev.yml run frontend_dev bashpp
