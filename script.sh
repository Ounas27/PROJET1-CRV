#!/bin/bash

# Fonction pour vérifier si tous les pods sont prêts
wait_for_pods_ready() {
    local resource_type=$1
    local resource_name=$2
    kubectl wait --for=condition=Ready pod -l $resource_type=$resource_name --timeout=300s
}

# Lancement des différents pods et services
kubectl apply -f redis.yaml
kubectl apply -f nodeJS.yaml
kubectl apply -f frontend.yaml
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml
kubectl apply -f autoScaling.yaml

echo "Les pods sont en cours de lancement. Veuillez patientez :)"

wait_for_pods_ready app redis
wait_for_pods_ready app node-server
wait_for_pods_ready app frontend
wait_for_pods_ready app prometheus
wait_for_pods_ready app grafana

# Lancement d'un terminal où un tunnel minikube sera créé
gnome-terminal -- bash -c "minikube tunnel"

echo "Lancement du tunnel minikube... Veuillez entrer votre mot de passe si necessaire dans le terminal qui vient de s'ouvrir !"

SERVICE_NAME="node-server-loadbalancer"

# Boucle qui attend que le tunnel minikube soit créé avant de passer à la suite
while true; do
    SERVICE_INFO=$(kubectl get service "$SERVICE_NAME" -o json)

    EXTERNAL_IP=$(echo "$SERVICE_INFO" | grep -o '"ip":[^,]*' | awk -F '"' '{print $4}')

    if [ -n "$EXTERNAL_IP" ]; then
        echo "Adresse IP externe du service de load balancing des serveurs bien recuperée"
        break
    else
        echo "Adresse IP externe du service de load balancing des serveurs en attente de provisionnement. Veuillez entrer votre mot de passe dans le terminal qui vient de s'ouvrir"
    fi
    sleep 3
done

# On recupère l'adresse IP (external IP) du service loadBalancer des serveurs nodeJS
adresseIP_serveurJS=$(kubectl get svc node-server-loadbalancer -o=jsonpath='{.spec.clusterIP}')

# On construit l'URL d'accès au Backend que l'on va renseigner par la suite dans le frontend
URL="http://$adresseIP_serveurJS:3000"

COMMANDE1="cd src && echo \"export const URL = '$URL'\" > conf.js"
COMMANDE2="tmole 3000"

# On recupère le nom du pod frontend
nomPod=$(kubectl get pods -l app="frontend" -o jsonpath='{.items[0].metadata.name}')

# On rentre dans le pod frontend et on execute la commande "COMMANDE1" qui va permettre de modifier l'URL d'accès au backend
kubectl exec -it "$nomPod" -- /bin/bash -c "$COMMANDE1"

echo " "
echo "Lancement du tableau de bord grafana relié à grafana :"

# Lancement sur le navigateur de Grafana
minikube service grafana

# Activation des addons nécessaire pour utiliser l'auto-scaling
minikube addons enable metrics-server

echo " "
echo -e "\033[1mCi-dessous les url permettant d'acceder au frontend du site. Afin que tout fonctionne sans encombre, veuillez cliquez sur le premier lien http et pas celui https :\033[0m"
echo " "

# On rentre dans le pod frontend et on execute la commande "COMMANDE2" afin de créer le tunnel HTTP
kubectl exec -it "$nomPod" -- /bin/bash -c "$COMMANDE2"


