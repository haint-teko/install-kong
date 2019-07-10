# Makefile

SHELL := /bin/bash
include .env
export $(shell sed 's/=.*//' .env)

install:
	      ./scripts/install_Kong.sh
