FROM node:14@sha256:b2d1c5df5e001b694115f64f4532c7eec2e5dbd73db6e0caacf0049bd0aed7d2

# renovate: datasource=github-releases depName=Azure/azure-cli versioning=loose
ENV AZURE_CLI_VERSION="2.33.1-1~focal"

# renovate: datasource=github-releases depName=hashicorp/terraform versioning=loose
ENV TERRAFORM_VERSION="1.1.5"

# renovate: datasource=repology depName=ubuntu_20_04/openssh versioning=loose
ENV SSH_VERSION="1:8.2p1-4ubuntu0.4"

# renovate: datasource=repology depName=ubuntu_20_04/git versioning=loose
ENV GIT_VERSION="1:2.25.1-1ubuntu3.2"

RUN apt update && \
    apt install -y ca-certificates curl apt-transport-https lsb-release gnupg && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt update && \
    apt install -y \
    azure-cli="$AZURE_CLI_VERSION" \
    terraform="$TERRAFORM_VERSION" \
    ssh="$SSH_VERSION" \
    git="$GIT_VERSION"

RUN touch /example.txt
