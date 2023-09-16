# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Update package lists and install required tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    curl \
    unzip \
    git \
    make \
    ncurses-term \
    python3-pip \
    gcc \
    python3-dev \
    libffi-dev \
    libssl-dev \
    cargo && \
    rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install kubelogin
RUN curl -LO "https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip" && \
    unzip kubelogin-linux-amd64.zip && \
    mv bin/linux_amd64/kubelogin /usr/local/bin/kubelogin && \
    rm kubelogin-linux-amd64.zip

# Install k9s
RUN curl -LO "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz" && \
    tar zxvf k9s_Linux_amd64.tar.gz -C /usr/local/bin && \
    rm k9s_Linux_amd64.tar.gz

# Install Helm
RUN curl -LO "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" && \
    chmod 700 get-helm-3 && \
    ./get-helm-3 && \
    rm get-helm-3

# Install Kubectx
RUN git clone https://github.com/ahmetb/kubectx /root/kubectx && \
    ln -s /root/kubectx/kubectx /usr/local/bin/kubectx && \
    ln -s /root/kubectx/kubens /usr/local/bin/kubens && \
    echo -e "export PATH=/root/kubectx:\$PATH" >> /root/.bashrc

# Install crictl
RUN curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.24.1/crictl-v1.24.1-linux-amd64.tar.gz --output crictl-v1.24.1-linux-amd64.tar.gz && \
    tar zxvf crictl-v1.24.1-linux-amd64.tar.gz -C /usr/local/bin && \
    rm crictl-v1.24.1-linux-amd64.tar.gz

# Install trivy
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install kube-bench
RUN curl -LO "https://github.com/aquasecurity/kube-bench/releases/download/v0.6.17/kube-bench_0.6.17_linux_amd64.tar.gz" && \
    tar zxvf kube-bench_0.6.17_linux_amd64.tar.gz -C /usr/local/bin && \
    rm kube-bench_0.6.17_linux_amd64.tar.gz

# Install krew
RUN (set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew) && \
    echo -e 'export PATH=${KREW_ROOT:-$HOME/.krew}/bin:$PATH' >> /root/.bashrc

# Alias
RUN echo -e "\nalias k='kubectl'" >> /root/.bashrc

# Cleanup and remove unnecessary files
RUN apt-get clean && \
    rm -rf /root/kubectx && \
    rm -rf /tmp/*

# Expose necessary ports
EXPOSE 8088 8087 8086 8085

# Entry point or command for your container
CMD ["/bin/bash"]
