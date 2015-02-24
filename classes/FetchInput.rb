require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'
require "./config/Constant"
require "./classes/KLogger"

class FetchInput

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    
    options.apiKey = nil
    options.apiSecret = nil
    options.appLoc = nil
    options.ttl = nil
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: appvigil-api.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"
  
      # Mandatory argument.
      opts.on("-K", "--api-key [ApiKey]",
              "Require the ApiKey before executing your script") do |apikey|
        options.apiKey = apikey
      end
      
      # Mandatory argument.
      opts.on("-S", "--api-secret [ApiSecret]",
              "Require the ApiSecret before executing your script") do |apisecret|
        options.apiSecret = apisecret
      end
      
      # Mandatory argument.
      opts.on("-L", "--app-loc [AppLocation]",
              "Require the AppLocation before start your scan") do |loc|
        options.appLoc = loc
      end

      # Mandatory argument.
      opts.on("-N", "--app-name [App name]",
              "Require the app name to store") do |name|
        options.appName = name
      end

      # Optional argument; multi-line description.
      opts.on("-t", "--ttl [TIME TO LIVE]",
              "(optional)") do |ttl|
        options.ttl = ttl || nil
      end

      # Optional argument; multi-line description.
      opts.on("-C", "--credentials [CREDENTIALS]",
              "(optional)") do |ref|
        options.credentials = ref || nil
      end

      # Optional argument; multi-line description.
      opts.on("-D", "--app-key [app-key]",
              "(optional)") do |key|
        options.appKey = key || nil
      end

      # Boolean switch.
      opts.on("-v", "--verbose", "Run verbosely") do |v|
        options.verbose = v
      end

      # Boolean switch.
      opts.on("-d", "--disable-digest-check", "Disable digest for fresh upload") do |dig|
        options.disableDigestCheck = dig
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts "[ appvigi-api ] V1.0"
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end  # parse()

end  # class FetchInput

options = FetchInput.parse(ARGV)

VARIABLE_SET = []
ERROR_ARRAY = []

if options.verbose
    VERBOSE = 1
else
    VERBOSE = 2 
end

DISABLE_DIGEST_CHECK = options.disableDigestCheck

if options.ttl
    TTL = options.ttl
else
    TTL = ''
end

#credentials
if options.credentials
    CREDENTIALS = options.credentials
    credentialArray = CREDENTIALS.split(',')

    credentialArray.each do|n|
      if n.length != 8
        VARIABLE_SET << "no"
        ERROR_ARRAY << "Given credentials length not valid"
      end
      
      r = /^[A-Za-z0-9]+$/
      if r.match(n).nil?
        VARIABLE_SET << "no"
        ERROR_ARRAY << "Given credentials not valid"
      end
    end 
else
    CREDENTIALS = ''
end

#appvigil app key
if options.appKey
    APP_KEY = options.appKey
else
    APP_KEY = ''
end

if (!options.apiKey)
  VARIABLE_SET << "no"
  ERROR_ARRAY << "use --api-key. Api key required"
else
  API_KEY = options.apiKey
end
if (!options.apiSecret)
  VARIABLE_SET << "no"
  ERROR_ARRAY << "use --api-secret. Api Secret required"
else
  API_SECRET = options.apiSecret
end
if (!options.appLoc)
  VARIABLE_SET << "no"
  ERROR_ARRAY << "use --app-loc. App location required"
else
  APP_LOC = options.appLoc
  if not (File.file?(APP_LOC))
    VARIABLE_SET << "no"
    ERROR_ARRAY << "use --app-loc. APP dosn't exist in this location"
  else
    file_formats = [".apk"]
    if not (file_formats.include? File.extname(APP_LOC))
      VARIABLE_SET << "no"
      ERROR_ARRAY << "use --app-loc. Sorry! only you can upload apk file"
    end
  end
end

if (!options.appName)
  VARIABLE_SET << "no"
  ERROR_ARRAY << "use --app-name. App name required"
else
  APP_NAME = options.appName
end

if VARIABLE_SET.index("no")
  puts "--------------------------------------"
  puts "APPVIGIL RUBY WRAPPER "
  puts "--------------------------------------"
  puts "use --help to show the help's message"
  puts ERROR_ARRAY
  abort
end