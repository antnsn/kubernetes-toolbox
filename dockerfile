# Use a specific Ubuntu base image
FROM ubuntu:23.10

# Set non-interactive mode for apt-get and other env variables
ENV DEBIAN_FRONTEND=noninteractive KREW_ROOT=/root/.krew

# Update package lists, install required tools and dependencies, and cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash curl ca-certificates unzip git make ncurses-term gcc libffi-dev libssl-dev cargo && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf /tmp/*

# Install various tools
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin && \
    curl -LO "https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip" && \
    unzip kubelogin-linux-amd64.zip && mv bin/linux_amd64/kubelogin /usr/local/bin/kubelogin && rm kubelogin-linux-amd64.zip && \
    curl -LO "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz" && \
    tar zxvf k9s_Linux_amd64.tar.gz -C /usr/local/bin && rm k9s_Linux_amd64.tar.gz && \
    curl -LO "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" && chmod 700 get-helm-3 && ./get-helm-3 && rm get-helm-3 && \
    git clone https://github.com/ahmetb/kubectx /root/kubectx && ln -s /root/kubectx/kubectx /usr/local/bin/kubectx && ln -s /root/kubectx/kubens /usr/local/bin/kubens && \
    curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.24.1/crictl-v1.24.1-linux-amd64.tar.gz --output crictl-v1.24.1-linux-amd64.tar.gz && \
    tar zxvf crictl-v1.24.1-linux-amd64.tar.gz -C /usr/local/bin && rm crictl-v1.24.1-linux-amd64.tar.gz && \
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin && \
    curl -LO "https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench_0.6.17_linux_amd64.tar.gz" && \
    tar zxvf kube-bench_0.6.17_linux_amd64.tar.gz -C /usr/local/bin && rm kube-bench_0.6.17_linux_amd64.tar.gz

# Install krew
RUN (set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew)

# Update bashrc with PATH and aliases
RUN echo -e "export PATH=${KREW_ROOT}/bin:$PATH" >> /root/.bashrc && \
    echo -e "\nalias k='kubectl'" >> /root/.bashrc && \
    echo -e "export PATH=/root/kubectx:\$PATH" >> /root/.bashrc

# Cleanup
RUN rm -rf /root/kubectx

# Entry point or command for your container
CMD ["/bin/bash"]
