# Kubernetes 102

_from "Hello World" to the real world_

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

---

### Inside a Secret

Contents base64-encoded, not safe for git:

```yaml
# web-env.yml
apiVersion: v1
kind: Secret
metadata:
  name: web-env
data:
  DATABASE_URL: cG9zdGdyZXM6Ly9sYXVuY2hwYWQ6dG9wc2VjcmV0QGRhdGFiYXNlL2xhdW5jaHBhZA==
  RAILS_MASTER_KEY: OGJkOWYzNDY4ZDMxZjU2ZjhjZjIzYTk1MjA5OWY5NmI=
```

---

### Inside a SealedSecret

```txt
$ kubeseal -o yaml < web-env.yml > web-env-sealed.yml
```

Contents encrypted, safe for git:

```yaml
# web-env-sealed.yml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: web-env
spec:
  encryptedData:
    DATABASE_URL: AgCJLkXEOXiNKqEbgPotvNEIWbYAwewJMMWnhoiC4WqZjRiRjmJz8wyjTYPWtDGAnmgxbqnDRMGTehcLmnT5Vk1l+1bunM0dujd7nx0bTV3vH83BiiD8fRy5TYGjEyMwLTgs3IkgOcR9W3V81wVlCHKZCaNzwpYUImDagGeZho6jM6k5+KR4goZkOf4vaN8hczJJBvEcDbZpizSW4fqAYUnBkA4EI/TbziISF8C4/jvF8yh1AsQZNq3oe0cNk3sAYg8vvuMkoEec1QLDJKBiJB/HUMvxhGJLC9iGh5OvQMN9ZlJub6uzC5KFukOKiuGdlP7/FgeXb1ORA7xsJM0cb4Sv1ctwXUNYYI0AQuJFbxGCFVXfy9mAqG533ZOdeWCnTqxjzaGW8Mvd3sHzR2sKsibeCuoIr7VR4MkewPEc3+u/OZloQcmoxJ/BpmECDi7CyiyFUnrkpGJj08JSnLBu9791w8CtmFfGOCopabkJicqUU62L/JynPwKtSfUx0SMrNgHs5ufVWKk8wQnis8ipkOxPxtCWMZi77ojwXfbB04CRMDFO9IYzg0JarDkZs2mBThRIV8i5vPG0paNF8ZHc4iko2kT5QG/lP3y9EAov9darhqOoiCb8G61msi6ZrOI++rLZuRVijKF2Am2hAx9ttBQPPKyi4h1zBojRxWvGkMsAufTvUw7Bl4nkxMGkswwyzkTiJ6HKa9p+qsyQXRALFvLNkxBs4fzfBACh2yX8CI9xv3SeDi0hXL+DyN5/agmofRp2
    RAILS_MASTER_KEY: AgC1YY8XLUfbDP6hSDq54NBgWx6Gu4m11JDFL5MQH44T/yAI/SvFUj63VZR7EBc86IsyVVZo3QYQOX2OrBgNYk2/yAaBkYIoqNNWSIcjxH2OKDp6jjX7+2HFgQwt+izDlRetGHa7WutF07D7FhwVAakRxYQ+W1nvFFLBb7Wv83cNUPSfa5XPYb5LxxHxPAqu02ZK+FkakXEizRsdCDry5+FHpcKtwHMB81pWvepLHkYhMsQv3I1EKdluOqqZuNti/t5H/iIBmEEjV6UbH1aGrqwVXZCuD/wZwxpQtNWJkO5bDP9OGTM/d4HcV/27np/7RhFyuI+4c6hNNIxA+N9HffqkMImWsmz1NCGiqj0gMv6NJxZ+OR+UF7Q/J6AtGhOkpSInBeYj/vJNp6q2RUVcourlku7M82vVDc5UeiEfnBq9a4eMqKnK8Jk0Alz5MLA6WIaHgHIXWYFKBuV2BnklyGrkdPqZvhYspXcX91EIaReAEVL74depiB4EtgMJuKyl8UQmKEZwqJy34Y7sSK1kfXIb5OkZPUEWeaQ2Qbw3Iw1+T3NhdjMjmChDcySup9A3HdBjSoLOPjh8wxdf2jeK2BII2ymivgIsm7B7vIxMZeD5/d2I4bbkcerKOdhvVcu4mHccs0oL4uImdwrbheO9Ue65Jpf/eHUo1SCWCUyIJUE6io9sWA+FRmYksS5/T5B3VG/dx2U8QBoZjZBaC/1jjOMsuO/gel6LASI3Rs8MFTy9aQ==
```

---

## Updating Pods

- Only some fields can be updated
- Pod is restarted
- There must be a better way...

---

## Deployment

* Manages Pods for you
* Simplifies updates
* Automates scaling

---

## Create a Deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: web
  template:
    # Blueprint for the pod goes here.
```

---

## Scale Deployment

```sh
$ kubectl scale deployment web --replicas 2
```

---

## Update Deployment

```sh
# Update image
$ kubectl set image \
    deployment web \
    web=czak/launchpad:v2 \
    --record
```

```sh
# Roll back to previous version
$ kubectl rollout history \
    deployment web
```

---

## Automate with GitHub

* Create a restricted user for GitHub
* Trigger rollout from a GitHub action
