FROM ubuntu:latest
LABEL maintainer="Donovan Hughes (dohughes@microsoft.com)"
RUN apt-get update && \
    apt-get -y install whois && \
    rm -rf /var/lib/apt/lists/*
ENTRYPOINT [ "/bin/bash" ]
