#!/usr/bin/env bash

# GCLOUD OUTPUT:
# NAME      ZONE             MACHINE_TYPE     PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP   STATUS
# icfpc     us-central1-a    n2d-standard-96  true         10.128.0.3                 TERMINATED
# icfpc-fi  europe-north1-a  n2d-standard-32  true         10.166.0.2   34.88.22.167  RUNNING

# Start instance-20240628-111438 in zone europe-west2-c:
gcloud compute instances start instance-20240628-111438 --zone europe-west2-c

# Generate ssh config for each user from users file using script `mk_gce <username>`.
# Then upload it to username@memoirici.de:
# Format of users file:
# <username> <ssh-key>
# drw ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGjAMLKOaj6pX75iOHhxWslnPVNr/TVjzJzYFLBEEtvDW7H1dX9Cx5861W1uGT7prHpv0Z67XqvHLJbqRbozgZUvsViIHv+GC9xyznXMxUzn/pROxmqO0jciCzKmYwXBZHI/gheyGzZxg7hc+2cUxL3r+nGJRAnfCHAfQMPKNHT1vmKrDshG3EuZkYw5NoueTwVEwjqyrDkdMy33PMaE6KXsmu/SjoT+wujfei9upUHxxFcPDkO11JTXlhsyaI8ic6+gR8aPmzup8axeQ69YenAwmsUAo/BEnsJyhUcIbNPjD5pV5hsuCBuH4h8ycV/2woefYgjxOZ+uZJ/WY+QzvNkMPH61dB8eDAzOB4eAMA8FJ1E5Mx/cZepX1JVwzfHnTb9g/WL1kxmFUeMiClbAdFBJ919pYTR6tNGB19lOK83+xMcP63XQn3ZbdaPPPAbCDXtitGqHT1ElgWzZHMZIZOQgO8kPmLQn+Qvc1WQj2DfYooSZQodbXjGsdCSMNDrlDDDnVdpyHI3403sn/H9RRQ/4FmjLmjvvaVX6QjkUZoD4ixOSRjPD24seMqwA+xkW2/nQcOQyhJ2K6zEWR7G7M8pL1RZ3ZFs5A5VpY3mzJ45O2nrEJNm7ui7yWcUnZefSE7QzDgmfSXGH3Je13zaQZgEF85YRS8Sa56HAFVIYrffQ== drw@technocore.net
# mira ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPXykZCkTk3iGTRefuj4UbT6IzZPmVyqaDHwLMm6gcC mira@mira
# pavel ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0QFhecujvrFZHQzCpxwkL+XYXo3G2XFF064u9KUN3V pavel
# vlad ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDalZDKboAxWB3pxMR3865i+P+L1bSu8DCTuJ2HOXC8E vlad
while read -r username ssh_key; do
    ./mk_gce "$username"
    rsync -Pave ssh "gce.$username.config" $username@memorici.de:
done < users
