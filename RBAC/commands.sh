openssl genrsa -out user1.key 2048
openssl req -new -key user1.key -out user1.csr -subj "/CN=user1/O=group1"
ls ~/.minikube/ # check that the files ca.crt and ca.key exists in this location.
openssl x509 -req -in user1.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out user1.crt -days 500
openssl x509 -in user1.crt -text -noout

# Set a user entry in kubeconfig
kubectl config set-credentials user1 --client-certificate=user1.crt --client-key=user1.key

# Set a context entry in kubeconfig
kubectl config set-context user1-context --cluster=minikube --user=user1

kubectl config view

# Switching to the created user
kubectl config use-context user1-context
kubectl config current-context

kubectl config use-context minikube


# Grant access to the user
1. Create a Role


cat <<EOF > role.yml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
EOF


2.  Create a BindingRole
cat <<EOF > role-binding.yml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: user1 # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # must match the name of the Role
  apiGroup: rbac.authorization.k8s.io
EOF