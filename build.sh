#!/bin/bash

USERNAME=oaklydokely
IMAGE_NAME=rust

# Build both
docker build -t ghcr.io/$USERNAME/${IMAGE_NAME}-prod:latest -f Dockerfile .
docker build -t ghcr.io/$USERNAME/${IMAGE_NAME}-dev:latest -f Dockerfile .

# Push both
docker push ghcr.io/$USERNAME/${IMAGE_NAME}-prod:latest
docker push ghcr.io/$USERNAME/${IMAGE_NAME}-dev:latest
