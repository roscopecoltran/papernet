
## #################################################################
## TITLE
## #################################################################

# Handle linux/osx differences
XARGS := xargs -r
FIND_DEPTH := maxdepth
ifeq ($(UNAME_S),Darwin)
	XARGS := xargs
	FIND_DEPTH := depth
endif