# Copyright (c) 2017-2020 SUSE LLC
# Licensed under the terms of the MIT license.
#
# The scenarios in this feature are skipped if there is no proxy
# ($proxy is nil)
#
# Alternative: Bootstrap the proxy as a traditional client from script

@scope_proxy
Feature: Setup SUSE Manager proxy
  In order to use a proxy with the SUSE manager server
  As the system administrator
  I want to register the proxy to the server

@proxy
  Scenario: Create the bootstrap script for the proxy and use it
    When I execute mgr-bootstrap "--script=bootstrap-proxy.sh --no-up2date --traditional"
    Then I should get "* bootstrap script (written):"
    And I should get "    '/srv/www/htdocs/pub/bootstrap/bootstrap-proxy.sh'"
    When I fetch "pub/bootstrap/bootstrap-proxy.sh" to "proxy"
    And I run "sh ./bootstrap-proxy.sh" on "proxy"

@proxy
  Scenario: Copy the keys and configure the proxy
    When I copy server's keys to the proxy
    And I configure the proxy
    Then I should see "proxy" via spacecmd

@proxy
  Scenario: Check proxy system details
    When I am on the Systems overview page of this "proxy"
    Then I should see "proxy" hostname
    # TODO: uncomment when SCC product becomes available
    # When I wait until I see "$PRODUCT Proxy" text, refreshing the page
    Then I should see a "Proxy" link in the content area

@proxy
  Scenario: Install expect package on proxy for bootstrapping client via script via script
    When I enable repositories before installing branch server
    And I install package "expect" on this "proxy"
    And I disable repositories after installing branch server

@proxy
  Scenario: Cleanup: remove proxy bootstrap scripts
    When I run "rm /srv/www/htdocs/pub/bootstrap/bootstrap-proxy.sh" on "server"
    And I run "rm /root/bootstrap-proxy.sh" on "proxy"
