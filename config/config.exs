# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :colorwall, Colorwall.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "o+Cix8x8u6YepUqIUlJgBHR5ujvYF1dAuclpQaPvYd09qzZ2W24SICcGOBaKg/oR",
  render_errors: [view: Colorwall.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Colorwall.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :colorwall, :interface,
  type: Colorwall.SPIDummy,
  led_count: 360,
  max_brightness: 31,
  order: ["r", "g", "b"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
