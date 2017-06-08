
## #################################################################
## TITLE
## #################################################################

GO_SRCS = $(shell git ls-files '*.go' | grep -v '^vendor/' | grep -v '^integration/vendor/')

# to finish later
