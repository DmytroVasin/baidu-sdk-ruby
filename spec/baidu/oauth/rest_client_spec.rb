# encoding: UTF-8

require 'spec_helper'
require 'baidu/oauth'

module Baidu
  describe OAuth::RESTClient do
    let(:base_query) { { access_token: '3.xxx.yyy' } }

    before do
      @client = OAuth::RESTClient.new(base_query[:access_token])
    end

    describe '#initialize' do
      it 'inits with access token string' do
        client = OAuth::RESTClient.new('xyz_at')
        expect(client).to be_a(OAuth::RESTClient)
        expect(client.instance_variable_get(:@access_token)).to eq('xyz_at')
      end

      it 'inits with Baidu::Session' do
        session = Baidu::Session.new
        session.access_token = 'zyx_at'
        client = OAuth::RESTClient.new(session)
        expect(client).to be_a(OAuth::RESTClient)
        expect(client.instance_variable_get(:@access_token)).to eq('zyx_at')
      end

      it 'provides base uri' do
        client = OAuth::RESTClient.new('xyz_at')
        expect(client.instance_variable_get(:@site)).to eq('https://openapi.baidu.com')
      end

      it 'raises error with other params' do
        expect {
          OAuth::RESTClient.new({})
        }.to raise_error(ArgumentError, 'need a String or Baidu::Session')
      end
    end

    describe '#get_logged_in_user' do
      it 'requests with params' do
        stub = stub_post(:oauth_rest, '/passport/users/getLoggedInUser', base_query)
        @client.get_logged_in_user
        stub.should have_been_requested
      end
    end

    describe '#get_info' do
      it 'requests current user info' do
        stub = stub_post(:oauth_rest, '/passport/users/getInfo', base_query)
        @client.get_info
        stub.should have_been_requested
      end
    end

    describe '#app_user?' do
      it 'requests "isAppUser" api' do
        stub = stub_post(:oauth_rest, '/passport/users/isAppUser', base_query)
        @client.app_user?
        stub.should have_been_requested
      end

      it 'requests "isAppUser" for specified user' do
        stub = stub_post(:oauth_rest,
                         '/passport/users/isAppUser',
                         base_query.update({ uid: '456123' }))
        stub.to_return(body: '{"result":"1"}')
        rest = @client.app_user?(uid: '456123')
        stub.should have_been_requested
        expect(rest).to eq(true)
      end

      it 'requests "isAppUser" for specified appid' do
        stub = stub_post(:oauth_rest,
                         '/passport/users/isAppUser',
                         base_query.update({ appid: '341256' }))
        stub.to_return(body: '{"result":"0"}')
        rest = @client.app_user?(appid: '341256')
        stub.should have_been_requested
        expect(rest).to eq(false)
      end
    end

    describe '#has_app_permission?' do
      it 'requests "hasAppPermission" api' do
        stub = stub_post(:oauth_rest,
                         '/passport/users/hasAppPermission',
                         base_query.update({ ext_perm: 'netdisk' }))
        stub.to_return(body: '{"result":"1"}')
        rest = @client.has_app_permission? 'netdisk'
        stub.should have_been_requested
        expect(rest).to eq(true)
      end

      it 'requests "hasAppPermission" for specified user' do
        stub = stub_post(:oauth_rest,
                         '/passport/users/hasAppPermission',
                         base_query.update({ ext_perm: 'super_msg', uid: '456123' }))
        stub.to_return(body: '{"result":"0"}')
        rest = @client.has_app_permission?('super_msg', '456123')
        stub.should have_been_requested
        expect(rest).to eq(false)
      end
    end

    describe '#has_app_permissions' do
      it 'requests "hasAppPermissions" api' do
        stub = stub_post(:oauth_rest,
                         '/passport/users/hasAppPermissions',
                         base_query.update({ ext_perms: 'netdisk,basic' }))
        stub.to_return(body: '{"basic":"1", "netdisk":"0"}')
        rest = @client.has_app_permissions 'netdisk,basic'
        stub.should have_been_requested
        expect(rest[:basic]).to   eq(true)
        expect(rest[:netdisk]).to eq(false)
      end

      it 'requests "hasAppPermissions" api with array of perms' do
        stub = stub_post(:oauth_rest,
                         '/passport/users/hasAppPermissions',
                         base_query.update({ ext_perms: 'netdisk,basic' }))
        stub.to_return(body: '{"basic":"1", "netdisk":"0"}')
        rest = @client.has_app_permissions %w[netdisk basic]
        stub.should have_been_requested
        expect(rest[:basic]).to   eq(true)
        expect(rest[:netdisk]).to eq(false)
      end

      it 'requests "hasAppPermissions" for specified user' do
        stub = stub_post(:oauth_rest,
                         '/passport/users/hasAppPermissions',
                         base_query.update({ ext_perms: 'super_msg', uid: '456123' }))
        stub.to_return(body: '{"super_msg":"0"}')
        rest = @client.has_app_permissions('super_msg', '456123')
        stub.should have_been_requested
        expect(rest[:super_msg]).to eq(false)
      end
    end

    describe '#get_friends' do
      it 'requests with default params' do
        stub = stub_post(:oauth_rest, '/friends/getFriends', base_query)
        @client.get_friends
        stub.should have_been_requested
      end

      it 'requests with custom params' do
        stub = stub_post(:oauth_rest,
                         '/friends/getFriends',
                         base_query.update({ page_no: 3, page_size: 10, sort_type: 1 }))
        @client.get_friends page_no: 3, page_size: 10, sort_type: 1
        stub.should have_been_requested
      end

      it 'returns result of an array' do
        stub = stub_post(:oauth_rest, '/friends/getFriends', base_query.update(page_size: 2))
        stub.to_return(body: ft('get_friends.json'))
        rest = @client.get_friends page_size: 2
        stub.should have_been_requested
        expect(rest).to be_a Array
        expect(rest.size).to be(2)
      end
    end

    describe '#are_friends' do
      it 'requests with both string params' do
        stub = stub_post(:oauth_rest,
                         '/friends/areFriends',
                         base_query.update(uids1: '111', uids2: '222'))
        @client.are_friends '111', '222'
        stub.should have_been_requested
      end

      it 'requests with both array params' do
        stub = stub_post(:oauth_rest,
                         '/friends/areFriends',
                         base_query.update(uids1: '111,333', uids2: '222,444'))
        @client.are_friends %w[111 333], %w[222 444]
        stub.should have_been_requested
      end

      it 'requests with different param type' do
        expect {
          @client.are_friends '111', %w[222]
        }.to raise_error ArgumentError, 'not the same types'
      end

      it 'requests with different size of array params' do
        expect {
          @client.are_friends %w[111], %w[222, 333]
        }.to raise_error ArgumentError, 'not the same size of array'
      end

      it 'changes result with true or false' do
        stub = stub_post(:oauth_rest,
                         '/friends/areFriends',
                         base_query.update(uids1: '111,333', uids2: '222,444'))
        stub.to_return(body: ft('are_friends.json'))
        rest = @client.are_friends %w[111 333], %w[222 444]
        stub.should have_been_requested
        expect(rest.first[:are_friends]).to eq(true)
        expect(rest.first[:are_friends_reverse]).to eq(false)
        expect(rest.last[:are_friends]).to eq(false)
        expect(rest.last[:are_friends_reverse]).to eq(true)
      end
    end

    describe '#expire_session' do
      it 'requests "expireSession" api successfully' do
        stub = stub_post(:oauth_rest,
                         '/passport/auth/expireSession',
                         base_query)
        stub.to_return(body: '{"result":"1"}')
        rest = @client.expire_session
        stub.should have_been_requested
        expect(rest).to eq(true)
      end

      it 'requests "expireSession" api unsuccessfully' do
        stub = stub_post(:oauth_rest,
                         '/passport/auth/expireSession',
                         base_query)
        stub.to_return(body: '{"result":"0"}')
        rest = @client.expire_session
        stub.should have_been_requested
        expect(rest).to eq(false)
      end
    end

    describe '#revoke_authorization' do
      it 'requests "revokeAuthorization" api successfully' do
        stub = stub_post(:oauth_rest,
                         '/passport/auth/revokeAuthorization',
                         base_query)
        stub.to_return(body: '{"result":"1"}')
        rest = @client.revoke_authorization
        stub.should have_been_requested
        expect(rest).to eq(true)
      end

      it 'requests "revokeAuthorization" api with uid successfully' do
        stub = stub_post(:oauth_rest,
                         '/passport/auth/revokeAuthorization',
                         base_query.update({ uid: 123654 }))
        stub.to_return(body: '{"result":"1"}')
        rest = @client.revoke_authorization '123654'
        stub.should have_been_requested
        expect(rest).to eq(true)
      end

      it 'requests "revokeAuthorization" api unsuccessfully' do
        stub = stub_post(:oauth_rest,
                         '/passport/auth/revokeAuthorization',
                         base_query)
        stub.to_return(body: '{"result":"0"}')
        rest = @client.revoke_authorization
        stub.should have_been_requested
        expect(rest).to eq(false)
      end
    end

    describe '#query_ip' do
      it 'requests single ip' do
        stub = stub_get(:oauth_rest,
                         '/iplib/query',
                         base_query.update({ ip: '111.222.111.222' }))
        stub.to_return(body: '{"111.222.111.222":{"province":"\u5e7f\u4e1c","city":"\u6df1\u5733"}}')
        rest = @client.query_ip '111.222.111.222'
        stub.should have_been_requested
        expect(rest).to have_key(:'111.222.111.222')
      end

      it 'requests multiple ips' do
        stub = stub_get(:oauth_rest,
                         '/iplib/query',
                         base_query.update({ ip: '111.222.111.222,8.8.8.8' }))
        @client.query_ip '111.222.111.222', '8.8.8.8'
        stub.should have_been_requested
      end

      it 'requests multiple ips as array' do
        stub = stub_get(:oauth_rest,
                         '/iplib/query',
                         base_query.update({ ip: '111.222.111.222,8.8.8.8,8.8.4.4' }))
        @client.query_ip ['111.222.111.222', '8.8.8.8', '8.8.4.4']
        stub.should have_been_requested
      end
    end

    describe 'when process error' do
      it 'does not raise error' do
        expect {
          @client.send(:process_error, ['hi'])
          @client.send(:process_error, {num: 0})
          @client.send(:process_error, {error_code: 0})
        }.not_to raise_error
      end

      it 'raises Baidu::Errors::Error' do
        expect {
          @client.send(:process_error, {error_code: 1})
        }.to raise_error Baidu::Errors::Error
      end

      it 'raises Baidu::Errors::AuthError' do
        expect {
          @client.send(:process_error, {error_code: 110})
        }.to raise_error Baidu::Errors::AuthError
      end
    end
  end
end
