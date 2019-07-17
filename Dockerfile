FROM amd64/ubuntu:18.04 AS builder

ARG KONG_VERSION

LABEL name="Kong" version="${KONG_VERSION}"

RUN mkdir /kong
WORKDIR /kong
COPY packages/ packages/
COPY templates/ templates/
COPY plugins/ plugins/


RUN apt-get update \
    && apt-get install -y openssl libpcre3 procps perl \
    && dpkg -i ./packages/kong-${KONG_VERSION}.*.deb \
    && rm -r ./packages

RUN cp ./templates/kong.conf.default /etc/kong/kong.conf
RUN cp ./templates/custom_nginx.template /etc/kong/custom_nginx.template
RUN chmod 644 /etc/kong/* && rm -r ./templates

RUN cd ./plugins/decision-maker && luarocks make
RUN rm -r ./plugins

COPY entry-point.sh /entry-point.sh

ENTRYPOINT ["/entry-point.sh"]

EXPOSE 80 443

STOPSIGNAL SIGQUIT

CMD ["kong", "start"]
