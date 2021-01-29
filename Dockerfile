FROM golang:1.15.6-alpine3.12

ARG USER_NAME='circleci'
ARG USER_UID='1000'
ARG USER_GID='1000'
ARG USER_GROUP='app_users'

ENV GOPATH /home/$USER_NAME
ENV CGO_ENABLED 0
ENV TERRAFORM_DOWNLOAD_URL 'https://releases.hashicorp.com/terraform/0.13.6/terraform_0.13.6_linux_amd64.zip'
ENV TFLINT_DOWNLOAD_URL 'https://github.com/wata727/tflint/releases/download/v0.13.1/tflint_linux_amd64.zip'
ENV TERRAGRUNT_DOWNLOAD_URL 'https://github.com/gruntwork-io/terragrunt/releases/download/v0.27.1/terragrunt_linux_amd64'
ENV AWSCLI_DOWNLOAD_URL 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip'

# VS Code Requirements: openssh, musl, libgcc, libstdc++
RUN apk --no-progress --purge --no-cache upgrade \
 && apk --no-progress --purge --no-cache add --upgrade \
    curl \
    git \
    gnupg \
    libgcc \
    libstdc++ \
    openssh \
    tini \
 && apk --no-progress --purge --no-cache upgrade \
 && rm -vrf /var/cache/apk/* \
 && curl --version \
 && git --version

# Install vanilla GLibC: https://github.com/sgerrand/alpine-pkg-glibc
RUN curl -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk \
 && apk add glibc-2.32-r0.apk

RUN echo 'Install AWS CLI 2' \
 && curl -o /tmp/awscliv2.zip "${AWSCLI_DOWNLOAD_URL}" \
 && unzip -q -d /tmp /tmp/awscliv2.zip \
 && /tmp/aws/install

# Add a non-root group and user, helpful if you dev on Linux.
RUN addgroup --system --gid $USER_GID $USER_GROUP \
 && adduser --system \
    --disabled-password \
    --ingroup $USER_GROUP \
    --uid $USER_UID \
    $USER_NAME

USER $USER_NAME

# Install Go helpful dev tools.
RUN mkdir -p ~/bin \
 && curl -L -o ~/bin/git-chglog https://github.com/git-chglog/git-chglog/releases/download/v0.10.0/git-chglog_linux_amd64 \
 && chmod +x ~/bin/git-chglog

# VSCode Requirements for pre-installing extensions
RUN mkdir -p /home/$USER_NAME/.vscode-server \
    /home/$USER_NAME/.vscode-server-insiders \
    "${GOPATH}/src" \
    "${GOPATH}/bin"

RUN curl -fL -o /tmp/terraform.zip "${TERRAFORM_DOWNLOAD_URL}" \
 && unzip -q -d "${GOPATH}/bin" /tmp/terraform.zip \
 && rm -f /tmp/terraform.zip

RUN curl -fL -o "${GOPATH}/bin/terragrunt" "${TERRAGRUNT_DOWNLOAD_URL}" \
 && chmod +x "${GOPATH}/bin/terragrunt"

ENV PATH "${PATH}:${GOPATH}/bin"

ENTRYPOINT [ "tini", "--" ]

CMD [ "tail", "-f", "/dev/null" ]
