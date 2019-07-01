FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERRAFORM_VERSION 0.11.14

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
            apt-utils \
            apt-transport-https \
            ca-certificates \
            curl \
            jq \
            git \
            gnupg \
            iputils-ping \
            libcurl3 \
            libicu55 \
            lsb-release \
            openssh-server \
            software-properties-common \
            unzip \
            wget

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/terraform \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null \
    && AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

RUN useradd -m ansible && echo "ansible:ansible" | chpasswd && adduser ansible sudo 

RUN apt-add-repository --y --u ppa:ansible/ansible \
    && apt-get update \
    && apt-get install -y \
             ansible \
	     azure-cli \
             python-pip \
    && pip install pywinrm \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/ansible \
    && echo 'localhost' > /etc/ansible/hosts

EXPOSE 22

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]
