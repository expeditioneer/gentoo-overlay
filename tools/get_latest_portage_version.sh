#!/usr/bin/env bash

set -e

if [ -z "${GITHUB_GRAPHQL_QUERY_TOKEN}" ]; then
  echo "GITHUB_GRAPHQL_QUERY_TOKEN not set"
  exit 1
fi

curl \
  --header "Content-Type: application/json"\
  --header "Authorization: Bearer ${GITHUB_GRAPHQL_QUERY_TOKEN}" \
  --request POST \
  --data '{
            "query": "{ repository(owner: \"gentoo\", name: \"portage\") { tags: refs(refPrefix: \"refs/tags/\", first: 1, orderBy: { field: TAG_COMMIT_DATE, direction: DESC }) { edges { tag: node { name } } } } }"
          }' https://api.github.com/graphql | jq -r '.data.repository.tags.edges[].tag.name | split("-")[1]'
