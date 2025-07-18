# Dockerfile for Phoenix Application

# ---- Builder Stage ----
# This stage builds the release.
ARG ELIXIR_VERSION=1.17.2
ARG OTP_VERSION=27.0.1
ARG DEBIAN_VERSION=bullseye-20240904-slim

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
# This is done first to leverage Docker layer caching.
# Dependencies won't be re-downloaded unless mix.exs or mix.lock changes.
COPY thirteen/mix.exs thirteen/mix.lock ./
RUN mix deps.get --only prod

# --- THIS IS THE CRITICAL FIX ---
# Copy config files BEFORE compiling dependencies and assets,
# as they are needed for compilation.
COPY thirteen/config ./config

# Now compile dependencies
RUN mix deps.compile

# copy all assets
COPY thirteen/assets ./assets

# build assets
RUN mix assets.deploy

# copy application source
COPY thirteen/lib ./lib
COPY thirteen/priv ./priv

# compile and build release
RUN mix compile
# A dummy secret is used here to satisfy compile-time checks.
# The real secret will be injected at runtime.
RUN SECRET_KEY_BASE=dummy mix release

# ---- Final Stage ----
# This stage prepares the final image.
FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION} AS app

# install runtime dependencies
RUN apt-get update -y && apt-get install -y libssl-dev libncurses5 locales openssl \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

# copy the compiled release from the builder stage
COPY --from=builder --chown=nobody:root /app/_build/prod/rel/thirteen ./

ENV HOME=/app
ENV MIX_ENV="prod"

# The user nobody is a standard non-root user available in this image for better security.
USER nobody

# The PORT environment variable is set by Cloud Run.
# The default port for Phoenix is 4000, but we use the PORT env var.
CMD ["/app/bin/thirteen", "start"]
