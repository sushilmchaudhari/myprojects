default: &default
  adapter: mysql2
  host: ${DB_HOST}
  port: 3306
  username: ${DB_USER}
  password: ${DB_PASSWORD}
  encoding: utf8
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: ""

staging:
  <<: *default
  database: ""

beta:
  <<: *default
  database: ""

qa:
  <<: *default
  database: ${DB_NAME}

production:
  <<: *default
  database: ""
