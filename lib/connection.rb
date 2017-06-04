# frozen_string_literal: true

DB_SPEC = {
  adapter: 'sqlite3',
  database: 'scope.sqlite3',
  pool: 5,
  timeout: 5000
}.freeze

ActiveRecord::Base.establish_connection(DB_SPEC)
