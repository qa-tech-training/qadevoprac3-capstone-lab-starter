sleep 90
apt-get update
apt-get install -y git nfs-common
mkdir /mnt/k3s
mount $NfsPublicIp:/opt/sfw /mnt/k3s
curl -sfL https://get.k3s.io | K3S_URL=https://$K3sPublicIp:6443 K3S_TOKEN=$(cat /mnt/k3s/node-token) sh -