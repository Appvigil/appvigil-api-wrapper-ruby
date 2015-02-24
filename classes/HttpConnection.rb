require 'net/http'
require 'rubygems'
require 'rest_client'
require File.expand_path('../../config/Config', __FILE__)

class HttpConnection
  def get(res, params)
    uri = URI(Conf::APIPROTO+'://'+Conf::APIHOST+'/'+Conf::RESOURCE[res])

    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request.initialize_http_header({"User-Agent" => Conf::USER_AGENT})

    res = http.request(request)

    if res.is_a?(Net::HTTPSuccess)
      return res
    else
      return res.code
    end
  end

  def post(res, params)
    uri = Conf::APIPROTO+'://'+Conf::APIHOST+'/'+Conf::RESOURCE[res]
    #uri.query = URI.encode_www_form(params), {:content_type => :json, :accept => :json}
    res = RestClient.post(uri , params, :user_agent => Conf::USER_AGENT)
    if res
      return res
    end
  end
end
