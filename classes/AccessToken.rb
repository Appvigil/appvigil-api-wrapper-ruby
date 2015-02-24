
require File.expand_path('../../classes/HttpConnection', __FILE__)
require 'rubygems'
require 'json'

class AccessToken
  @apiKey = nil
  @apiSecret = nil
  @accessToken = nil
  def initialize *args
    case args.size
      when 2
        @apiKey = args[0]
        @apiSecret = args[1]
      when 1
        @accessToken = args[0]
       else
        return false
      end
  end

  def requestAccessToken(ttl, appKey)
    params = { :api_key => @apiKey, :api_secret => @apiSecret , :ttl => ttl, :appvigil_app_key => appKey}
    newTokenRequest = HttpConnection.new().get("REQUEST_NEW_TOKEN", params)
    return JSON.parse(newTokenRequest.body)
  end
  def renewAccessToken(ttl)
    params = { :access_token => @accessToken, :ttl => ttl }
    renewTokenResult = HttpConnection.new().get("RENEW_TOKEN", params)
    return JSON.parse(renewTokenResult.body)
  end
  def viewAccessToken
    params = { :access_token => @accessToken }
    viewTokenResult = HttpConnection.new().get("VIEW_TOKEN", params)
    return JSON.parse(viewTokenResult.body)
  end
  def flushAccessToken
    params = { :access_token => @accessToken }
    flushTokenResult = HttpConnection.new().get("FLUSH_TOKEN", params)
    return JSON.parse(flushTokenResult.body)
  end
end