use Mix.Config

config :exvcr,
  vcr_cassette_library_dir: "test/fixtures/vcr_cassettes"

config :logger, level: :error

config :upstream, :storage,
  account_id: System.get_env("B2_ACCOUNT_ID"),
  application_key: System.get_env("B2_APPLICATION_KEY"),
  bucket_id: System.get_env("B2_BUCKET_ID"),
  bucket_name: System.get_env("B2_BUCKET_NAME"),
  service: "b2"

config :upstream, Upstream,
  concurrency: 2

config :upstream, :upload,
  timeout: :infinity
