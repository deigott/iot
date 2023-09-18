# colors
DARK_GREEN='\e[0;32m'
END='\e[0;m'

# Function to print log messages with color and log level
log() {
  local level="$1"
  local message="$2"
  local color=""
  case "$level" in
    "INFO")
      color="${GREEN}"
      ;;
    "WARNING")
      color="${YELLOW}"
      ;;
    "ERROR")
      color="${RED}"
      ;;
    *)
      color="${NC}"
      ;;
  esac
  echo -e "[${color}${level}${NC}] ${message}"
}

echo "${DARK_GREEN}[DISABLE FIREWALL] : DISABLE FIREWALL...${END}"
systemctl disable firewalld --now

curl -sfL https://get.k3s.io | sh -
sudo k3s kubectl config view --raw | tee ~/.kube/config
chmod 600 ~/.kube/config
export KUBECONFIG=~/.kube/config

echo "${DARK_GREEN}[INSTALL GITLAB - CURL] : CURL...${END}"
kubectl create namespace gitlab
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh && ./get_helm.sh &> /dev/null
helm repo add gitlab https://charts.gitlab.io/ &> /dev/null
helm search repo gitlab &> /dev/null
helm install gitlab gitlab/gitlab \
    --set global.hosts.domain=$DOMAIN \
    --set certmanager-issuer.email=$EMAIL \
    --set global.hosts.https="false" \
    --set global.ingress.configureCertmanager="false" \
    --set gitlab-runner.install="false" \
    --set global.edition=ce \
    -n gitlab &> /dev/null

log "INFO" "GitLab installation initiated."
log "INFO" "Waiting for GitLab to be deployed..."
kubectl wait -n gitlab --for=condition=available deployment --all --timeout=-1s &> /dev/null
log "INFO" "GitLab is deployed and ready."

# Port Forward to Access GitLab UI
log "INFO" "Port forwarding to access GitLab UI..."
GITLAB_PASSWORD=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d)
log "INFO" "GitLab UI is accessible at http://$DOMAIN:1337"
# peut régler certains soucis de ssh etc => c'est évidemment pas une bonne pratique mais ici ça nous permet de contourner des migraines



kubectl port-forward --address 192.168.56.110 svc/gitlab-webservice-default -n gitlab 1337:8181

# # lien pour téléchager notre gitlab
# curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash

# echo "${DARK_GREEN}[INSTALL GITLAB - INSTALL] : GITLAB-CE...${END}"

# # on installe le fichier qu'on vient de curl => en version CE
# yum -y install gitlab-ce

# echo "${DARK_GREEN}[EXTERNAL URL SET UP] : SETTING UP...${END}"

# # Afin d'accéder à notre gitlab depuis notre machine, on vient créer une url externe
# # config.vm.network "forwarded_port", guest: 8181, host: 8181, protocol: "tcp" => lié à ce paramètrage dans notre vagrantfile
# # il suffit de cat /etc/gitlab/gitlab.rb en cas d'erreur pour vérifier que la commande est passée
# # on met en paramètre notre IP instanciée en amont sur notre vagrantfile, ainsi que le port XXXX de guest 
# sudo sed -i 's|external_url \x27http://gitlab.example.com\x27|external_url \x27http://192.168.56.110:8181\x27|g' /etc/gitlab/gitlab.rb 

# echo "${DARK_GREEN}[GITLAB.RB RECONFIGUE] : CONFIG...${END}"

# # nécessité de reconfigurer notre gitlab afin qu'il prenne en compte la modif
# sudo gitlab-ctl reconfigure

# # sudo gitlab-ctl restart
# # sudo gitlab-rake cache:clear => en cas de soucis on peut redémarrer et vider le cache de notre .rb, ça peut parfois bloquer la reconfiguration qu'on a besoin de faire

# echo "${DARK_GREEN}[PASSWORD] : CAT PASSWORD...${END}"
# # afin de se connecter à notre gitlab, on a besoin du mdp associé à notre user : root
# sudo cat /etc/gitlab/initial_root_password