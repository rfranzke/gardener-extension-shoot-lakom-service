# SPDX-FileCopyrightText: 2022 SAP SE or an SAP affiliate company and Gardener contributors
#
# SPDX-License-Identifier: Apache-2.0

############# builder
FROM golang:1.20.4 AS builder

ARG EFFECTIVE_VERSION
ARG TARGETARCH
WORKDIR /go/src/github.com/gardener/gardener-extension-shoot-lakom-service
COPY . .
RUN make install EFFECTIVE_VERSION=$EFFECTIVE_VERSION GOARCH=$TARGETARCH

############# base
FROM gcr.io/distroless/static-debian11:nonroot AS base

############# lakom
FROM base AS lakom
WORKDIR /

COPY --from=builder /go/bin/lakom /lakom
ENTRYPOINT ["/lakom"]

############# gardener-extension-shoot-lakom-service
FROM base AS gardener-extension-shoot-lakom-service

COPY charts /charts
COPY --from=builder /go/bin/gardener-extension-shoot-lakom-service /gardener-extension-shoot-lakom-service
ENTRYPOINT ["/gardener-extension-shoot-lakom-service"]
