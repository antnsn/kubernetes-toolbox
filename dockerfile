# Based on official Azure-cli image
# adds bash curl unzip git make
# installs latest kubectl, kubelogin and k9s
# Able to manage azure kubernetes service out of the box

FROM mcr.microsoft.com/azure-cli

RUN apk add --no-cache bash curl unzip git make ncurses

# kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /bin/kubectl

# kubelogin
RUN curl -LO "https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip"
RUN unzip kubelogin-linux-amd64.zip && cp bin/linux_amd64/kubelogin /bin/kubelogin

# k9s
RUN curl -LO "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_x86_64.tar.gz"
RUN tar zxvf k9s_Linux_x86_64.tar.gz -C /bin

# Helm
Run curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Kubectx
RUN git clone https://github.com/ahmetb/kubectx /root/kubectx
RUN ln -s /root/kubectx/kubectx /bin/kubectx && ln -s /root/kubectx/kubens /bin/kubens
RUN COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
RUN ln -sf /root/.kubectx/completion/kubens.bash $COMPDIR/kubens && ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
RUN echo -e "export PATH=/root/.kubectx:\$PATH" >> /root/.bashrc

# crictl
RUN curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.24.1/crictl-v1.24.1-linux-amd64.tar.gz --output crictl-v1.24.1-linux-amd64.tar.gz
RUN tar zxvf crictl-v1.24.1-linux-amd64.tar.gz -C /bin

# trivy
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /bin

# kube-bench
RUN curl -LO "https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench_0.6.10_linux_amd64.tar.gz"
RUN tar zxvf kube-bench_0.6.10_linux_amd64.tar.gz -C /bin

# krew
RUN (set -x; cd "$(mktemp -d)" && OS="$(uname | tr '[:upper:]' '[:lower:]')" && ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && KREW="krew-${OS}_${ARCH}" && curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && tar zxvf "${KREW}.tar.gz" && ./"${KREW}" install krew)
RUN echo -e 'export PATH=${KREW_ROOT:-$HOME/.krew}/bin:$PATH' >> /root/.bashrc

# Alias
RUN echo -e "\nalias k='kubectl'" >> /root/.bashrc

# Cleanup
RUN rm -f k9s_Linux_x86_64.tar.gz kubelogin-linux-amd64.zip kubectl kube-bench_0.6.10_linux_amd64.tar.gz crictl-v1.24.1-linux-amd64.tar.gz
RUN rm -rf /bin/linux_amd64

EXPOSE 8088 8087 8086 8085
