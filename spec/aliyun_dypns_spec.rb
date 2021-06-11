RSpec.describe AliyunDypns do
  describe "AliyunDypns" do
    before  do
      AliyunDypns.configure do |config|
        config.access_key_id = "test_access_key_id"
        config.access_key_secret = "test_access_key_secret"
      end
    end

    it "get_mobile" do
      token = "access token from sdk"
      mobile = AliyunDypns.get_mobile(token)

      expect(mobile).to be_kind_of(String)
      expect(mobile).not_to be_empty
    end
  end
end
