# Kubernetes 102

_from getting started to the real world_

---

## Where we are

* Launched a few Pods: `database`, `web`, `worker`
* Defined a `database` Service
* Defined a `web` Service and Ingress

---

## Where we want to be

* Commit infrastructure files to repo, safely
* Update the deployed app, securely
* Automate deployments

---

## New resources

* `Secret` - store and manage sensitive information
* `SealedSecret` - safe way to store secrets in git
* `Deployment` - manage Pods, simplify updates & scaling

---

## Create a secret

```txt
$ kubectl create secret generic \
  database-env \
  --from-literal=POSTGRES_DB=launchpad \
  --from-literal=POSTGRES_USER=launchpad \
  --from-literal=POSTGRES_PASSWORD=topsecret
```

---

## Use secret in a Pod

Before:

```yaml
env:
  - name: POSTGRES_DB
    value: launchpad
  - name: POSTGRES_USER
    value: launchpad
  - name: POSTGRES_PASSWORD
    value: topsecret
```

After:

```yaml
envFrom:
  - secretRef:
      name: database-env
```
