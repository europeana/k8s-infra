# Image pushed as europeana/fluentd
FROM fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch

LABEL Author="Europeana Foundation <development@europeana.eu>"

USER root

RUN buildDeps="build-essential libgeoip-dev ruby-dev  libmaxminddb-dev wget libtool automake autoconf" \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps \
    && fluent-gem install fluent-plugin-geoip fluent-plugin-multi-format-parser jwt \
    && rm -rf /var/lib/apt/lists/* \
    # removes GeoIP database so we re-download below
    && gem sources --clear-all \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem \
    && mkdir -p /usr/share/geoip \
    && wget -P /usr/share/geoip/ https://git.io/GeoLite2-City.mmdb

# By default fluentd will read plugin files from /fluentd/plugins/ folder (see also Docker containers entrypoint.sh)
COPY plugin_jwt/** /fluentd/plugins/


