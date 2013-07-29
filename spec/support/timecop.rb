RSpec.configure do |config|
  config.before(:each) { Timecop.freeze(Time.zone.parse("2000-01-01")) }
  config.after(:each)  { Timecop.return }
end
