#!/usr/bin/env bash

# GCLOUD OUTPUT:
# λ gcloud compute instances list
# NAME             ZONE             MACHINE_TYPE     PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
# icfpc-hel        us-central1-a    n2d-highcpu-128  true         10.128.0.9                TERMINATED
# icfpc-leviathan  us-central1-a    n2d-highcpu-128  true         10.128.0.8                TERMINATED
# icfpc-32-1       europe-north1-a  n2d-highcpu-32   true         10.166.0.4                TERMINATED
# icfpc-32-2       europe-north1-a  n2d-highcpu-32   true         10.166.0.5                TERMINATED
# icfpc-komodo     europe-north1-a  n2d-highcpu-128  true         10.166.0.7                TERMINATED


if [ -z "$1" ]; then
    # Start all instances
    gcloud compute instances start icfpc-hel --zone us-central1-a
    gcloud compute instances start icfpc-leviathan --zone us-central1-a
    gcloud compute instances start icfpc-32-1 --zone europe-north1-a
    gcloud compute instances start icfpc-32-2 --zone europe-north1-a
    gcloud compute instances start icfpc-komodo --zone europe-north1-a
fi

# If we're running only small ones, limit ourselves to 32-core instances
if [ "$1" == "--small" ]; then
    gcloud compute instances start icfpc-32-1 --zone europe-north1-a
    gcloud compute instances start icfpc-32-2 --zone europe-north1-a
fi

gce_user="$(cat ./gce_user)"
./mk_gce "$gce_user"
cp "./gce.$gce_user.config" ~/.ssh/gce.config

# Generate ssh config for each user from users file using script `mk_gce <username>`.
# Then upload it to username@memoirici.de:
# Format of users file:
# <username> <ssh-key>
# drw ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGjAMLKOaj6pX75iOHhxWslnPVNr/TVjzJzYFLBEEtvDW7H1dX9Cx5861W1uGT7prHpv0Z67XqvHLJbqRbozgZUvsViIHv+GC9xyznXMxUzn/pROxmqO0jciCzKmYwXBZHI/gheyGzZxg7hc+2cUxL3r+nGJRAnfCHAfQMPKNHT1vmKrDshG3EuZkYw5NoueTwVEwjqyrDkdMy33PMaE6KXsmu/SjoT+wujfei9upUHxxFcPDkO11JTXlhsyaI8ic6+gR8aPmzup8axeQ69YenAwmsUAo/BEnsJyhUcIbNPjD5pV5hsuCBuH4h8ycV/2woefYgjxOZ+uZJ/WY+QzvNkMPH61dB8eDAzOB4eAMA8FJ1E5Mx/cZepX1JVwzfHnTb9g/WL1kxmFUeMiClbAdFBJ919pYTR6tNGB19lOK83+xMcP63XQn3ZbdaPPPAbCDXtitGqHT1ElgWzZHMZIZOQgO8kPmLQn+Qvc1WQj2DfYooSZQodbXjGsdCSMNDrlDDDnVdpyHI3403sn/H9RRQ/4FmjLmjvvaVX6QjkUZoD4ixOSRjPD24seMqwA+xkW2/nQcOQyhJ2K6zEWR7G7M8pL1RZ3ZFs5A5VpY3mzJ45O2nrEJNm7ui7yWcUnZefSE7QzDgmfSXGH3Je13zaQZgEF85YRS8Sa56HAFVIYrffQ== drw@technocore.net
# mira ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPXykZCkTk3iGTRefuj4UbT6IzZPmVyqaDHwLMm6gcC mira@mira
# pavel ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0QFhecujvrFZHQzCpxwkL+XYXo3G2XFF064u9KUN3V pavel
# vlad ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDalZDKboAxWB3pxMR3865i+P+L1bSu8DCTuJ2HOXC8E vlad
while read -r username ssh_key; do
  echo "- - - Adding user $username to memorici.de"
  echo "- - - Key: $key"

    echo "Checking if the user exists"
    doesUserExist=$(ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "if id -u \"$username\" > /dev/null 2>&1; then echo 'ok'; else echo ''; fi")
    if [ -n "$doesUserExist" ]; then
        echo "User $username already exists on memorici.de"
        continue
    fi

    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "sudo useradd -m -s /bin/bash $username" 2>/dev/null
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "sudo mkdir -p /home/$username/.ssh" 2>/dev/null
    # Add the customer's key to `~/.ssh/authorized_keys` on remote
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "sudo bash -c 'echo $key > /home/$username/.ssh/authorized_keys'" 2>/dev/null
    # Add `~/.ssh/id_ed25519.pub` to `~/.ssh/authorized_keys` on remote
    public_key=$(cat ~/.ssh/id_ed25519.pub)
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "sudo bash -c 'echo $public_key >> /home/$username/.ssh/authorized_keys'" 2>/dev/null
    public_key='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKb5AbpG8brcZsMm6iiWgdgq9YSE7Y1sJ6Piz42amB/x sweater@conflagrate-wsl'
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "sudo bash -c 'echo $public_key >> /home/$username/.ssh/authorized_keys'" 2>/dev/null
    # Now chmod 700 /home/$username/.ssh and chmod 600 /home/$username/.ssh/authorized_keys
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "sudo chmod 700 /home/$username/.ssh" 2>/dev/null
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "sudo chown -R $username:$username /home/$username/.ssh" 2>/dev/null
done < users

while read -r username ssh_key; do
    ./mk_gce "$username"
    rsync -Pave ssh "gce.$username.config" $username@memorici.de:
done < users
