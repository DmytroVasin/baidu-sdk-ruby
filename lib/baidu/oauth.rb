require 'baidu/core'
require 'baidu/oauth/client'

module Baidu
  module OAuth
    SITE                   = 'https://openapi.baidu.com'
    AUTHORIZATION_ENDPOINT = '/oauth/2.0/authorize'
    TOKEN_ENDPOINT         = '/oauth/2.0/token'
    TOKEN_INFO_ENDPOINT    = '/oauth/2.0/tokeninfo'
    DEVICE_ENDPOINT        = '/oauth/2.0/device/code'
  end
end
