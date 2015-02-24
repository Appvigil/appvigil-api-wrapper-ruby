module Conf

  HOMEPAGE = "appvigil.co"
  
  APIPROTO = "https"
  APIHOST = "api.appvigil.co/v1.0"
  RESOURCE = {"REQUEST_NEW_TOKEN" => "access_token/request/",
    "RENEW_TOKEN" => "access_token/renew/",
    "VIEW_TOKEN" => "access_token/view/",
    "FLUSH_TOKEN" => "access_token/flush/",
    "UPLOAD_NEW" => "upload/new/",
    "UPLOAD_LIST" => "upload/list/",
    "UPLOAD_DETAILS" => "upload/details/",
    "SCAN_START" => "scan/start/",
    "SCAN_LIST" => "scan/list/",
    "SCAN_STATUS" => "scan/status/"
  }

  USER_AGENT = "RUBY_CLI"
end

