#!/usr/bin/env ruby

require 'yaml'

reglist = ARGV[0]
output = ARGV[1]
registers = File.readlines(reglist).map(&:strip)

puts "Found #{registers.size} registers:"
puts registers

File.write(output,
  YAML.dump({ 'applications' => [{
    'buildpacks' => [ 'https://github.com/cloudfoundry/nginx-buildpack.git' ],
    'instances' => 2,
    'memory' => '1G',
    'name' => 'registers',
    'routes' => registers.map { |reg| { 'route' => "#{reg}-reg.london.cloudapps.digital" } }
  }]})
)
