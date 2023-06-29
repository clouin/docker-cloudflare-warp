FROM debian:bullseye-slim
ARG DEBIAN_RELEASE=bullseye

RUN true && \
	apt-get update && \
	apt-get install curl gnupg ca-certificates socat -y && \
 	curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $DEBIAN_RELEASE main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
	apt-get update && \
	apt-get install cloudflare-warp -y --no-install-recommends && \
 	apt-get autoremove --yes && \
	apt-get clean -y && \
 	rm -rf /var/lib/apt/lists/*

COPY --chmod=755 entrypoint.sh /usr/local/bin/

ENV WARP_LICENSE=
ENV FAMILIES_MODE=off

EXPOSE 1080/tcp
VOLUME ["/var/lib/cloudflare-warp"]

ENTRYPOINT [ "entrypoint.sh" ]
