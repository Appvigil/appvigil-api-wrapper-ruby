
require "./auto-loader"
require 'pp'

options = FetchInput.new()#.parse(ARGV)
log = KLogger.new(VERBOSE)

errorMessage = []
accessToken = nil
uploadId = nil
scanId = nil

if (API_KEY && API_SECRET && APP_LOC)
  log.LogInfo('-------------------------')
  log.LogInfo('APPVIGIL SCAN LAUNCHER')
  log.LogInfo('-------------------------')
  log.LogInfo('Generating AccessToken...')

  accessTokenResult = AccessToken.new(API_KEY, API_SECRET).requestAccessToken(TTL, APP_KEY)

  if (defined?(accessTokenResult['meta']['code'])).nil? # will now return true or false
   log.LogInfo('Damn!!! Unable to generate AccessToken...')
   log.LogInfo('Reason '+accessTokenResult.to_s)
   log.LogInfo('I am Sorry...Quitting')
   abort()
  end

  log.LogDebug(accessTokenResult.to_s)#inspect
  metaCode = accessTokenResult['meta']['code']
  #abort
  if (metaCode == Const::SUCCESS)
    log.LogInfo('AccessToken Generated :)')
    accessToken = accessTokenResult['response']['access_token']
    log.LogInfo('AccessToken is: ' + accessToken)
  else
    log.LogInfo('Damn!!! Unable to generate AccessToken...')
    log.LogInfo('Reason: ' + accessTokenResult['response']['message'])
    log.LogInfo('I am Sorry...Quitting')
    abort()#errorMessage << accessTokenResult['response']['message']
  end
  
  if(accessToken)
    log.LogInfo('Uploading APK file to Appvigil Cloud...This may take a while')
    uploadResult = Upload.new(accessToken).uploadNew(APP_LOC, APP_NAME, DISABLE_DIGEST_CHECK)
    log.LogDebug(uploadResult.to_s)
    
    if (!uploadResult)
      log.LogInfo("Oppss!!! Provided apk file is not a valid android app...")
      log.LogInfo("I am Sorry...Quitting")
      abort()
    end
    
    metaCode = uploadResult['meta']['code']
    if (metaCode == Const::UPLOAD_SUCCESS || metaCode == Const::DIGEST_SUCCESS)
      log.LogInfo("App has been uploaded successfully...")
      uploadId = uploadResult['response']['upload_id']
      log.LogInfo("Upload ID is: " + uploadId.to_s)
    else
      log.LogInfo("Damn!!! Unable to upload apk file to Appvigil Cloud...")
      log.LogInfo("Reason: " + uploadResult['response']['message'])
      log.LogInfo("I am Sorry...Quitting")
      abort()#errorMessage << uploadResult['response']['message']
    end
    
    if(uploadId)
      log.LogInfo("Launching vulnerability scan..")
      scanStartResult = Scan.new(accessToken).scanStart(uploadId, CREDENTIALS)
      log.LogDebug(scanStartResult.to_s)
      
      metaCode = scanStartResult['meta']['code']
      
      if (metaCode == Const::SCAN_STARTED)
        log.LogInfo("Scan launched successfully...")
        scanId = scanStartResult['response']['scan_id']
        log.LogInfo("Scan ID is: " + scanId.to_s);
      else
        log.LogInfo("Damn!!! Unable to launch scan...")
        log.LogInfo("Reason: " + scanStartResult['response']['message'])
        log.LogInfo("I am Sorry...Quitting")
        abort()#errorMessage << scanStartResult['response']['message']
      end
      
      if(scanId)
        log.LogInfo("Scan running...it will be over in few minutes ")
        log.LogInfo("Please wait...")
        statusCheck = false
        startTime = Time.now
        
        while(!statusCheck) do
          scanStatusResult = Scan.new(accessToken).scanStatus(scanId)
          metaCode = scanStatusResult['meta']['code']
          if (metaCode == Const::SUCCESS)
            scanStatus = scanStatusResult['response']['scan_status']

=begin
            if (Time.now > startTime + 5)
              scanStatus = 'Finished'
            end
=end

            if(scanStatus != 'Pending' && scanStatus != "Running")
              statusCheck = true
              
              log.LogInfo("Scan Finished.")
              log.LogDebug(scanStatusResult.to_s)
              log.LogInfo("Scan Status: " + scanStatus)
              log.LogInfo("Scan report is available at: " + scanStatusResult['response']['report_url'].to_s)
              exit
            end#scan status pending
          else
            log.LogInfo("Damn!!! Unable to fetch scan status...")
            log.LogInfo("Reason: " + scanStatusResult['response']['message'])
            log.LogInfo("Let me retry...")
            statusCheck = true
          end#meta success
          sleep 5
        end#while

      else#if scan id else
        puts errorMessage
      end
    
    else
      puts errorMessage
    end
  
  else
    puts errorMessage
  end
  
else
  puts errorArray
end

