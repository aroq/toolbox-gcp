# Define arguments & default values
ARG GCLOUD_VERSION=266.0.0-alpine

FROM google/cloud-sdk:$GCLOUD_VERSION as google-cloud-sdk

# Main stage
FROM aroq/toolbox-variant:0.1.51

COPY Dockerfile.packages.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)

ENV CLOUDSDK_CONFIG=/localhost/.config/gcloud/
COPY --from=google-cloud-sdk /google-cloud-sdk/ /usr/local/google-cloud-sdk/
RUN ln -s /usr/local/google-cloud-sdk/bin/gcloud /usr/local/bin/ && \
    ln -s /usr/local/google-cloud-sdk/bin/gsutil /usr/local/bin/ && \
    ln -s /usr/local/google-cloud-sdk/bin/bq /usr/local/bin/ && \
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

RUN mkdir -p /toolbox/toolbox-gcp
COPY tools /toolbox/toolbox-gcp/tools
COPY variant-lib /toolbox/toolbox-gcp/variant-lib

ENV TOOLBOX_TOOL_DIRS toolbox,/toolbox/toolbox-gcp
ENV VARIANT_CONFIG_CONTEXT toolbox
ENV VARIANT_CONFIG_DIR toolbox
