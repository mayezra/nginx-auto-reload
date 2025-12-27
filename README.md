# NGINX Auto-Reload with Kubernetes Sidecar Pattern

Automatic zero-downtime NGINX configuration updates using Kubernetes ConfigMaps and a sidecar watcher container.

##  What This Does

- Runs NGINX web server in Kubernetes
- Monitors nginx.conf for changes
- Automatically reloads NGINX when config updates
- Zero downtime - no service interruption
- Validates config before applying

##  Architecture
```
Pod
├── NGINX Container (serves web traffic)
└── Watcher Container (monitors config, triggers reload)
```

##  Components

- **nginx.conf** - NGINX configuration file
- **watcher.sh** - Monitoring script that detects changes
- **nginx-deployment.yaml** - Kubernetes deployment definition
- ConfigMaps for storing configs
- Service for network access

##  Quick Start

### Prerequisites

- Kubernetes cluster (minikube, k3s, or cloud)
- kubectl configured

### Deploy

1. Create namespace:
```bash
kubectl create namespace nginx-sidecar
```

2. Create ConfigMaps:
kubectl create configmap nginx-config --from-file=nginx.conf -n nginx-sidecar
kubectl create configmap watcher-script --from-file=watcher.sh -n nginx-sidecar
```
3. Deploy:
kubectl apply -f nginx-deployment.yaml
```
4. Test:
# Get service URL (if using minikube)
minikube service nginx-service -n nginx-sidecar --url

# Or use NodePort
curl http://<NODE_IP>:30080/

## 🔄 Update Configuration

Update nginx.conf and apply:
```bash
kubectl create configmap nginx-config \
  --from-file=nginx.conf \
  -n nginx-sidecar \
  --dry-run=client -o yaml | kubectl apply -f -
```

NGINX will automatically reload in ~60-70 seconds with zero downtime!

## 🎓 How It Works

1. **ConfigMap Update**: You update nginx-config ConfigMap
2. **Kubelet Sync**: Kubernetes syncs file to Pod (~60s)
3. **Change Detection**: Watcher detects MD5 checksum change
4. **Validation**: Watcher validates config with `nginx -t`
5. **Reload**: Watcher sends `kill -HUP` to NGINX
6. **Zero Downtime**: NGINX gracefully reloads configuration
