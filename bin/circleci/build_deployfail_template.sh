#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../lib/git.bash"
git.paths.get

. "$SUBMODULES/lib/string.bash"

commit=$1
org="Medology"
query="{
       search(query: \"org:$org commit_sha:$commit\", type: ISSUE, first: 1) {
         nodes {
           ... on PullRequest {
             url
             number
             author {
               ... on User {
                 name
                 url
               }
             }
           }
         }
       }
     }"

# Query the Github GraphQL endpoint to retrieve PR information
pr_json_data="$(hub api graphql -f query="$query" | cut -c5-)"

# Parsing the JSON response into variables
PR_NUMBER="$(echo "$pr_json_data" | jq -r '.data.search.nodes[0].number')"
PR_URL="$(echo "$pr_json_data" | jq -r '.data.search.nodes[0].url')"
PR_AUTHOR_NAME="$(echo "$pr_json_data" | jq -r '.data.search.nodes[0].author.name')"
PR_AUTHOR_URL="$(echo "$pr_json_data" | jq -r '.data.search.nodes[0].author.url')"

# Building the RegEx query to inject the variables values in the template
regex=""
for elm in 'PR_NUMBER' 'PR_URL' 'PR_AUTHOR_NAME' 'PR_AUTHOR_URL' 'CIRCLE_PROJECT_REPONAME' 'CIRCLE_USERNAME' 'CIRCLE_BUILD_URL'; do
  regex+="s#\$${elm}#$(echo -n ${!elm} | string.sed.regex.escape)#;"
done

# Add the Slack template to the ENV variable and export it
echo "export SLACK_TEMPLATE='$(cat "$SUBMODULES/artifacts/slack_deploy_fail_template.json" | sed -e "$regex")'" >> $BASH_ENV
