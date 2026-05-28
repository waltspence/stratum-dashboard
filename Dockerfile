FROM ruby:3.3.6-slim AS base
WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev pkg-config curl nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY api/Gemfile api/Gemfile.lock ./
RUN bundle config set --local deployment true && \
    bundle config set --local without "development test" && \
    bundle install && \
    rm -rf ~/.bundle/cache vendor/bundle/ruby/*/cache

# Stage 2: Vue frontend build
FROM node:22-slim AS frontend-build
WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 3: Production
FROM ruby:3.3.6-slim
WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libpq5 curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=base /usr/local/bundle /usr/local/bundle
COPY --from=base /rails/vendor /rails/vendor
COPY api/ .

# Copy Vue build
COPY --from=frontend-build /frontend/dist ./public/

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log tmp public

USER 1000:1000

EXPOSE 80
CMD ["bundle", "exec", "thrust", "puma", "-C", "config/puma.rb"]
