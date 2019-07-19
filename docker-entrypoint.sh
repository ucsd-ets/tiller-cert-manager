#!/bin/bash -x
# ca
if [ ! -f ca.key.pem ]; then
  openssl genrsa -out ./ca.key.pem 4096
fi

if [ ! -f ca.cert.pem ]; then
  openssl req -key ca.key.pem -new -x509 -days 7300 -sha256 -out ca.cert.pem -extensions v3_ca -subj "/CN=helm-ca"
fi

# tiller key
openssl genrsa -out ./tiller.key.pem 4096
openssl req -key tiller.key.pem -new -sha256 -out tiller.csr.pem -subj "/CN=tiller-server"
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in tiller.csr.pem -out tiller.cert.pem -days 365

# client key
openssl genrsa -out ./helm.key.pem 4096
openssl req -key helm.key.pem -new -sha256 -out helm.csr.pem -subj "/CN=tiller-user"
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in helm.csr.pem -out helm.cert.pem  -days 365


export CA_CERT=$(base64 < "./ca.cert.pem" | tr -d '\n')
export TLS_KEY=$(base64 < "./tiller.key.pem" | tr -d '\n')
export TLS_CERT=$(base64 < "./tiller.cert.pem" | tr -d '\n')

kubectl get secrets -n kube-system tiller-secret -o json | \
  jq '.data["ca.crt"] |= env.CA_CERT' | \
  jq '.data["tls.key"] |= env.TLS_KEY' | \
  jq '.data["tls.crt"] |= env.TLS_CERT' | \
  kubectl apply -f -
