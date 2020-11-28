# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :weather_service,
  base_url:
    "http://api.openweathermap.org/data/2.5/weather?appid=dedc8f6532112bc88c2c40eb0893f9a1&units=metric&q="
