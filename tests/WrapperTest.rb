require "test/unit"
require "./TestInput"
require File.expand_path('../../classes/AccessToken', __FILE__)
require File.expand_path('../../classes/Upload', __FILE__)
require File.expand_path('../../classes/Scan', __FILE__)
require File.expand_path('../../config/Constant', __FILE__)

class WrapperTest < Test::Unit::TestCase

  @@accessToken = nil
  @@uploadId = nil
  @@scanId = nil
  
  def test_1_AccessTokenConstructSuccess
    accessTokenResult = AccessToken.new(API_KEY, API_SECRET)
    assert_instance_of(AccessToken, accessTokenResult, 'AccessToken construct test return non-object' )
    assert_equal(API_KEY, accessTokenResult.instance_variable_get(:@apiKey), "Api key not set")
    assert_equal(API_SECRET, accessTokenResult.instance_variable_get(:@apiSecret), "Api secret not set")
  end
  
  def test_2_AccessTokenConstructError
    accessTokenResult = AccessToken.new()
    assert_instance_of(AccessToken, accessTokenResult, 'AccessToken construct test return non-object' )
    assert_equal(nil, accessTokenResult.instance_variable_get(:@apiKey), "Api key is set")
    assert_equal(nil, accessTokenResult.instance_variable_get(:@apiSecret), "Api secret is set")
  end
  
  def test_11_requestAccessTokenSuccess
    accessTokenResult = AccessToken.new(API_KEY, API_SECRET).requestAccessToken("", '')
    assert_equal(Const::SUCCESS, accessTokenResult["meta"]["code"], "Generate access token not success")
    assert_not_equal("", accessTokenResult["response"]["message"], "Response mesage is empty")
    @@accessToken = accessTokenResult["response"]["access_token"]
  end
  
  def test_12_requestAccessTokenError
    accessTokenResult = AccessToken.new("", "").requestAccessToken("", '')
    assert_equal(Const::INSUFFICIENT_PARAMETER, accessTokenResult["meta"]["code"], "Expected key required")
    assert_not_equal("", accessTokenResult["response"]["message"], "Response mesage is empty")
    
    accessTokenResult = AccessToken.new("123456789", "123456789").requestAccessToken("", '')
    assert_equal(Const::INVALID_API_LEN, accessTokenResult["meta"]["code"] )
    assert_not_equal("", accessTokenResult["response"]["message"], "Response mesage is empty")
    
    accessTokenResult = AccessToken.new("12345678$9", "12345678$9").requestAccessToken("", '')
    assert_equal(Const::SPECIALCHAR_IN_KEY, accessTokenResult["meta"]["code"] )
    assert_not_equal("", accessTokenResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_13_renewAccessTokenSuccess
    renewTokenResult = AccessToken.new(@@accessToken).renewAccessToken("")
    assert_equal(Const::ACCESS_TOKEN_EXTENDED, renewTokenResult["meta"]["code"], "Extend access_token not success")
    assert_not_equal("", renewTokenResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_14_renewAccessTokenError
    renewTokenResult = AccessToken.new("12345678900123456789").renewAccessToken("")
    assert_equal(Const::INVALID_TOKEN, renewTokenResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", renewTokenResult["response"]["message"], "Response mesage is empty")
    
    renewTokenResult = AccessToken.new("123456789001234567$9").renewAccessToken("")
    assert_equal(Const::SPECIALCHAR_IN_TOKEN, renewTokenResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", renewTokenResult["response"]["message"], "Response mesage is empty")
    
    renewTokenResult = AccessToken.new("1234567890").renewAccessToken("")
    assert_equal(Const::INVALID_TOKEN_LEN, renewTokenResult["meta"]["code"])
    assert_not_equal("", renewTokenResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_15_viewAccessTokenSuccess
    viewTokenResult = AccessToken.new(@@accessToken).viewAccessToken()
    assert_equal(Const::SUCCESS, viewTokenResult["meta"]["code"], "View access_token not success")
    assert_not_equal("", viewTokenResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_16_viewAccessTokenError
    viewTokenResult = AccessToken.new('1234567890012345679').viewAccessToken()
    assert_equal(Const::INVALID_TOKEN_LEN, viewTokenResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", viewTokenResult["response"]["message"], "Response mesage is empty")
    
    viewTokenResult = AccessToken.new('123456789001234567$9').viewAccessToken()
    assert_equal(Const::SPECIALCHAR_IN_TOKEN, viewTokenResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", viewTokenResult["response"]["message"], "Response mesage is empty")
    
    viewTokenResult = AccessToken.new('1234567890').viewAccessToken()
    assert_equal(Const::INVALID_TOKEN_LEN, viewTokenResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", viewTokenResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_21_UploadConstructSuccess
    uploadResult = Upload.new(@@accessToken)
    assert_instance_of(Upload, uploadResult, 'Upload construct test return non-object' )
    assert_equal(@@accessToken, uploadResult.instance_variable_get(:@accessToken), "Access token not set")
  end
  def test_22_UploadConstructError
    uploadResult = Upload.new("")
    assert_instance_of(Upload, uploadResult, 'Upload construct test return non-object' )
    assert_equal(nil, uploadResult.instance_variable_get(:@accessToken), "Access token is set")
  end
  
  def test_23_UploadNewSuccess
    uploadObject = Upload.new(@@accessToken)
    uploadResult = uploadObject.uploadNew(APP_LOC, 'phpwrappertestapp', true)

    assert_equal(Const::UPLOAD_SUCCESS, uploadResult["meta"]["code"])
    uploadid =  !uploadResult["response"]["upload_id"].match(/[^A-Za-z0-9]/)
    assert_equal(true, uploadid , "Upload id not alpha numeric")
    assert_not_equal("", uploadResult["response"]["message"], "Response mesage is empty")
    
    @@uploadId = uploadResult["response"]["upload_id"]

    uploadResult = uploadObject.uploadNew(APP_LOC, 'phpwrappertestapp', false)

    assert_equal(Const::DIGEST_SUCCESS, uploadResult["meta"]["code"])
    uploadid =  !uploadResult["response"]["upload_id"].match(/[^A-Za-z0-9]/)
    assert_equal(true, uploadid , "Upload id not alpha numeric")
    assert_not_equal("", uploadResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_23_UploadNewError
    uploadObject = Upload.new(@@accessToken)
    uploadResult = uploadObject.uploadNew(E_APP_LOC, 'phpwrappertestapp', true)
    assert_equal(false, uploadResult, "Error upload return some data")
    
    uploadObject = Upload.new(@@accessToken)
    uploadResult = uploadObject.uploadNew(INV_APP_LOC, 'phpwrappertestapp', true)
    
    assert_equal(Const::CORRUPTED_APP, uploadResult["meta"]["code"], "Expected invalid Upload File")
    assert_not_equal("", uploadResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_24_uploadListSuccess
    uploadObject = Upload.new(@@accessToken)
    uploadResult = uploadObject.uploadList('', 'false')
    
    assert_equal(Const::SUCCESS, uploadResult["meta"]["code"], "Expected Upload list success")
    assert_not_equal("", uploadResult["response"]["message"], "Response mesage is empty")
  end
  def test_25_uploadListError
    uploadObject = Upload.new("12345678901234567890")
    uploadResult = uploadObject.uploadList('', 'false')
    
    assert_equal(Const::INVALID_TOKEN, uploadResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", uploadResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_26_uploadDetailsSuccess
    uploadObject = Upload.new(@@accessToken)
    uploadResult = uploadObject.uploadDetails(@@uploadId)
    
    assert_equal(Const::SUCCESS, uploadResult["meta"]["code"], "Expected upload details success")
    assert_not_equal("", uploadResult["response"]["message"], "Response mesage is empty")
  end
  def test_27_uploadDetailsError
    uploadObject = Upload.new(@@accessToken)
    uploadResult = uploadObject.uploadDetails('6666666')
    
    assert_equal(Const::INVALID_UPLOAD_REF_LEN, uploadResult["meta"]["code"], "Expected invalid Upload Id")
    assert_not_equal("", uploadResult["response"]["message"], "Response mesage is empty")

    uploadResult = uploadObject.uploadDetails('b$99b08c270b6165369dd857e8d20c0d7b31e9f8')
    
    assert_equal(Const::SPECIALCHAR_IN_UPLOAD_REF, uploadResult["meta"]["code"], "Expected invalid Upload Id")
    assert_not_equal("", uploadResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_31_ScanConstructSuccess
    scanObject = Scan.new(@@accessToken)
    assert_instance_of(Scan, scanObject, 'Scan construct test return non-object' )
    assert_equal(@@accessToken, scanObject.instance_variable_get(:@accessToken), "Expected accessToken set")
  end
  def test_32_ScanConstructError
    scanObject = Scan.new("")
    assert_instance_of(Scan, scanObject, 'Scan construct test return non-object' )
    assert_equal(nil, scanObject.instance_variable_get(:@accessToken), "Expected access token not set")
  end
  
  def test_33_scanStartSuccess
    scanObject = Scan.new(@@accessToken)
    scanResult = scanObject.scanStart(@@uploadId, '')
    assert_equal(Const::SCAN_STARTED, scanResult["meta"]["code"], "Expected Scan start successfull")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")
    
    scanid =  !scanResult["response"]["scan_id"].match(/[^A-Za-z0-9]/)
    assert_equal(true, scanid)
    @@scanId = scanResult["response"]["scan_id"]
  end
  def test_34_scanStartError
    scanObject = Scan.new(@@accessToken)
    scanResult = scanObject.scanStart(@@uploadId, '')
    assert_equal(Const::UPLOAD_ID_IN_PROCESS, scanResult["meta"]["code"], "Expected Uploadid in process")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")
    
    scanResult = scanObject.scanStart(6666666, '')
    assert_equal(Const::INVALID_UPLOAD_REF_LEN, scanResult["meta"]["code"], "Expected invalid upload id")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")

  end
  
  def test_35_scanListSuccess
    scanObject = Scan.new(@@accessToken)
    scanResult = scanObject.scanList('*')
    assert_equal(Const::SUCCESS, scanResult["meta"]["code"], "Expected scan success")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")
  end
  def test_36_scanListError
    scanObject = Scan.new('12345678901234567890')
    scanResult = scanObject.scanList(0)
    assert_equal(Const::INVALID_TOKEN, scanResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")
    
    scanObject = Scan.new(@@accessToken)
    scanResult = scanObject.scanList(8)
    assert_equal(Const::INVALID_SCAN_STATUS, scanResult["meta"]["code"], "Expected scan empty")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_37_scanStatusSuccess
    scanObject = Scan.new(@@accessToken)
    scanResult = scanObject.scanStatus(@@scanId)
    assert_equal(Const::SUCCESS, scanResult["meta"]["code"], "Expected scan status success")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")
  end
  def test_38_scanStatusError
    scanObject = Scan.new('12345678901234567890')
    scanResult = scanObject.scanStatus(@@scanId)
    assert_equal(Const::INVALID_TOKEN, scanResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")
    
    scanObject = Scan.new(@@accessToken)
    scanResult = scanObject.scanStatus('777777777')
    assert_equal(Const::INVALID_SCAN_ID, scanResult["meta"]["code"], "Expected invalid scanid")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")

    scanResult = scanObject.scanStatus('2$668fb5002164555e54c7d85b112b25b36672f9e59049545864b64b234e')
    assert_equal(Const::INVALID_SCAN_ID, scanResult["meta"]["code"], "Expected invalid scanid")
    assert_not_equal("", scanResult["response"]["message"], "Response mesage is empty")
  end
  
  def test_41_flushAccessToken
    flushTokenResult = AccessToken.new(@@accessToken).flushAccessToken()
    assert_equal(Const::ACCESS_TOKEN_FLUSHED, flushTokenResult["meta"]["code"], "Expected token flushed")
    assert_not_equal("", flushTokenResult["response"]["message"], "Response mesage is empty")
  end
  def test_42_flushAccessError
    flushTokenResult = AccessToken.new('1234567890012345679').flushAccessToken()
    assert_equal(Const::INVALID_TOKEN_LEN, flushTokenResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", flushTokenResult["response"]["message"], "Response mesage is empty")
    
    flushTokenResult = AccessToken.new('123456789001234567$9').flushAccessToken()
    assert_equal(Const::SPECIALCHAR_IN_TOKEN, flushTokenResult["meta"]["code"], "Expected invalid token")
    assert_not_equal("", flushTokenResult["response"]["message"], "Response mesage is empty")
    
    flushTokenResult = AccessToken.new('12345678900').flushAccessToken()
    assert_equal(Const::INVALID_TOKEN_LEN, flushTokenResult["meta"]["code"], "Expected Invalid token")
    assert_not_equal("", flushTokenResult["response"]["message"], "Response mesage is empty")
  end

end
