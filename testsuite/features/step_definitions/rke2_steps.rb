# Copyright 2026 SUSE LLC
# Licensed under the terms of the MIT license.

Given('The first-time setup job is successful') do
  # Check the job status via JSON
  cmd = "kubectl get jobs -n uyuni -l app.kubernetes.io/component=server-setup -o jsonpath='{.items[0].status.succeeded}'"
  status, code = get_target('server').run_local(cmd)
  raise 'Failed to get server setup job status' unless code.zero?
  raise 'Server setup job did not succeed' unless status.to_i >= 1
end

Then('the setup marker file should exist on "server"') do
  server_pod = get_pod_name('server', 'server')
  cmd = "kubectl exec -n uyuni #{server_pod} -- test -f /root/.MANAGER_SETUP_COMPLETE && echo 'EXISTS'"
  status, code = get_target('server').run_local(cmd)
  raise 'Failed to check server setup marker file' unless code.zero?
  raise 'Server setup marker file does not exist' unless status.include? 'EXISTS'
end

Given(/^The Kubernetes cluster is ready on "(.*)"$/) do |target|
  _out, code = get_target(target).run_local('kubectl get nodes && kubectl get namespace uyuni')
  raise "Kubernetes cluster is not ready or uyuni namespace is missing on #{target}" unless code.zero?
end

And(/^(?:the|I wait until the) "(.*)" deployment on "(.*)" (?:becomes|should become) ready within (.*) minutes$/) do |name, target, mins|
  wait_for_deployment(target, name, mins.to_i)
end
