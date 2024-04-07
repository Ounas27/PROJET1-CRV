Prérequis

    Cluster Minikube actif

Déploiement Automatique à l'aide d'un script

    Lancez le script bash script.sh : ./script.sh


    Le script configure automatiquement le service Grafana avec un tableau de bord pré-configuré.
    Identifiants pour accéder à Grafana :
        Nom d'utilisateur : admin
        Mot de passe : admin
    L'URL pour accéder au site Web est disponible en HTTP et HTTPS. Il est IMPORTANT de choisir le lien HTTP pour un fonctionnement correct.
    Note : Au démarrage, le tableau de bord Grafana affiche plusieurs graphiques, mais les données /metrics sont vides. Effectuez quelques requêtes sur le site pour les afficher.

Déploiement Manuel

En cas de problème avec le script, suivez ces étapes pour déployer manuellement :

bash

kubectl apply -f redis.yaml
kubectl apply -f nodeJS.yaml
kubectl apply -f frontend.yaml
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml
kubectl apply -f autoScaling.yaml
minikube addons enable metrics-server
minikube tunnel
kubectl get svc

    Copiez l'adresse IP du service node-server-loadbalancer.
    Accédez au pod du frontend avec la commande kubectl exec -it nomDuPod -- /bin/bash, puis éditez le fichier src/conf.js avec l'URL suivante : http://adresseIP_serveurJS:3000, où adresseIP_serveur est l'adresse IP récupérée précédemment.
    À l'intérieur du pod frontend, exécutez tmole 3000 pour créer le tunnel HTTP.
    Dans un autre terminal, lancez Grafana avec minikube service grafana.
