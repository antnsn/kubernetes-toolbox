# Use ubuntu:23.04 as the base image
FROM ubuntu:23.04

# Update package lists and install required tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    curl \
    unzip \
    git \
    make \
    ncurses-term \
    gcc \
    libffi-dev \
    libssl-dev \
    snapd \ 
    cargo && \
    rm -rf /var/lib/apt/lists/*


# Install Snap
RUN systemctl enable snapd --now

# Install tools using Snap
RUN snap install k9s
RUN snap install kubelogin
RUN snap install helm --classic
RUN snap install kubectx --classic
RUN snap install trivy

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install crictl
RUN curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.24.1/crictl-v1.24.1-linux-amd64.tar.gz --output crictl-v1.24.1-linux-amd64.tar.gz && \
    tar zxvf crictl-v1.24.1-linux-amd64.tar.gz -C /usr/local/bin && \
    rm crictl-v1.24.1-linux-amd64.tar.gz

# Install kube-bench
RUN curl -LO "https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench_0.6.17_linux_amd64.tar.gz" && \
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

RUN echo 'export PATH=$PATH:/snap/bin' >> ~/.bashrc

# Cleanup and remove unnecessary files
RUN apt-get clean && \
    rm -rf /root/kubectx && \
    rm -rf /tmp/*

# Expose necessary ports
EXPOSE 8088 8087 8086 8085

# Entry point or command for your container
CMD ["/bin/bash"]
