## example for vm named "windows-11" in "default" namespace

```sh
docker run -it --rm --name kubevirt console -v ~/.kube/config:~/.kube/config --entrypoint "" aarto/kubevirt-console:1.4.0-alpine sh

kubectl proxy --address=[::] --port=9000 --accept-hosts=^.*$ --www=/app/ --www-prefix=/ --api-prefix=/k8s/
```

browse to

http://localhost:9000/k8s/apis/kubevirt.io/v1/namespaces/default/virtualmachineinstances
http://localhost:9000/window.html?path=k8s/apis/subresources.kubevirt.io/v1/namespaces/default/virtualmachineinstances/windows-11/vnc

## manifest

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: kubevirt-console

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubevirt-console-sa
  namespace: kubevirt-console

---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kubevirt-console
rules:
  - apiGroups:
      - subresources.kubevirt.io
    resources:
      - virtualmachineinstances/console
      - virtualmachineinstances/vnc
    verbs:
      - get
  - apiGroups:
      - kubevirt.io
    resources:
      - virtualmachines
      - virtualmachineinstances
      - virtualmachineinstancepresets
      - virtualmachineinstancereplicasets
      - virtualmachineinstancemigrations
    verbs:
      - get
      - list
      - watch

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kubevirt-console-role-binding
subjects:
  - kind: ServiceAccount
    name: kubevirt-console-sa
    namespace: kubevirt-console
roleRef:
  kind: ClusterRole
  name: kubevirt-console
  apiGroup: rbac.authorization.k8s.io

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kubevirt-console
  name: kubevirt-console
  namespace: kubevirt-console
spec:
  ports:
    - port: 9000
  selector:
    app: kubevirt-console

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubevirt-console-deploy
  namespace: kubevirt-console
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kubevirt-console
  template:
    metadata:
      labels:
        app: kubevirt-console
    spec:
      serviceAccountName: kubevirt-console-sa
      containers:
        - name: novnc
          image: aarto/kubevirt-console:1.4.0-alpine
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
          ports:
            - containerPort: 9000
              name: http
          livenessProbe:
            httpGet:
              port: 9000
              path: /
              scheme: HTTP
            failureThreshold: 30
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 5
```

## expose svc

```sh
kubectl -n kubevirt-console port-forward svc/kubevirt-console 3000:9000
```

browse to http://localhost:9000/?namespace=default
