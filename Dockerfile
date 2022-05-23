# ---------------------------------- Base (tools and packages installed) ------------------------------

FROM mcr.microsoft.com/dotnet/sdk:6.0.101-alpine3.14 AS rgcompare_base

ARG TEAMCITY_VERSION
ARG TEAMCITY_PROJECT_NAME
ARG BUILD_VERSION
ARG MAJ_MIN_VERSION
ARG BUILD_NUMBER
ARG NUGET_FEED_PASSWORD

WORKDIR /app

RUN echo hello


# ---------------------------------- Build ------------------------------

FROM rgcompare_base AS rgcompare_build

COPY . .

RUN ./docker/create-nuget-package.sh

RUN mkdir /scan-artifacts/ && \
    find /app/src -name 'project.assets.json' \
        -print \
        -exec cp --parents \{\} /scan-artifacts/ \;

# ---------------------------------- Mutation test ----------------------------------

FROM rgcompare_base AS rgcompare_mutation_test

RUN dotnet tool install -g dotnet-stryker --version 1.2.1
ENV PATH="/root/.dotnet/tools:${PATH}"

COPY . .

# ---------------------------------- Publish NuGet ----------------------------------

FROM mcr.microsoft.com/dotnet/sdk:6.0.101-alpine3.14 AS rgcompare_publish_nuget

WORKDIR /app

# hadolint ignore=DL3018
RUN apk add bash

COPY ./.nupkg ./.nupkg
COPY ./docker/push-nuget-package.sh ./docker/push-nuget-package.sh

# ---------------------------------- Published Image  ----------------------------------

FROM mcr.microsoft.com/dotnet/runtime:6.0.1-alpine3.14 AS rgcompare_published_image

WORKDIR /app

COPY ./.published .

ENTRYPOINT [ "dotnet", "./RgCompare.Cli.dll" ]

# ---------------------------------- Scan ----------------------------------

FROM node:lts-alpine3.14 AS rgcompare_scan

WORKDIR /app

# hadolint ignore=DL3018
RUN apk add bash

RUN npm install -g snyk@1.874.0

COPY ./.snyk ./.snyk
COPY ./docker/run-snyk-monitor-current.sh ./docker/run-snyk-monitor-current.sh
COPY ./docker/run-snyk-monitor-release.sh ./docker/run-snyk-monitor-release.sh
COPY ./docker/run-snyk-test.sh ./docker/run-snyk-test.sh

# ---------------------------------- License check ----------------------------------

FROM alpine:3.16.0 as rgcompare_license_report

# hadolint ignore=DL3018
RUN apk update \
    && apk add --no-cache \
        curl \
        jq \
        bash

WORKDIR /app

COPY ./licenses.csv ./licenses.csv
COPY ./docker/check-license-report.sh ./docker/check-license-report.sh
