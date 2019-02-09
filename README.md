# jtc-jira

Ruby on Rails web application to report the results of sprints from JIRA, based on epics and parent epics from the portfolio plugin.

### Running the application
The application uses the JIRA API to retrieve data for sprints. Get your API token from https://id.atlassian.com/manage-profile/security. Copy the `.env.example` file to `.env` and fill in the username, api token and JIRA url.

The easiest way to run the web application is to install Docker and run `docker-compose up`. The application runs by default on http://localhost:3001
