# Image pushed as europeana/fluentd
FROM fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch

LABEL Author="Europeana Foundation <development@europeana.eu>"

USER root

RUN buildDeps="build-essential libgeoip-dev ruby-dev  libmaxminddb-dev wget" \
     && apt-get update \
     && apt-get install \
     -y --no-install-recommends \
     $buildDeps \
     && fluent-gem install fluent-plugin-geoip fluent-plugin-color-stripper \
    && rm -rf /var/lib/apt/lists/* \
    # removes GeoIP database so we re-download below
    && gem sources --clear-all \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem \
    && mkdir -p /usr/share/geoip \
    && wget -P /usr/share/geoip/ https://git.io/GeoLite2-City.mmdb
