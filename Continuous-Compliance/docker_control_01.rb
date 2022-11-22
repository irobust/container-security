describe docker_container(name: 'some-rabbit') do
    its('image') { should eq 'rabbitmq' }
end

describe docker.containers() do
    its('images') { should_not include 'nodejs' }
end

describe docker.containers.where { names == 'some-rabbit' } do
    its('images') { should include 'rabbitmq' }
    it { should exist }
end

describe command("docker history irobust/weather:1.0| grep 'ADD'") do
    its('stdout') { should match /ADD\s+file/ }
end