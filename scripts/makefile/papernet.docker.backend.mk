
## #################################################################
## TITLE
## #################################################################

papernet.docker.run.web:
	@echo "Running docker container for $(APP_NAME)"
	@docker run -t -i -v ${APP_DATA_DIR}:/data -p 0.0.0.0:$(APP_PORT_API):$(APP_PORT_API) $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG))
	@echo "Done."

papernet.docker.remove.web:
	@echo "Removing existing docker image"
	@docker rmi $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG))
	@echo "Done."

papernet.docker.rebuild.web: papernet.docker.remove.web

papernet.docker.publish.web: 
	@echo "Publishing image to artifactory..."
	@docker push $(or $(TAG), $(DOCKER_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG))
	@echo "Done."
