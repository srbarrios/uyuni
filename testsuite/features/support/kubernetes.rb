# Copyright (c) 2023 SUSE LLC.
# Licensed under the terms of the MIT license.

# Create an SSL certificate using cert-manager and return the path on the server where the files have been copied
#
# @param name [String] The name of the certificate.
# @param fqdn [String] The fully qualified domain name (FQDN) for the certificate.
# @return [Array<String>] An array containing the paths to the generated certificate files: [crt_path, key_path, ca_path].
def generate_certificate(name, fqdn)
  certificate = 'apiVersion: cert-manager.io/v1\\n'\
                'kind: Certificate\\n'\
                'metadata:\\n'\
                "  name: uyuni-#{name}\\n"\
                'spec:\\n'\
                "  secretName: uyuni-#{name}-cert\\n"\
                '  subject:\\n'\
                "    countries: ['DE']\\n"\
                "    provinces: ['Bayern']\\n"\
                "    localities: ['Nuernberg']\\n"\
                "    organizations: ['SUSE']\\n"\
                "    organizationalUnits: ['SUSE']\\n"\
                '  emailAddresses:\\n'\
                '    - galaxy-noise@suse.de\\n'\
                "  commonName: #{fqdn}\\n"\
                '  dnsNames:\\n'\
                "    - #{fqdn}\\n"\
                '  issuerRef:\\n'\
                '    name: uyuni-ca-issuer\\n'\
                '    kind: Issuer'
  _out, return_code = get_target('server').run_local("echo -e \"#{certificate}\" | kubectl apply -f -")
  raise SystemCallError, "Failed to define #{name} Certificate resource" unless return_code.zero?

  # cert-manager takes some time to generate the secret, wait for it before continuing
  repeat_until_timeout(timeout: 600, message: "Kubernetes uyuni-#{name}-cert secret has not been defined") do
    _result, code = get_target('server').run_local("kubectl get secret uyuni-#{name}-cert", check_errors: false)
    break if code.zero?

    sleep 1
  end

  crt_path = "/tmp/#{name}.crt"
  key_path = "/tmp/#{name}.key"
  ca_path = '/tmp/ca.crt'

  _out, return_code = get_target('server').run_local("kubectl get secret uyuni-#{name}-cert -o jsonpath='{.data.tls\\.crt}' | base64 -d >#{crt_path}")
  raise SystemCallError, "Failed to store #{name} certificate" unless return_code.zero?

  _out, return_code = get_target('server').run_local("kubectl get secret uyuni-#{name}-cert -o jsonpath='{.data.tls\\.key}' | base64 -d >#{key_path}")
  raise SystemCallError, "Failed to store #{name} key" unless return_code.zero?

  get_target('server').run_local("kubectl get secret uyuni-#{name}-cert -o jsonpath='{.data.ca\\.crt}' | base64 -d >#{ca_path}")
  [crt_path, key_path, ca_path]
end

# Returns whether the server is running in a k3s container or not
#
# @return [Boolean] Returns true if the k3s service is running, false otherwise.
def running_k3s?
  _out, code = get_target('server').run_local('systemctl is-active k3s', check_errors: false)
  code.zero?
end

# Returns whether the server is running in a rke2 cluster or not
#
# @return [Boolean] Returns true if the rke2 service is running, false otherwise.
def running_rke2?
  _out, code = get_target('server').run_local('systemctl is-active rke2-server', check_errors: false)
  code.zero?
end

# Performs a label-based pod lookup using JSONPath.
#
# @param target [String] The target host where the kubectl command will be run.
# @param component [String] The component label value to search for.
# @return [String, nil] The name of the first matching pod, or nil if not found.
def get_pod_name(target, component)
  label = "app.kubernetes.io/component=#{component}"
  cmd = "kubectl get pods -n uyuni -l #{label} -o jsonpath='{.items[0].metadata.name}'"
  out, code = get_target(target).run_local(cmd)
  out if code.zero?
end

# Polls the Kubernetes Deployment status until all replicas are ready or a timeout is reached.
#
# @param target [String] The target host where the kubectl command will be run.
# @param deploy_name [String] The name of the deployment to check.
# @param timeout_mins [Integer] The maximum time to wait in minutes. Defaults to 15.
# @return [Boolean] Returns true if the deployment becomes ready.
# @raise [RuntimeError] If the timeout is reached before the deployment is ready.
def wait_for_deployment(target, deploy_name, timeout_mins = 15)
  start_time = Time.now
  loop do
    raise "Timeout: #{deploy_name} on #{target} not ready" if (Time.now - start_time) > (timeout_mins * 60)

    out, _code = get_target(target).run_local("kubectl get deployment #{deploy_name} -n uyuni -o json")
    data = JSON.parse(out)

    return true if data.dig('status', 'readyReplicas') == data.dig('spec', 'replicas')

    puts "Waiting for #{deploy_name} on #{target}... (#{(Time.now - start_time).to_i}s)"
    sleep 10
  end
end
