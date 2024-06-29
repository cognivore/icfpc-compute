# For sysadmin

```
while true; do
    ./start_all.sh && ./provision_users.sh
    sleep 10
done
```

If we're not at the stage where we need heavy lifting:

```
while true; do
    ./start_all.sh --small && ./provision_users.sh --small
    sleep 10
done
```

