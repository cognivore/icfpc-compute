# For user (2024)

Compute allows you to run cargo commands from the main repository **on powerful remote machines** like this:

```
echo 'B$ L! B$ v! I" L! B+ B+ v! v! B+ v! v!' | \
  ./run_at icfpc-32-1 'cargo run --release expr_eval'
```

## How do I gain access to the machines?

1. Go to [this thread](https://zulip.memorici.de/#narrow/stream/78-icfpc-2024/topic/SSH.20Keys.20.28to.20access.20large.20VMs.29) and tell me your public key.
2. Copy the keypair you told me about into `~/.ssh/gce` and `~/.ssh/gce.pub`. For example, on my machine, my main key is my gce key.
3. Run `./download_gce_conf $username` server†, where `$username` is the user name you have noted in the public key you sent to the thread.If you didn't have a name attached to the key, I will use your Zulip handle. If you are confused, look at `users` file in this directory, you should find yourself there.
4. Add line `Include gce.$username.config` (replacing `$username` with your user name) at THE VERY BEGINNING of your `~/.ssh/config`.
5. Bish bash bosh, you sohuld be able to log into our servers. But also, you can just [evaluate arbitrary payload on the server](https://github.com/Vlad-Shcherbina/icfpc2024-tbd/blob/main/run_at) without thinking about SSH and stuff.

## †: Why do I have to keep running `download_gce_conf`?!

Because we're running our VMs in a mode where Google can interrupt them **at any point**.
It also means that IP addresses of the VMs can change.
I also may want to add MOAR COMPUTE for you to enjoy at some point during the contest.

So don't slack, run `download_gce_conf` continuously in a screen session or a tmux session.
And don't forget to start it when you reboot your computer :)
