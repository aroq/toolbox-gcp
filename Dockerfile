# Define arguments & default values
ARG GCLOUD_VERSION=290.0.1-alpine

FROM google/cloud-sdk:$GCLOUD_VERSION as google-cloud-sdk

# Main stage
FROM aroq/toolbox-secrets:0.1.26

COPY Dockerfile.packages.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)

ENV CLOUDSDK_CONFIG=/localhost/.config/gcloud/
COPY --from=google-cloud-sdk /google-cloud-sdk/ /usr/local/google-cloud-sdk/
RUN ln -s /usr/local/google-cloud-sdk/bin/gcloud /usr/local/bin/ && \
    ln -s /usr/local/google-cloud-sdk/bin/gsutil /usr/local/bin/ && \
    ln -s /usr/local/google-cloud-sdk/bin/bq /usr/local/bin/ && \
    ln -s /usr/local/google-cloud-sdk/bin/docker-credential-gcloud /usr/local/bin/ && \
    gcloud config set core/disable_usage_reporting true --installation && \
    gcloud config set component_manager/disable_update_check true --installation && \
    gcloud config set metrics/environment github_docker_image --installation

# Install kubectl
ARG KUBECTL_VERSION=v1.18.0
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    mkdir -p ~/completions && \
    kubectl completion bash > ~/completions/kubectl.bash && \
    echo "source ~/completions/kubectl.bash" >> /etc/profile

# Install kpt
RUN curl -LO https://storage.googleapis.com/kpt-dev/latest/linux_amd64/kpt && \
    chmod +x ./kpt && \
    mv ./kpt /usr/local/bin/kpt

# Install kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
RUN mv ./kustomize /usr/local/bin/kustomize

RUN mkdir -p /toolbox/toolbox-gcp
COPY tools /toolbox/toolbox-gcp/tools

ENV TOOLBOX_TOOL_DIRS toolbox,/toolbox/toolbox-gcp
ENV VARIANT_CONFIG_CONTEXT toolbox
ENV VARIANT_CONFIG_DIR toolbox
