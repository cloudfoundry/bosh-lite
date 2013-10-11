#!/usr/bin/env ruby

require 'yaml'
require 'optparse'

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: transform [OPTIONS] to transform your yaml(already bosh diffed aws template from warden stub) for warden cpi"
  opt.separator  "Options"
  opt.on("-f","--file File","file path which has been diffed from warden stub file to aws template") do |file|
    options[:file] = file
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
end
opt_parser.parse!

mock_network_stub = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'manifests', 'warden-network.stub')
mock_db_stub = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'manifests', 'warden-db.stub')

if options[:file]
  dep_yaml = YAML.load_file(options[:file])

  nats_ip = nil
  log_ip = nil

  dep_yaml['jobs'].each do |job|
    case job['name']
    when 'syslog_aggregator'
      # reduce persistent disk of syslog
      job['persistent_disk'] = 4096
      log_ip = job['networks'][0]['static_ips'].first

    when 'cloud_controller'
      # add persistent disk for CC
      job['persistent_disk'] = 4096

    when 'dea_next'
      # simplify dea network
      job['networks'][0].delete('default')
      # add disk quota properties
      job['properties']['disk_quota_enabled'] = false

    when 'router'
      # hardcode router ip
      job['networks'][0].delete('default')
      job['networks'][0]['static_ips'] = '10.244.0.254'

    when 'nats'
      nats_ip = job['networks'][0]['static_ips'].first
    end
  end

  # Change nats/syslog hardcode ip(dirty part in aws template)
  dep_yaml['properties']['nats']['address'] = nats_ip
  dep_yaml['properties']['syslog_aggregator']['address'] = log_ip

  # Unused job/properties removed
  dep_yaml['jobs'].delete_if { |job| job['name'] == 'collector' }
  dep_yaml['properties'].delete('collector')

  # Add postgresql db
  db_yaml = YAML.load_file(mock_db_stub)
  dep_yaml['jobs'].insert(2, db_yaml['jobs'].first)
  dep_yaml['properties']['databases'] = db_yaml['properties']['databases']

  # Properties changes for warden cpi
  dep_yaml['properties']['dea_next']['kernel_network_tuning_enabled'] = false
  dep_yaml['properties']['dea_next']['enable_https_directory_server_protocal'] = false
  dep_yaml['properties']['dea_next']['directory_server_protocol'] = 'http'
  ['resource_pool', 'packages', 'droplets'].each do |name|
    dep_yaml['properties']['cc'][name]['fog_connection'] = {
      'provider' => 'Local',
      'local_root' => '/var/vcap/store'
    }
  end

  # Uaa/login memory tunnings
  # Note: reduce more memory usage will increase CPU usage
  ['uaa', 'login'].each do |j|
    dep_yaml['properties'][j]['catalina_opts'] = '-Xmx384m -XX:MaxPermSize=128m'
  end

  # canary_watch_time tunnings
  dep_yaml['update']['canary_watch_time'] = '30000-240000'

  # Clean up aws related stuff to keep yaml clear
  dep_yaml['resource_pools'].each do |rp|
    rp['cloud_properties'] = { 'name' => 'random' }
  end
  dep_yaml['compilation']['cloud_properties'] = { 'name' => 'random' }
  dep_yaml['properties'].delete('template_only')

  # Erase network first
  dep_yaml.delete('networks')
  File.open(options[:file], 'w+') {|f| f.write(dep_yaml.to_yaml) }

  # Apply network(just append can keep the network helper)
  network_stub = File.read(mock_network_stub)
  File.open(options[:file], 'a') {|f| f.puts network_stub}

  puts "#{options[:file]} transformed"
end
