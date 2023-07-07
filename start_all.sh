#!/usr/bin/env bash

# GCLOUD OUTPUT:
# NAME      ZONE             MACHINE_TYPE     PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP   STATUS
# icfpc     us-central1-a    n2d-standard-96  true         10.128.0.3                 TERMINATED
# icfpc-fi  europe-north1-a  n2d-standard-32  true         10.166.0.2   34.88.22.167  RUNNING

# Start icfpc in zone us-central1-a
gcloud compute instances start icfpc --zone us-central1-a

# Start icfpc-fi in zone europe-north1-a
gcloud compute instances start icfpc-fi --zone europe-north1-a
