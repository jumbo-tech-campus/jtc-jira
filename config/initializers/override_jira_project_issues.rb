JIRA::Resource::Project.class_eval do
  def issues(params = {})
    search_url = client.options[:rest_base_path] + '/search'
    query_params = { jql: "project=\"#{key}\"" }
    query_params.update JIRA::Base.query_params_for_search(params)
    response = client.get(url_with_query_params(search_url, query_params))
    json = self.class.parse_json(response.body)
    results = json['issues']

    while (json['startAt'] + json['maxResults']) < json['total']
      query_params['startAt'] = (json['startAt'] + json['maxResults'])
      response = client.get(url_with_query_params(search_url, query_params))
      json = self.class.parse_json(response.body)
      results += json['issues']
    end

    results
  end
end
