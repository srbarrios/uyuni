#!/bin/bash
set -xe

if [[ "$(uname)" == "Darwin" ]]; then
  PODMAN_CMD="podman"
else
  PODMAN_CMD="sudo -i podman"
fi

echo opensusesshproductuuid > /tmp/testing/opensuse_ssh_product_uuid
$PODMAN_CMD run --privileged -d --network network -v /tmp/testing/opensuse_ssh_product_uuid:/sys/class/dmi/id/product_uuid -v /tmp/testing:/tmp --name opensusessh -h opensusessh ghcr.io/$UYUNI_PROJECT/uyuni/ci-test-opensuse-minion:$UYUNI_VERSION

$PODMAN_CMD exec opensusessh bash -c "sed -e 's/http:\/\/download.opensuse.org/http:\/\/server\/pub\/mirror\/download.opensuse.org/g' -i /etc/zypp/repos.d/*"
$PODMAN_CMD exec opensusessh bash -c "sed -e 's/https:\/\/download.opensuse.org/http:\/\/server\/pub\/mirror\/download.opensuse.org/g' -i /etc/zypp/repos.d/*"
