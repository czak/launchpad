# Kubernetes 101

_from zero to cluster in 30 minutes or less_

---

## Why?

* Connect Native: 2 processes + 1 db
* Standardized way to *orchestrate* systems
* Getting easier and cheaper to start

---

## Program

1. Demo app
2. Quick intro to Kubernetes
3. Live hacking

---

## Demo: Launchpad

* Preview upcoming SpaceX launch
* 2 Rails processes
* 1 Postgres DB

---

## Kubernetes

* System to automate deployments
* Keeps processes running on servers
* Simplifies connecting them together
* Standardized way to define infrastructure as code

---

## Resources

<dl>
<dt><code>Pod</code></dt>
<dd>akin to Docker container</dd>

<dt><code>Service</code></dt>
<dd>name things for discovery in cluster, expose ports</dd>

<dt><code>Ingress</code></dt>
<dd>expose HTTP services to outside world</dd>

<dt><code>Secret</code></dt>
<dd>store sensitive data (passwords, api keys, env variables)</dd>
</dl>

---

## Key pieces

<dl>
<dt><code>kubectl</code></dt>
<dd>command-line program to interact with cluster</dd>

<dt><code>kubeconfig</code></dt>
<dd>configuration/credential file from cloud provider</dd>
</dl>

---

## Disclaimer

* Simplicity first, not best practices
* My goal for this

---

# Hacking

---

## kubeconfig

Goes in `~/.kube/config`

```sh
$ kubectl config use-context launchpad-staging
```

```sh
$ kubectl config use-context launchpad-production
```

---

## View resources in cluster

```sh
$ kubectl get pods,services,ingresses
```

```sh
$ kubectl get all
```

---

## Run first pod

```sh
$ kubectl run web \
    --image=czak/launchpad \
    --env=RAILS_ENV=production \
    --env=RAILS_LOG_TO_STDOUT=true \
    --env=RAILS_SERVE_STATIC_FILES=true \
    --env=RAILS_MASTER_KEY=8bd9f3468d31f56f8cf23a952099f96b \
    --env=DATABASE_URL=postgres://launchpad:topsecret@database/launchpad \
    -- \
    bin/rails server
```

---

## Connect to pod

```txt
$ kubectl exec -it web -- bin/rails console
```

---

## Connect to pod pt. 2

```txt
$ kubectl port-forward web 3000
```

---

## Pod in YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    app: web
spec:
  containers:
    - name: web
      image: czak/launchpad
      command: ["bin/rails", "server"]
      env:
        - name: RAILS_ENV
          value: production
        - name: RAILS_LOG_TO_STDOUT
          value: "true"
        - name: RAILS_SERVE_STATIC_FILES
          value: "true"
        - name: RAILS_MASTER_KEY
          value: 8bd9f3468d31f56f8cf23a952099f96b
        - name: DATABASE_URL
          value: postgres://launchpad:topsecret@database/launchpad
```

---

## Run pod from YAML

```txt
$ kubectl apply -f web.yml
```

---

## Check logs

```txt
$ kubectl logs web
```

---

## Run more pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database
  labels:
    app: database
spec:
  containers:
    - name: database
      image: postgres:13-alpine
      env:
        - name: POSTGRES_DB
          value: launchpad
        - name: POSTGRES_USER
          value: launchpad
        - name: POSTGRES_PASSWORD
          value: topsecret
```

---

## Declare database Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: database
spec:
  selector:
    app: database
  ports:
    - port: 5432
```

---

## web 🠒 database

```txt
$ kubectl exec web -- bin/rails db:migrate
```

---

## Declare web Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
    - port: 3000
```

---

## Expose web service via Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
spec:
  rules:
    - host: launchpad-staging.czak.pl
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 3000
```

---

## Run worker Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: worker
spec:
  containers:
    - name: worker
      image: czak/launchpad
      command: ["bin/rails", "runner", "bin/worker.rb"]
      env:
        - name: RAILS_ENV
          value: production
        - name: RAILS_LOG_TO_STDOUT
          value: "true"
        - name: RAILS_SERVE_STATIC_FILES
          value: "true"
        - name: RAILS_MASTER_KEY
          value: 8bd9f3468d31f56f8cf23a952099f96b
        - name: DATABASE_URL
          value: postgres://launchpad:topsecret@database/launchpad
```

---

## Deploy to production

```txt
$ kubectl config use-context launchpad-production
$ kubectl apply -f production/
$ kubectl exec web -- bin/rails db:migrate
```

---

## Web secrets

```sh
# secrets/web.env
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
RAILS_MASTER_KEY=8bd9f3468d31f56f8cf23a952099f96b
DATABASE_URL=postgres://launchpad:topsecret@database/launchpad
```

```txt
$ kubectl create secret generic web-env \
    --from-env-file secrets/web.env
```

---

## Use secret to populate env

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    app: web
spec:
  containers:
    - name: web
      image: czak/launchpad
      command: ["bin/rails", "server"]
      envFrom:
        - secretRef:
            name: web-env
```

---

## Database secrets 

```sh
# secrets/database.env
POSTGRES_DB=launchpad
POSTGRES_USER=launchpad
POSTGRES_PASSWORD=topsecret
```

```txt
$ kubectl create secret generic database-env \
    --from-env-file secrets/database.env
```

---

## Use secret to populate env

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database
  labels:
    app: database
spec:
  containers:
    - name: database
      image: postgres:13-alpine
      envFrom:
        - secretRef:
            name: database-env
```
