FROM java:8-jdk
ENV GOLANG_VERSION 1.7
ENV LV 3.5.1
# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		curl \
		telnet \
		wget \
		awscli \
		rsync \
		ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 702ad90f705365227e902b42d91dd1a40e48ca7f67a2f4b2fd052aaa4295cd95

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

RUN mkdir -p /usr/local/liquibase

ENV GOPATH /builds
ENV LIQUIBASE_HOME /usr/local/liquibase
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH:$LIQUIBASE_HOME

RUN wget https://github.com/liquibase/liquibase/releases/download/liquibase-parent-$LV/liquibase-$LV-bin.tar.gz -O /tmp/liquibase.tar.gz
RUN tar -xf /tmp/liquibase.tar.gz -C /usr/local/liquibase
RUN chmod +x /usr/local/liquibase/liquibase

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

WORKDIR $GOPATH

RUN wget https://raw.githubusercontent.com/docker-library/golang/master/go-wrapper
RUN mv go-wrapper /usr/local/bin/
RUN curl https://glide.sh/get | sh
RUN go get -u github.com/golang/lint/golint
RUN go get -u bitbucket.org/tebeka/go2xunit
RUN go get -u github.com/axw/gocov/gocov
RUN go get -u gopkg.in/matm/v1/gocov-html
RUN go get -u github.com/AlekSi/gocov-xml
RUN go get -u github.com/spf13/hugo
RUN go get -u github.com/wellington/wellington/wt