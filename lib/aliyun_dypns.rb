require "aliyun_dypns/version"
require "aliyunsdkcore"

begin
  require "pry"
rescue LoadError
end

module AliyunDypns
  class Configuration
    attr_accessor :access_key_id, :access_key_secret,
                  :region_id, :api_version,
                  :sign_name

    def initialize
      @access_key_id = ""
      @access_key_secret = ""
      @sign_name = ""
      @region_id = "cn-hangzhou"
      @api_version = "2017-05-25"
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # {
    #   "Message": "请求成功",
    #   "RequestId": 8906582,
    #   "Code": "OK",
    #   "GetMobileResultDTO": {
    #     "Mobile": 121343241
    #   }
    # }

    def get_mobile(access_token, out_id = "")
      response = client.request(
        action: "GetMobile",
        params: {
          "RegionId": configuration.region_id,
          "AccessToken": access_token,
          "OutId": out_id,
        },
        opts: { method: "POST" },
      )
      response.dig("GetMobileResultDTO", "Mobile")
    rescue StandardError => e
      { Code: "BadRequest", Message: "Request failed: #<#{e.class}: #{e.message}>" }
    end

    # {
    #   "GateVerifyResultDTO": {
    #     "VerifyResult": "PASS",
    #     "VerifyId": 121343241
    #   },
    #   "Message": "请求成功",
    #   "RequestId": 8906582,
    #   "Code": "OK"
    # }
    # PASS：一致。 REJECT：不一致。 UNKNOWN：无法判断。
    def verify_mobile(access_code, phone_number, out_id = "")
      response = client.request(
        action: "VerifyMobile",
        params: {
          "RegionId": configuration.region_id,
          "AccessCode": access_code,
          "PhoneNumber": phone_number,
          "OutId": out_id,
        },
        opts: { method: "POST" },
      )

      response.dig("GateVerifyResultDTO", "VerifyResult")
    rescue StandardError => e
      { Code: "BadRequest", Message: "Request failed: #<#{e.class}: #{e.message}>" }
    end

    def client
      @client ||= RPCClient.new(
        access_key_id: configuration.access_key_id,
        access_key_secret: configuration.access_key_secret,
        api_version: configuration.api_version,
        endpoint: "https://dypnsapi.aliyuncs.com",
      )
    end
  end
end
