FROM alpine:3.19.1

RUN apk add \
    git \
    kubectl

RUN git clone --branch v1.4.0 --depth 1 https://github.com/novnc/noVNC /app

COPY index.html window.html /app/

ENTRYPOINT ["kubectl"]

CMD ["proxy", "--address=[::]", "--port=9000", "--accept-hosts=^.*$", "--www=/app/", "--www-prefix=/", "--api-prefix=/k8s/"]
