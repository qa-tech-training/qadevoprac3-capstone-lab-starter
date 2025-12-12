sudo useradd -m -s /bin/bash student
apt-get update
apt-get install -y git nfs-common
curl -sfL https://get.k3s.io | sh -
mkdir -p /home/student/.kube
cp /etc/rancher/k3s/k3s.yaml /home/student/.kube/config
chown -R student:student /home/student/.kube
printf "\nexport KUBECONFIG=~/.kube/config\n" | tee -a /home/student/.bashrc
mkdir /mnt/k3s
sleep 60
mount $NfsPublicIp:/opt/sfw /mnt/k3s
cp /var/lib/rancher/k3s/server/node-token /mnt/k3s/node-token
chmod a+r /mnt/k3s/node-token
wget https://get.helm.sh/helm-v3.18.3-linux-amd64.tar.gz
tar xvf helm-v3.18.3-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin
rm -rf linux-amd64
wget https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment \
  metrics-server --namespace kube-system \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
