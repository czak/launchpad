Pods expect `database-env` and `web-env` secrets:

```sh
kubectl create secret generic \
  database-env \
  --from-literal=POSTGRES_DB=launchpad \
  --from-literal=POSTGRES_USER=launchpad \
  --from-literal=POSTGRES_PASSWORD=topsecret
```

```sh
kubectl create secret generic \
  web-env \
  --from-literal=RAILS_MASTER_KEY=<SEE app/config/master.key> \
  --from-literal=DATABASE_URL=postgres://launchpad:topsecret@database/launchpad \
```
