#!/bin/sh
set -x
set -e

case "$1" in

	'npm')
		exec npm $@
	;;

	'npm_run')
		exec npm run $@
	;;

	'build')
		exec npm run build
	;;

	'dev')
		exec npm run dev
	;;

	'devv')
		exec npm run dev:v
	;;

	'jest')
		exec npm run jest
	;;

	'jest:u')
		exec npm run jest:u
	;;

	'lint')
		exec npm run lint
	;;

	'lintf')
		exec npm run lint:f
	;;

	'ncu') 
		exec ncu > /code/app/packages.ncu.json
	;;

	'bash')
		if [ "${BASH_EXECUTABLE}" == "" ]; then
			apk --update --no-progress --no-cache add bash 
		fi
		exec /bin/bash
	;;

	'bashplus')
		if [ "${BASH_EXECUTABLE}" == "" ]; then
			apk --update --no-progress --no-cache add bash nano tree 
		fi
		exec /bin/bash
	;;

	'test')
		exec npm run test
	;;

	*)
		exec sh $@
	;;

esac
