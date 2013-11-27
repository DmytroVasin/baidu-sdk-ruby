# encoding: UTF-8

require 'baidu/core'
require 'webmock/rspec'

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # disable real requests to network
  WebMock.disable_net_connect!
end

def fixtures_path
  File.expand_path('../fixtures', __FILE__)
end

def ft(path)
  File.new "#{fixtures_path}/#{path}"
end

def webmock_url(mod, path)
  case mod
  when :oauth        then "https://openapi.baidu.com#{path}"
  when :pcs          then "https://pcs.baidu.com/rest/2.0/pcs#{path}"
  when :pcs_upload   then "https://c.pcs.baidu.com/rest/2.0/pcs#{path}"
  when :pcs_download then "https://d.pcs.baidu.com/rest/2.0/pcs#{path}"
  end
end

def stub_get(mod, path, params={})
  req = stub_request :get, webmock_url(mod, path)
  req.with(query: params) unless params.empty?
  req
end

def stub_post(mod, path, params={})
  req = stub_request :post, webmock_url(mod, path)
  req.with(body: params) unless params.empty?
  req
end

def a_get(mod, path, params={})
  req = a_request :get, webmock_url(mod, path)
  req.with(query: params) unless params.empty?
  req
end

def a_post(mod, path, params={})
  req = a_request :post, webmock_url(mod, path)
  req.with(body: params) unless params.empty?
  req
end
