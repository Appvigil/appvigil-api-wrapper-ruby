require File.expand_path('../../classes/HttpConnection', __FILE__)
require 'rubygems'
require 'json'

class Scan
  @accessToken = nil
  def initialize(accessToken)
    if(accessToken.empty?)
      return false
     else
      @accessToken = accessToken
    end
  end

  def scanStart(uploadId, credentials)
    params = { :access_token => @accessToken, :upload_id => uploadId, :credential_id => credentials }
    scanStartResult = HttpConnection.new().get("SCAN_START", params)
    return JSON.parse(scanStartResult.body)
  end
  def scanList(statusType)
    params = { :access_token => @accessToken, :status_type => statusType }
    scanListResult = HttpConnection.new().get("SCAN_LIST", params)
    return JSON.parse(scanListResult.body)
  end
  def scanStatus(scanId)
    params = { :access_token => @accessToken, :scan_id => scanId }
    scanStatusResult = HttpConnection.new().get("SCAN_STATUS", params)
    return JSON.parse(scanStatusResult.body)
  end
end