class JIRA::Resource::Issue
  def self.jql(client, jql, options = {})
    url = client.options[:rest_base_path] + "/search?jql=#{CGI.escape(jql)}"

    if options[:expand]
      options[:expand] = [options[:expand]] if options[:expand].is_a?(String)
      url << "&expand=#{options[:expand].to_a.map { |value| CGI.escape(value.to_s) }.join(',')}"
    end

    response = client.get(url)
    json = parse_json(response.body)
    results = json['issues']

    while (json['startAt'] + json['maxResults']) < json['total']
      start_at = (json['startAt'] + json['maxResults'])
      response = client.get("#{url}&startAt=#{start_at}")
      json = parse_json(response.body)
      results += json['issues']
    end

    results
  end
end
