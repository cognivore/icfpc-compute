#!/usr/bin/env bash

# Format of users in `users` file:
# <username> <ssh-key>
# drw ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGjAMLKOaj6pX75iOHhxWslnPVNr/TVjzJzYFLBEEtvDW7H1dX9Cx5861W1uGT7prHpv0Z67XqvHLJbqRbozgZUvsViIHv+GC9xyznXMxUzn/pROxmqO0jciCzKmYwXBZHI/gheyGzZxg7hc+2cUxL3r+nGJRAnfCHAfQMPKNHT1vmKrDshG3EuZkYw5NoueTwVEwjqyrDkdMy33PMaE6KXsmu/SjoT+wujfei9upUHxxFcPDkO11JTXlhsyaI8ic6+gR8aPmzup8axeQ69YenAwmsUAo/BEnsJyhUcIbNPjD5pV5hsuCBuH4h8ycV/2woefYgjxOZ+uZJ/WY+QzvNkMPH61dB8eDAzOB4eAMA8FJ1E5Mx/cZepX1JVwzfHnTb9g/WL1kxmFUeMiClbAdFBJ919pYTR6tNGB19lOK83+xMcP63XQn3ZbdaPPPAbCDXtitGqHT1ElgWzZHMZIZOQgO8kPmLQn+Qvc1WQj2DfYooSZQodbXjGsdCSMNDrlDDDnVdpyHI3403sn/H9RRQ/4FmjLmjvvaVX6QjkUZoD4ixOSRjPD24seMqwA+xkW2/nQcOQyhJ2K6zEWR7G7M8pL1RZ3ZFs5A5VpY3mzJ45O2nrEJNm7ui7yWcUnZefSE7QzDgmfSXGH3Je13zaQZgEF85YRS8Sa56HAFVIYrffQ== drw@technocore.net
# mira ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPXykZCkTk3iGTRefuj4UbT6IzZPmVyqaDHwLMm6gcC mira@mira
# pavel ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0QFhecujvrFZHQzCpxwkL+XYXo3G2XFF064u9KUN3V pavel
# vlad ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDalZDKboAxWB3pxMR3865i+P+L1bSu8DCTuJ2HOXC8E vlad

# GCLOUD OUTPUT:
# λ gcloud compute instances list
# NAME             ZONE             MACHINE_TYPE     PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
# icfpc-hel        us-central1-a    n2d-highcpu-128  true         10.128.0.9                TERMINATED
# icfpc-leviathan  us-central1-a    n2d-highcpu-128  true         10.128.0.8                TERMINATED
# icfpc-32-1       europe-north1-a  n2d-highcpu-32   true         10.166.0.4                TERMINATED
# icfpc-32-2       europe-north1-a  n2d-highcpu-32   true         10.166.0.5                TERMINATED
# icfpc-komodo     europe-north1-a  n2d-highcpu-128  true         10.166.0.7                TERMINATED

# hosts=(icfpc-32-1 icfpc-32-2 icfpc-hel icfpc-komodo icfpc-leviathan)
hosts=(icfpc-32-1)

repo="git@github.com:Vlad-Shcherbina/icfpc2024-tbd.git"
project_dir="icfpc2024-tbd"

for host in "${hosts[@]}"; do
    echo $host
    while read -r line; do
        username=$(echo $line | awk '{print $1}')
        key=$(echo "$line" | cut -d' ' -f2-)
        echo "Username: $username"
        echo "Key: $key"
    done < users
done

# exit 1

# For each host and for each user do the following:
# 1. Create user `sudo useradd -m -s /bin/bash -G sudo <username>`
# 2. Add user's ssh key to `~/.ssh/authorized_keys`
# 3. Allow NOPASSWD command invocation for the user
# 4. Add `eval "$(direnv hook bash)"` to `~/.bashrc`
# 5. Copy installer.sh to the host
for host in "${hosts[@]}"; do
  ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo apt-get update && sudo apt install curl" 2>/dev/null
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "bash -s" < ./install_nix_over_ssh.sh
  while read -r line; do
    username=$(echo $line | awk '{print $1}')
    key=$(echo "$line" | cut -d' ' -f2-)

    echo "- - - Adding user $username to $host"
    echo "- - - Key: $key"

    echo "Checking if the user exists"
    doesUserExist=$(ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "if id -u \"$username\" > /dev/null 2>&1; then echo 'ok'; else echo ''; fi")
    if [ -n "$doesUserExist" ]; then
        echo "User $username already exists on $host"
    fi

    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo useradd -m -s /bin/bash -G sudo $username" 2>/dev/null
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo mkdir -p /home/$username/.ssh" 2>/dev/null
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo bash -c 'echo $key > /home/$username/.ssh/authorized_keys'" 2>/dev/null
    public_key=$(cat ~/.ssh/id_ed25519.pub)
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo bash -c 'echo $public_key >> /home/$username/.ssh/authorized_keys'" 2>/dev/null
    public_key='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKb5AbpG8brcZsMm6iiWgdgq9YSE7Y1sJ6Piz42amB/x sweater@conflagrate-wsl'
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null memorici.de "sudo bash -c 'echo $public_key >> /home/$username/.ssh/authorized_keys'" 2>/dev/null
    # Now chmod 700 /home/$username/.ssh and chmod 600 /home/$username/.ssh/authorized_keys
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo chmod 700 /home/$username/.ssh" 2>/dev/null
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo chown -R $username:$username /home/$username/.ssh" 2>/dev/null
    # Now we need to enable NOPASSWD for the user
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo bash -c 'echo \"$username ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers'" 2>/dev/null

    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$username@$host" "bash -s" < ./install_direnv_over_ssh.sh
    # Finally, since we're using `nix`, add 'eval "$(direnv hook bash)"' to `~/.bashrc`
    ## First check if the hook is already in .bashrc
    is_hook_present=$(ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo bash -c 'grep \"eval \\\"\\\$(direnv hook bash)\\\"\" /home/$username/.bashrc'" 2>/dev/null)
    echo "Is hook present: $is_hook_present"
    if [ -z "$is_hook_present" ]; then
      echo "Adding hook to .bashrc"
      ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$username@$host" "bash -c 'echo \"eval \\\"\\\$(direnv hook bash)\\\"\" >> /home/$username/.bashrc'" 2>/dev/null
    fi

    # Memorize current directory
    current_dir=$(pwd)

    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$username@$host" "mkdir -p /home/$username/repo" 2>/dev/null
    [ -d /tmp/repo ] && (cd /tmp/repo && git pull) || (git clone "$repo" /tmp/repo && cd /tmp/repo && echo -e '#!/bin/sh\n\nexec git_hooks/pre-push "$@"' > .git/hooks/pre-push && chmod +x .git/hooks/pre-push)

    cd $current_dir

    echo "rsync -avz --filter=':- .gitignore' -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" /tmp/repo/ \"$username@$host\":\"/home/$username/repo/$project_dir\""
    rsync -avz --filter=':- .gitignore' -e "ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" /tmp/repo/ "$username@$host":"/home/$username/repo/$project_dir"
    # Direnv allow
    ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$username@$host" "bash -c 'source /etc/profile && source /home/$username/.bashrc && direnv --version && cd /home/$username/repo/$project_dir && direnv allow && nix develop . --command cargo test && nix develop . --command tsc'"

  done < users
done
