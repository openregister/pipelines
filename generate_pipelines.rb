#!/usr/bin/env ruby

require 'yaml'

pipelines = Dir.glob(ENV.fetch('REGISTRY_DATA')).map do |path|
  register = File.basename(path, '.rsf')
  {
    'name' => "deploy-#{register}",
    'team' => 'register',
    'config_file' => ENV.fetch('DEPLOY_CONFIG_FILE'),
    'unpaused' => ENV.fetch('UNPAUSED') == 'true',
    'vars' => { 'register-name' => register, 'paas-space' => register, 'domain' => ENV.fetch('DOMAIN') }
  }
end

File.write(ENV.fetch('OUTPUT'), YAML.dump({ 'pipelines' => pipelines }))
