#!/bin/bash
docker build -t vsts-tf-ans --build-arg VCS_REF="git rev-parse --short HEAD" .
docker tag vsts-tf-ans sadfaerie/vsts-tf-ans 
docker push sadfaerie/vsts-tf-ans 