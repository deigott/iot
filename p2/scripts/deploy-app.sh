#!/bin/bash

# Function to check if the ingress is ready
wait_for_ingress() {
    echo "[INFO]  Waiting for ingress..."
    while true; do
        EXTERNAL_IP=$(/usr/local/bin/kubectl get ing app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            break
        fi
        sleep 10
    done
}

# Apply app1 deployment
/usr/local/bin/kubectl apply -f /vagrant/confs/app1-deployment.yaml >> /dev/null && echo "[INFO]  App1 is configured successfully."
/usr/local/bin/kubectl wait deployment app-one --for condition=Available=True --timeout=-1s > /dev/null && echo "[INFO]  App1 is deployed successfully"

# Apply app2 deployment
/usr/local/bin/kubectl apply -f /vagrant/confs/app2-deployment.yaml >> /dev/null && echo "[INFO]  App2 is configured successfully."
/usr/local/bin/kubectl wait deployment app-two --for condition=Available=True --timeout=-1s > /dev/null && echo "[INFO]  App2 is deployed successfully."

# Apply app3 deployment
/usr/local/bin/kubectl apply -f /vagrant/confs/app3-deployment.yaml >> /dev/null && echo "[INFO]  App3 is configured successfully."
/usr/local/bin/kubectl wait deployment app-three --for condition=Available=True --timeout=-1s > /dev/null && echo "[INFO]  App3 is deployed successfully."

# Apply Ingress
/usr/local/bin/kubectl apply -f /vagrant/confs/ingress.yaml && echo "[INFO]  Ingress is configured."

# Call for the function to wait for ingress to be available
wait_for_ingress

# Print Ingress IP
echo "[INFO]  Ingress IP: ${EXTERNAL_IP}"