# For user (2024)

1. Go to [this thread](https://zulip.memorici.de/#narrow/stream/78-icfpc-2024/topic/SSH.20Keys.20.28to.20access.20large.20VMs.29) and tell me your public key.
2. Copy the keypair you told me about into `~/.ssh/gce` and `~/.ssh/gce.pub`. For example, on my machine, my main key is my gce key (see example)
3. Run `./download_gce_conf $username`, where `$username` is the user name you have noted in the public key you sent to the thread.If you didn't have a name attached to the key, I will use your Zulip handle. If you are confused, look at `users` file in this directory, you should find yourself there.
4. Add line `Include gce.$username.config` (replacing `$username` with your user name) at THE VERY BEGINNING of your `~/.ssh/config`.
5. Bish bash bosh, you sohuld be able to log into our servers.

## Example

```
Fri Jun 28 13:39:40:307096000 sweater@conflagrate ~/github/icfpc-compute (main)
λ cat ~/.ssh/gce.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKb5AbpG8brcZsMm6iiWgdgq9YSE7Y1sJ6Piz42amB/x sweater@conflagrate-wsl
Fri Jun 28 13:39:48:915778300 sweater@conflagrate ~/github/icfpc-compute (main)
λ cat ~/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKb5AbpG8brcZsMm6iiWgdgq9YSE7Y1sJ6Piz42amB/x sweater@conflagrate-wsl
```

# For sysadmin

./provision_users.sh && ./start_all.sh
