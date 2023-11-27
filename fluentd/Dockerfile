# Image pushed as europeana/fluentd
#FROM fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch
FROM fluent/fluentd-kubernetes-daemonset:v1.16.1-debian-elasticsearch7-1.2

LABEL Author="Europeana Foundation <development@europeana.eu>"

USER root

# (MD nov 23) we now need to include automake and libtool dependencies to build fluent-plugin-geoip
# autoconf is not required now, but try including it if the build fails again
RUN buildDeps="build-essential libgeoip-dev ruby-dev automake libtool libmaxminddb-dev wget" \
  && apt-get update \
  && apt-get install -y --no-install-recommends $buildDeps \
  && fluent-gem install fluent-plugin-geoip fluent-plugin-multi-format-parser \
  && rm -rf /var/lib/apt/lists/* \
  # removes GeoIP database so we re-download below \
#  && gem search -rd fluent-plugin \
  && gem sources --clear-all \
  && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem \
  && mkdir -p /usr/share/geoip \
  && wget -P /usr/share/geoip/ https://git.io/GeoLite2-City.mmdb

# user created in base image (PE Apr 2023 - commented out as this is causing issues)
#USER fluent