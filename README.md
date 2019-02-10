# jtc-jira

Ruby on Rails web application to report the results of sprints from JIRA, based on epics and parent epics from the portfolio plugin.

## Configuration

### Configuration: JIRA
The application uses the JIRA API to retrieve data for sprints. Get your API token from https://id.atlassian.com/manage-profile/security. Copy the [env.example](./.env.example) file to `.env` and fill in the username, api token, redis host and JIRA url. If you use the docker-compose setup, the REDIS_HOST will be `redis`.

### Configuration: teams
The application expects a `teams.yml` file in the root folder containing the teams you would like to see reports from. Copy the [teams.yml.example](./teams.yml.example) to `teams.yml` and fill in the data for each team. NOTE: You can find the `board_id` and `project_key` by going to the Active Sprint board in JIRA. The URL will look like this: https://yourcompany.atlassian.net/secure/RapidBoard.jspa?rapidView=42&projectKey=EXP. The `board_id` is the `rapidView` parameter and the `project_key` is (of course) the `projectKey` parameter.

## Running the application
The easiest way to run the web application is to install Docker and run `docker-compose up`. The application runs by default on http://localhost:3001. You can also run it without Docker if you have Ruby 2.6 installed, by running `rails s`. The application will then be run on http://localhost:3000.

### Filling the cache
The application uses a Redis cache to store the data from JIRA. There is a Thor task that gets all data from JIRA and stores in the cache. This task is run in a separate container when you run `docker-compose up` (see [docker-compose.yml](./docker-compose.yml)). Watch the docker-compose log to see when it is finished, you will see `jtc-jira_thor_runner_1 exited with code 0` after a couple of minutes. After that the application is ready for use.

### Running the application without cache
It's possible to run the application without using the cache. It then queries the JIRA API on each page load. Change the value `:use_cached_data: true
` to `:use_cached_data: false` in [config.yml](./config.yml) and restart the application.
