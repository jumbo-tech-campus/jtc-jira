class StatsdMonitor
  def initialize(app)
    @app = app
    @client = StatsdClient.new
  end

  def call(env)
    started = Time.now

    status, headers, body = @app.call(env)

    if status.to_i.between?(200, 400)
      result = "result:success"
    elsif status.to_i.between?(500, 600)
      result = "result:failure"
    end

    path = Rails.application.routes.recognize_path(env['PATH_INFO'])

    controller = path[:controller]
    action = path[:action]

    @client.timing('request.duration',
      (Time.now - started) * 1000,
      tags: ["status:#{status}", result, "path:/#{controller}/#{action}"]
    )

    [status, headers, body]
  end
end
