FROM kohirens/alpine-awscli:2.13.33 AS base

ARG USER_NAME='circleci'
ARG USER_UID='1000'
ARG USER_GID='1000'
ARG USER_GROUP='app_users'

ENV TERRAFORM_DOWNLOAD_URL 'https://releases.hashicorp.com/terraform/1.6.3/terraform_1.6.3_linux_amd64.zip'
ENV TFLINT_DOWNLOAD_URL 'https://github.com/wata727/tflint/releases/download/v0.53.0/tflint_linux_amd64.zip'
ENV TFLINT_DOWNLOAD_URL 'https://github.com/terraform-linters/tflint/releases/download/v0.48.0/tflint_linux_amd64.zip'
ENV TERRAGRUNT_DOWNLOAD_URL 'https://github.com/gruntwork-io/terragrunt/releases/download/v0.53.0/terragrunt_linux_amd64'

WORKDIR /tmp

RUN apk --no-progress --purge --no-cache upgrade \
 && apk --no-progress --purge --no-cache add --upgrade \
    bash \
    curl \
    git \
    gnupg \
    gzip \
    jq \
    openssh \
    openssl \
    zip \
 && apk --no-progress --purge --no-cache upgrade \
 && rm -vrf /var/cache/apk/* \
 && curl --version \
 && git --version

RUN curl -fL -o /tmp/terraform.zip "${TERRAFORM_DOWNLOAD_URL}" \
 && unzip -q -d "/usr/local/bin" /tmp/terraform.zip \
 && rm -f /tmp/terraform.zip \
 && terraform version

RUN curl -fL -o "/usr/local/bin/terragrunt" "${TERRAGRUNT_DOWNLOAD_URL}" \
 && chmod a+x "/usr/local/bin/terragrunt" \
 && terragrunt

RUN curl --fail --silent -L -o /tmp/tflint.zip "${TFLINT_DOWNLOAD_URL}" \
 && unzip -q -d "/usr/local/bin" /tmp/tflint.zip \
 && chmod a+x "/usr/local/bin/tflint" \
 && rm -f /tmp/tflint.zip \
 && tflint

RUN aws --version

RUN rm -rf /tmp/*

# Add a non-root group and user.
RUN addgroup --system --gid ${USER_GID} ${USER_GROUP} \
 && adduser --system \
    --disabled-password \
    --ingroup ${USER_GROUP} \
    --uid ${USER_UID} \
    ${USER_NAME}

FROM base AS dev

COPY --chmod=0775 start.sh /usr/local/bin/

ENTRYPOINT [ "start.sh" ]

FROM base AS release

USER ${USER_NAME}

ENTRYPOINT [ "" ]

CMD [ "" ]