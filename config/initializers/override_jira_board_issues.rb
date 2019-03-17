JIRA::Resource::Board.class_eval do
  def issues(params = {})
    path = path_base(client) + "/board/#{id}/issue"
    response = client.get(url_with_query_params(path, params))
    json = self.class.parse_json(response.body)
    results = json['issues']

    while (json['startAt'] + json['maxResults']) < json['total']
      params['startAt'] = (json['startAt'] + json['maxResults'])
      response = client.get(url_with_query_params(path, params))
      json = self.class.parse_json(response.body)
      results += json['issues']
    end

    results
  end
end
