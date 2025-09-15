# escape=`
FROM lacledeslan/steamcmd:linux AS downloader

ARG contentServer=content.lacledeslan.net


RUN echo "Downloading CS2d BASE" &&`
    curl -sSL "http://${contentServer}/fastDownloads/_installers/cs2d_1016_linux.zip" -o /tmp/cs2d_1016_linux.zip &&`
echo "Validating download against known hash" &&`
    echo "E2DE8000B639AADDD373BF47568A4B55DAE59D3E246E7A109FB61394A5E45381  /tmp/cs2d_1016_linux.zip" | sha256sum -c - &&`
echo "Extracting CS2D BASE FILES" &&`
    mkdir --parents /output &&`
    unzip /tmp/cs2d_1016_linux.zip -d /output;


RUN echo "Downloading CS2d SERVER FILES" &&`
    curl -sSL "http://${contentServer}/fastDownloads/_installers/cs2d_dedicated_linux.zip" -o /tmp/cs2d_dedicated_linux.zip &&`
echo "Validating download against known hash" &&`
    echo "C90988EC75A9D7E2E36271F7B70F96B40F5D6F1C1E625AA282D2C18246FC46B2  /tmp/cs2d_dedicated_linux.zip" | sha256sum -c - &&`
echo "Extracting CS2D SERVER FILES" &&`
    mkdir --parents /output &&`
    unzip /tmp/cs2d_dedicated_linux.zip -d /output;



COPY ./dist /output

FROM debian:trixie-slim

HEALTHCHECK NONE

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

ENV LANG=en_US.UTF-8 `
    LANGUAGE=en_US.UTF-8 `
    LC_ALL=en_US.UTF-8

RUN dpkg --add-architecture i386


RUN apt-get update &&`
    apt-get install -y `
        ca-certificates locales locales-all libsdl1.2debian whiptail libc6:i386 libstdc++6:i386 `
        --no-install-recommends --no-install-suggests --no-upgrade &&`
    apt-get clean &&`
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* &&`
    useradd --home /app --gid root --system CS2D &&`
    mkdir --parents /app /dist/sys/logs &&`
    chown CS2D:root -R /app;


COPY --chown=CS2D:root --from=downloader /output /app

RUN chmod +x /app/cs2d_dedicated 


USER CS2D

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root