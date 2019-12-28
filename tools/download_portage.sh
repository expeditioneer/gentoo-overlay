#!/usr/bin/env bash

set -e

if [ -z "${GITHUB_GRAPHQL_QUERY_TOKEN}" ]; then
  echo "GITHUB_GRAPHQL_QUERY_TOKEN not set"
  exit 1
fi

LATEST_PORTAGE_VERSION=$(curl \
  --header "Content-Type: application/json"\
  --header "Authorization: Bearer ${GITHUB_GRAPHQL_QUERY_TOKEN}" \
  --request POST \
  --data '{
            "query": "{ repository(owner: \"gentoo\", name: \"portage\") { tags: refs(refPrefix: \"refs/tags/\", first: 1, orderBy: { field: TAG_COMMIT_DATE, direction: DESC }) { edges { tag: node { name } } } } }"
          }' https://api.github.com/graphql | jq -r '.data.repository.tags.edges[].tag.name | split("-")[1]')

echo "Latest Portage Version is: ${LATEST_PORTAGE_VERSION}"

temporary_directory="$(mktemp --directory)"

portage_extracted_directory=${temporary_directory}/portage-archive
mkdir "${portage_extracted_directory}"

curl --location --silent "https://github.com/gentoo/portage/archive/portage-${LATEST_PORTAGE_VERSION}.tar.gz" | tar --extract --gzip --directory="${portage_extracted_directory}" --strip-components=1