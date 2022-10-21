FROM mcr.microsoft.com/azure-cli
RUN apk update
RUN apk add --no-cache bash curl unzip git make
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
RUN curl -LO "https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip"
RUN unzip kubelogin-linux-amd64.zip && cp bin/linux_amd64/kubelogin /bin/kubelogin
RUN curl -LO "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_x86_64.tar.gz"
RUN tar -xf k9s_Linux_x86_64.tar.gz && cp k9s /bin/k9s
