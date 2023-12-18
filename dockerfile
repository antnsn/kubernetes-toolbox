# Use a specific debian base image
FROM debian:stable-slim

# Set non-interactive mode for apt-get and other env variables
ENV DEBIAN_FRONTEND=noninteractive \
    kube_bench_version=0.6.19 \
    crictl_version=1.29.0 \
    trivy_version=0.18.3

# Update package lists, install required tools and dependencies, and cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash curl ca-certificates unzip git make ncurses-term gcc libffi-dev libssl-dev cargo wget apt-transport-https gnupg lsb-release && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf /tmp/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin

# Install kubelogin
RUN curl -LO "https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip" && \
    unzip kubelogin-linux-amd64.zip && mv bin/linux_amd64/kubelogin /usr/local/bin/kubelogin && rm kubelogin-linux-amd64.zip 
    
# Install k9s    
RUN curl -LO "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz" && \
    tar zxvf k9s_Linux_amd64.tar.gz -C /usr/local/bin && rm k9s_Linux_amd64.tar.gz 

# Install helm    
RUN curl -LO "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" && chmod 700 get-helm-3 && ./get-helm-3 && rm get-helm-3 && \
    git clone https://github.com/ahmetb/kubectx /root/kubectx && ln -s /root/kubectx/kubectx /usr/local/bin/kubectx && ln -s /root/kubectx/kubens /usr/local/bin/kubens
    
# Install crictl    
RUN curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v${crictl_version}/crictl-v${crictl_version}-linux-amd64.tar.gz --output crictl-v${crictl_version}-linux-amd64.tar.gz && \
    tar zxvf crictl-v${crictl_version}-linux-amd64.tar.gz -C /usr/local/bin && rm crictl-v${crictl_version}-linux-amd64.tar.gz
    
# Install trivy    
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v${trivy_version}
   
    
# Install kube-bench    
RUN curl -LO "https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench_${kube_bench_version}_linux_amd64.tar.gz" && \
    tar zxvf kube-bench_${kube_bench_version}_linux_amd64.tar.gz -C /usr/local/bin && rm kube-bench_${kube_bench_version}_linux_amd64.tar.gz


# Create a user named 'k8s-toolbox' with UID 1000
RUN useradd -u 1000 -m -s /bin/bash k8s-toolbox
RUN touch /home/k8s-toolbox/.bashrc
RUN chown -R k8s-toolbox:k8s-toolbox /home/k8s-toolbox

# Update bashrc with PATH and aliases
RUN echo "\nexport PATH=/root/kubectx:\$PATH" >> /root/.bashrc && \
    echo "\nalias k='kubectl'" >> /root/.bashrc && \
    echo "\nexport PATH=/root/kubectx:\$PATH" >> /home/k8s-toolbox/.bashrc && \
    echo "\nalias k='kubectl'" >> /home/k8s-toolbox/.bashrc



# Cleanup
RUN rm -rf /root/kubectx

# Entry point or command for your container
CMD ["tail", "-f", "/dev/null"]

# Switch to the newly created user
USER k8s-toolbox
SHELL ["/bin/bash", "-c"]
