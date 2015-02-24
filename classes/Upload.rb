require File.expand_path('../../classes/HttpConnection', __FILE__)
require 'rubygems'
require 'json'
require 'rest_client'

class Upload
  @appLoc = nil
  @accessToken = nil
  def initialize(accessToken)
    if(accessToken.empty?)
      return false
     else
      @accessToken = accessToken
    end
  end

  def uploadNew(appLocation, appName, digestEnable)

    @digestResult = nil
    if (!digestEnable)
      appDegist = Digest::SHA256.hexdigest File.read appLocation
      params = { :access_token => @accessToken, :app_digest => appDegist, :app_name => appName}
      uploadNewResult = HttpConnection.new().post("UPLOAD_NEW", params)
      result = JSON.parse(uploadNewResult)
      if (result['meta']['code'] == Const::APP_DIGEST_NOT_EXIST)
        digestEnable = true
        @digestResult = result['meta']['code']
      else
        digestEnable = false
        return result;
      end
    end

    if(digestEnable || @digestResult == Const::APP_DIGEST_NOT_EXIST)
      if (File.file?(appLocation))
        params = { :access_token => @accessToken, :app => File.new(appLocation), :app_name => appName}
        uploadNewResult = HttpConnection.new().post("UPLOAD_NEW", params)
        return JSON.parse(uploadNewResult)
      else
        return false
      end
    end

  end
  def uploadList(count, thisSes)
    params = { :access_token => @accessToken, :count => count, :this_ses => thisSes }
    uploadListResult = HttpConnection.new().get("UPLOAD_LIST", params)
    return JSON.parse(uploadListResult.body)
  end
  def uploadDetails(uploadId)
    params = { :access_token => @accessToken, :upload_id => uploadId }
    uploadDetailsResult = HttpConnection.new().get("UPLOAD_DETAILS", params)
    return JSON.parse(uploadDetailsResult.body)
  end
end