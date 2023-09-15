
## Dockerfile for Azure CLI and Kubernetes Tools
This Dockerfile builds a Docker image containing Azure CLI and various Kubernetes tools. It uses a multi-stage build to keep the final image size small.

[![Docker Publish](https://github.com/antnsn/kube-mgmt/actions/workflows/build.yml/badge.svg)](https://github.com/antnsn/kube-mgmt/actions/workflows/build.yml)

### Building the Docker Image
To build the Docker image, navigate to the directory containing the Dockerfile and run the following command:

```bash
docker build -t kube-mgmt .
```

### Pulling the container from ghcr

To pull a Docker image from a container registry, you can use the `docker pull` command. In your case, you want to pull an image from the GitHub Container Registry (GHCR). Here's how you can do it:

```bash
docker pull ghcr.io/antnsn/kube-mgmt:latest
```


### Running a Container
Once the image is built, you can run a container using the following command:
```bash
docker run -it kube-mgmt
```
This will start an interactive shell in the container, allowing you to use Azure CLI and Kubernetes tools.





This command will fetch the `kube-mgmt` image from the `ghcr.io/antnsn` repository with the `latest` tag.


## Tools Included
The Docker image includes the following tools:

 - Azure CLI
 - kubectl
 - kubelogin 
 - k9s
 - Helm
 - Kubectx
 - crictl
 - trivy
 - kube-bench 
 - krew

### Exposed Ports
The Docker image exposes the following ports, which you can use for your applications:

 - 8088
 - 8087
 - 8086
 - 8085

### Customization
You can customize this Dockerfile to add or remove specific tools or dependencies according to your project requirements.

### Cleanup

The Dockerfile includes cleanup steps to reduce the image size by removing unnecessary files and package caches.

Feel free to modify the Dockerfile as needed for your specific use case.
