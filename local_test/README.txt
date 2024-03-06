This folder contains a copy of the current fluentd configuration, but then tailored to be run in a local environment
There is no need to setup a kubernetes cluster or ELK, only Ruby and Fluentd need to be installed.
Furthermore the following fluentd plugins need to be installed.
  * fluent-plugin-concat
  * fluent-plugin-multi-format-parser
  * fluent-plugin-rewrite-tag-filter
  * fluent-plugin-kubernetes_metadata_filter

Moreover, we recommend setting the following environment variables
  export EANA_K8S_CLUSTER=localtest
  export EXCLUDE_HOST_REGEX="/.dev.eanadev.org|^(portal-js|contribute|contentful-proxy|media-proxy-js|styleguide|www)/"

To run simply open a terminal, go to this folder and run `fluentd -c local.conf'.
The results will be written to files in the result folder.
To retry delete the generated result folder and restart using the same command.