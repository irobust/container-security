# describe kernel_module('cramfs') do
#   it { should_not be_loaded }
#   it { should be_disabled }
#   it { should be_blacklisted }
# end

describe file('/tmp/rabbitmq-ssl') do
  it { should be_directory }
end