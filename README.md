# jtc-jira

Ruby on Rails web application to report the results of sprints from JIRA, based on epics and parent epics from the portfolio plugin.

## Configuration

### Configuration: JIRA
The application uses the JIRA API to retrieve data for sprints. Get your API token from https://id.atlassian.com/manage-profile/security. Copy the [env.example](./.env.example) file to `.env` and fill in the username, api token, redis host and JIRA url. If you use the docker-compose setup, the REDIS_HOST will be `redis`. In Kubernetes, the REDIS_HOST will be an AWS Elasticache instance, so it will be configured with a REDIS_PASSWORD as well.

### Configuration:
The application expects a [config.yml](./config.yml) file in the root folder containing the teams you would like to see reports from. If you want to add a team, make sure the board_id, name, department_id, deployment_constraint_id and project_key are filled in. NOTE: You can find the `board_id` and `project_key` by going to a board of the team's project in JIRA. The URL will look like this: https://yourcompany.atlassian.net/secure/RapidBoard.jspa?rapidView=42&projectKey=EXP. The `board_id` is the `rapidView` parameter and the `project_key` is (of course) the `projectKey` parameter.

## Running the application

### Environment setup
In order to run the application you'll need to setup your environment, based on the example:
```
cp .env.example .env
nano .env
```

`JIRA_USERNAME` is your email address which you use to sign into JIRA.
`JIRA_API_KEY` is your JIRA API key, see [Attlasian documentation](https://confluence.atlassian.com/cloud/api-tokens-938839638.html) on how to create one.
`JIRA_SITE` is the root url of your JIRA instance, i.e. https://yourcompany.atlassian.net/. Note the `/` at the end, it's required!
Follow the comments in the `.env` file for instructions on `REDIS_HOST` and `RAILS_RELATIVE_URL_ROOT`.

### Starting the application

The easiest way to start the web application is to install Docker and run `docker-compose up`. The application runs by default on http://localhost:3001. You can also run it without Docker if you have Ruby 2.6 installed, by running `rails s`. The application will then be run on http://localhost:3000.

When running via docker-compose the current directory is linked into the container. Any changes in the source code you make are immediately visible in the running container. However, you should relaunch the container when changing i.e. how Rails is being started.

### Filling the cache
The application uses a Redis cache to store the data from JIRA. There is a Thor task that gets all data from JIRA and stores in the cache. This task is run in a separate container when you run `docker-compose up` (see [docker-compose.yml](./docker-compose.yml)). Watch the docker-compose log to see when it is finished, you will see `jtc-jira_thor_runner_1 exited with code 0` after a couple of minutes. After that the application is ready for use.

### Common errors
The application needs to cache the data from JIRA before it can run. Errors are logged to Datadog, so check here for what error is occurring [Datadog jtc-jira logs](https://app.datadoghq.com/logs?cols=core_host%2Ccore_service%2Clog_http.status_code%2Clog_request_time&from_ts=1579558081910&index=main&live=true&messageDisplay=inline&stream_sort=desc&to_ts=1579558981910&query=service%3Ajtc-jira)

Most common is that the Redis cache has been corrupted somehow. You can fix that by restarting the caching job. Go to [Gitlab jtc-jira pipelines](https://jmb.gitlab.schubergphilis.com/microservices/jtc-jira/pipelines) and trigger the 'Run once' job in the latest pipeline. Sometimes the data in JIRA crashes the caching job, because of inconsistent or missing data. Check the logs on which team it breaks (basically the last log message will tell you), remove that team from [config.yml](./config.yml) and retrigger the caching job.
You can always try a restart of the containers (could work) or try to add an empty commit to retrigger a full build and deploy (should not work).

## Development

The application is built on Ruby on Rails 6, using Ruby 2.7. It follows a lot of the standard Rails development practices, except that it does not use ActiveRecord, but factory and repository patterns for object creation and persistence. The front-end is built with Bootstrap 4. It uses Docker containers in a docker-compose setup to make development and deployment easy. There are no unit tests yet, however adding them should be fairly simple and PR's containing tests will be welcomed.

The application is a prototype to show how easy it can be to automate sprint reporting on portfolio epics if your team uses JIRA and consistently estimates the issues in a sprint. Even though the application does not change data in JIRA, use of this application is on your own risk. The authors nor Jumbo Supermarkten can be held responsible for any issues that may occur when using this application.
