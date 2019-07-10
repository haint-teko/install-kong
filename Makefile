# Makefile

SHELL := /bin/bash
include .env
export $(shell sed 's/=.*//' .env)

install:
	bash ./scripts/install_Kong.sh

kong-plugins:
	bash ./scripts/decision_maker.sh
