#!/bin/bash
#
# Setup a directory in this repository with ESF terraform files.

ESF_DESTINATION_DIRECTORY="terraform/requirements/esf"
rm -rf "${ESF_DESTINATION_DIRECTORY}"

cd terraform || exit

# Delete esf_requirements module if this script was applied before
sed -i "/# Deploy the necessary resources to use ESF/,/# End ESF module/d" modules.tf
