# Makefile

SHELL := /bin/bash

install:
	      source .env && ./scripts/install_Kong.sh
