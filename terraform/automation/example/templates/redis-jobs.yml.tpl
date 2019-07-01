default: &default
  host: ${REDIS_JOBS}
  port: 6379

development:
  <<: *default

staging:
  <<: *default

qa:
  <<: *default

beta:
  <<: *default

production:
  <<: *default
