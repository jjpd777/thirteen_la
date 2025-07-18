
# Dockerfile for Phoenix Application

# ---- Builder Stage ----
# This stage builds the release.
ARG ELIXIR_VERSION=1.17.2
ARG OTP_VERSION=27.1.2
ARG DEBIAN_VERSION=bullseye-20240716-slim

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION} AS builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# set build environment
ENV MIX_ENV="prod"

# install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# copy mix files and install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# copy assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY assets assets

# build assets
RUN mix assets.deploy

# copy application source
COPY lib lib
COPY priv priv

# compile and build release
RUN mix compile
# The SECRET_KEY_BASE is not needed at build time, but it's good practice
# to have a dummy value to avoid compilation warnings.
RUN SECRET_KEY_BASE=dummy mix release

# ---- Final Stage ----
# This stage prepares the final image.
FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION} AS app

# install runtime dependencies
RUN apt-get update -y && apt-get install -y libssl-dev libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

# copy the compiled release from the builder stage
COPY --from=builder --chown=nobody:root /app/_build/prod/rel/thirteen ./

ENV HOME=/app
ENV MIX_ENV="prod"

# The user nobody is a standard non-root user available in this image.
USER nobody

# The PORT environment variable is set by Cloud Run.
# The default port for Phoenix is 4000, but we use the PORT env var.
CMD ["/app/bin/thirteen", "start"] 