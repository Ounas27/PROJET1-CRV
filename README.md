PREREQUIS -
-- Cluster Minikube actif

1 - Pour deployer l'application web sur un cluster minikube, il suffit de lancer le script BASH script.sh ---> ./script.sh
|__ Le script va lancer automatiquement le service grafana avec un tableau de bord pré-configuré. Les identifiants pour accéder à celui-ci sont : username = admin ; password = admin
|__ L'URL permettant d'acceder au site Web est proposé sous deux versions HTTP ET HTTPS : Il est IMPORTANT de choisir le lien HTTP pour que tout fonctionne correctement !!!
|__ NB : A son lancement, le tableau de bord Grafana propose plusieurs graphs mais les données /metrics étant encore vide, il faut réaliser quelques requêtes sur le site pour que ceci s’affichent

 2 - Dans le cas où le script ne fonctionnerait pas vous pouvez suivre la procédure suivante afin de tout déployer manuellement
 |__ kubectl apply -f redis.yaml
 |__ kubectl apply -f nodeJS.yaml
 |__ kubectl apply -f frontend.yaml
 |__ kubectl apply -f prometheus.yaml
 |__ kubectl apply -f grafana.yaml
 |__ kubectl apply -f autoScaling.yaml
 |__ minikube addons enable metrics-server
 |__ minikube tunnel
 |__ kubectl get svc (copier dans un coin l’adresse IP du service node-server-loadbalancer) 
 |__ Rentrer dans le pod du frontend (avec la commande kubectl exec -it nomDuPod -- /bin/bash) puis dans le fichier src/conf.js ecrire l’URL suivante : http://adresseIP_serveurJS:3000 avec adresseIP_serveur = l’adresse IP récupérée à l’étape précédente
 |__ Toujours à l’intérieur du pod frontend, entrer la commande suivante pour créer le tunnel http : tmole 3000 (Il faut choisir le lien HTTP)
 |__ Dans un autre terminal, pour lancer grafana : minikube service grafana


