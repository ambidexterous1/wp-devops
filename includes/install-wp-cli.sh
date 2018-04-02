#!/usr/bin/env bash
#
# devops/core/includes/install-wp-cli.sh
#
#   Install WP-CLI
#

#
# "Declarations" of the variables this script assumes
#

declare=${WP_CLI_SOURCE:=}
declare=${WP_CLI_FILEPATH:=}

#
# Add the executable flat
#
announce "......Make WP-CLI executable"
chmod +x "${WP_CLI_SOURCE}"

#
# Add the executable flat
#
announce "......Copying WP-CLI to ${WP_CLI_FILEPATH}"
sudo cp "${WP_CLI_SOURCE}" "${WP_CLI_FILEPATH}"


