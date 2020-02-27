# Define arguments & default values
ARG GCLOUD_VERSION=266.0.0-alpine

FROM google/cloud-sdk:$GCLOUD_VERSION as google-cloud-sdk

# Main stage
FROM aroq/toolbox

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

RUN mkdir -p /toolbox-gcp
ADD tools /toolbox-gcp/tools
ADD variant-lib /toolbox-gcp/variant-lib

ENTRYPOINT ["/toolbox-gcp/tools/gcp"]
