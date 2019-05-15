FROM microsoft/vsts-agent:latest

# Build-time metadata as defined at http://label-schema.org

LABEL org.label-schema.name="VSTS Agent with TF & ANSIBLE" \
    org.label-schema.url="https://github.com/karanotts/" \
    org.label-schema.vcs-url="https://github.com/karanotts/vsts-tf-ans" \
    org.label-schema.schema-version="1.0"
                
ENV TERRAFORM_VERSION 0.11.13


# Install Terraform
RUN echo "===> Installing Terraform ${TERRAFORM_VERSION}..." \
 && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
 &&	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
 && mv terraform /usr/local/bin/terraform \
 && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
	
# Install Ansible
RUN  echo "===> Installing Ansible..." \
 && apt-get update \   
 && apt-get install -y ansible \      
 && rm -rf /var/lib/apt/lists/*      \ 
 && echo "===> Adding hosts for convenience..." \
 && mkdir -p /etc/ansible                       \
 && echo 'localhost' > /etc/ansible/hosts

