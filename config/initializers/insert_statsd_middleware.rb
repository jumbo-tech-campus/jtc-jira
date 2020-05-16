require 'middlewares/statsd_monitor'

Rails.application.config.middleware.insert_before ActionDispatch::Executor, StatsdMonitor
