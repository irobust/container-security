describe docker_container(name: 'amazing_kepler') do
    its('image') { should eq 'rabbitmq' }
end

describe docker.containers() do
    its('images') { should_not include 'nodejs' }
end

describe docker.containers.where { names == 'amazing_kepler' } do
    its('images') { should include 'rabbitmq' }
    it { should be_running }
end