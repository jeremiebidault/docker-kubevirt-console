FROM alpine:3.19.1

RUN apk add \
    git \
    kubectl

RUN git clone --branch v1.4.0 --depth 1 https://github.com/novnc/noVNC /app

COPY . /app/

ENTRYPOINT ["kubectl"]

CMD ["proxy", "--accept-hosts=^.*$", "--address=[::]", "--api-prefix=/k8s/", "--www=/app/", "--www-prefix=/"]
