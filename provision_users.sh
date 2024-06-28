#!/usr/bin/env bash

# Format of users in `users` file:
# <username> <ssh-key>
# drw ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGjAMLKOaj6pX75iOHhxWslnPVNr/TVjzJzYFLBEEtvDW7H1dX9Cx5861W1uGT7prHpv0Z67XqvHLJbqRbozgZUvsViIHv+GC9xyznXMxUzn/pROxmqO0jciCzKmYwXBZHI/gheyGzZxg7hc+2cUxL3r+nGJRAnfCHAfQMPKNHT1vmKrDshG3EuZkYw5NoueTwVEwjqyrDkdMy33PMaE6KXsmu/SjoT+wujfei9upUHxxFcPDkO11JTXlhsyaI8ic6+gR8aPmzup8axeQ69YenAwmsUAo/BEnsJyhUcIbNPjD5pV5hsuCBuH4h8ycV/2woefYgjxOZ+uZJ/WY+QzvNkMPH61dB8eDAzOB4eAMA8FJ1E5Mx/cZepX1JVwzfHnTb9g/WL1kxmFUeMiClbAdFBJ919pYTR6tNGB19lOK83+xMcP63XQn3ZbdaPPPAbCDXtitGqHT1ElgWzZHMZIZOQgO8kPmLQn+Qvc1WQj2DfYooSZQodbXjGsdCSMNDrlDDDnVdpyHI3403sn/H9RRQ/4FmjLmjvvaVX6QjkUZoD4ixOSRjPD24seMqwA+xkW2/nQcOQyhJ2K6zEWR7G7M8pL1RZ3ZFs5A5VpY3mzJ45O2nrEJNm7ui7yWcUnZefSE7QzDgmfSXGH3Je13zaQZgEF85YRS8Sa56HAFVIYrffQ== drw@technocore.net
# mira ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPXykZCkTk3iGTRefuj4UbT6IzZPmVyqaDHwLMm6gcC mira@mira
# pavel ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0QFhecujvrFZHQzCpxwkL+XYXo3G2XFF064u9KUN3V pavel
# vlad ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDalZDKboAxWB3pxMR3865i+P+L1bSu8DCTuJ2HOXC8E vlad

# Hosts: icfpc, icfpc-fi
hosts=(instance-20240628-111438)

# For each host and for each user do the following:
# 1. Create user `sudo useradd -m -s /bin/bash -G sudo <username>`
# 2. Add user's ssh key to `~/.ssh/authorized_keys`
# 3. Allow NOPASSWD command invocation for the user
# 4. Add `eval "$(direnv hook bash)"` to `~/.bashrc`
# 5. Copy installer.sh to the host
for host in "${hosts[@]}"; do
  while read -r username key; do
    echo "- - - Adding user $username to $host"
    echo "- - - Key: $key"

    echo "Checking if the user exists"
    doesUserExist=$(ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "if id -u \"$username\" > /dev/null 2>&1; then echo 'ok'; else echo ''; fi")
    if [ -n "$doesUserExist" ]; then
        echo "User $username already exists on $host"
        # continue
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

    # Finally, since we're using `nix`, add 'eval "$(direnv hook bash)"' to `~/.bashrc`
    ## First check if the hook is already in .bashrc
    is_hook_present=$(ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo bash -c 'grep \"eval \\\"\\\$(direnv hook bash)\\\"\" /home/$username/.bashrc'" 2>/dev/null)
    echo "Is hook present: $is_hook_present"
    if [ -z "$is_hook_present" ]; then
      echo "Adding hook to .bashrc"
      ssh -n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host" "sudo bash -c 'echo \"eval \\\"\\\$(direnv hook bash)\\\"\" >> /home/$username/.bashrc'" 2>/dev/null
    fi

  done < users
  rsync -Pave "ssh" installer.sh "$host":
done

# Finally, add a user without sudo rights to memorici.de
# And add `~/.ssh/id_ed25519.pub` to `~/.ssh/authorized_keys` on remote
while read -r username key; do
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
