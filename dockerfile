FROM alpine:3.19.1 AS base
LABEL maintainer="Nícolas Basilio"

RUN mkdir -p /usr/node/app
WORKDIR /usr/node/app

RUN apk add --no-cache npm=10.2.5-r0 nodejs=20.12.1-r0 && \
        rm -rf /var/cache/apk/*

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

COPY functions ./functions
COPY package.json .
COPY pnpm-lock.yaml .

#---------- mid stage ------------
FROM base AS mid_stage
RUN npm install -g pnpm@8.15.5

#---------- prod deps ------------
FROM mid_stage AS prod_deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

#--------- build stage -----------
FROM mid_stage AS builder

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

COPY tsconfig.json .
COPY .swcrc.json .

RUN pnpm run build

#------- release stage -----------
FROM base

COPY --from=prod_deps /usr/node/app/node_modules ./node_modules
COPY --from=builder /usr/node/app/dist ./dist
COPY ./tools/ ./tools

VOLUME ["/usr/node/app/node_modules"]

