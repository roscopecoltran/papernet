#!/bin/sh

mkdir ./data
go run cmd/cli/*.go index create --index=data/papernet.index --mapping=bleve/mapping.json

