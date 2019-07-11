# Makefile

SHELL := /bin/bash
include .env
export $(shell sed 's/=.*//' .env)

install:
	bash ./scripts/install_kong.sh

decision-maker:
	bash ./scripts/install_decision_maker.sh
