FROM centos:7.6.1810

ARG KUBECTL_VERSION=1.15.0
COPY kubernetes.repo /etc/yum.repos.d
RUN yum install -y epel-release && \
  yum install -y kubectl-${KUBECTL_VERSION} openssl jq

COPY docker-entrypoint.sh /
ENTRYPOINT /docker-entrypoint.sh
RUN mkdir -p /etc/helm/pki
WORKDIR /etc/helm/pki
