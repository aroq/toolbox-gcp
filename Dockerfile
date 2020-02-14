FROM aroq/toolbox-cloud:0.1.5

RUN mkdir -p /toolbox-gcp
ADD tools /toolbox-gcp/tools
ADD variant-lib /toolbox-gcp/variant-lib

ENTRYPOINT ["/toolbox-gcp/tools/gcp"]
