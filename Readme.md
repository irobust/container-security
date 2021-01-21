# Container Security
### Hadolint
* hadolint /path/to/Dockerfile
* hadolint /path/to/Dockerfile --ignore DL3006

### Build Node with non-root user
* docker exec c08 ps -o pid,user (Check ID)
* docker build -t nodejs -f node.Dockerfile .
* docker run -d nodejs
* docker exec [Contianer ID] ps -o pid,user

### Compare with user in host machine
* docker inspect --format='{{ .State.Pid }}' [Container ID]
* ps -p [Process ID from previous command] -o pid,user

### Docker Content Trust
* export DOCKER_CONTENT_TRUST=1 (On Windows setting Enviroment Variables)
* docker pull williamyeh/json-server (Can't pull this image)
* docker pull --disable-content-trust=true williamyeh/json-server (Pull unsign image sucessfully)
* notary -s https://notary.docker.io list docker.io/library/alpine

### Using Apparmor
* apparmor_parser -r -W deny-write-etc (Linux Only)
* docker run -d alpine --security-opt apparmor=sample-one

### Using seccomp
* docker run --security-opt seccomp=profile.json -it nginx bash
* docker run --security-opt seccomp=black-list-profile.json -it nginx bash

### Docker Bench
* git clone https://github.com/docker/docker-bench-security.git
* cd docker-bench-security
* sudo chmod +x docker-bench-security.sh
* ./docker-bench-security.sh

### Chef Inspec
* inspec exec linux_control_01.rb
* inspec exec docker_control_01.rb
* inspec exec inside-container_01.rb -t docker://eba962138009 <- Container ID
* inspec exec linux-baseline-master/-t docker://eba962138009
* inspec supermarket profiles
* inspec supermarket exec dev-sec/linux-baseline -t docker://eba962138009

## References
* https://vulnerablecontainers.org
* https://securitytxt.org
* https://github.com/hadolint/hadolint
* https://owasp.org/www-project-docker-top-10/
* https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html
* https://docs.docker.com/engine/security/apparmor/
* https://docs.docker.com/engine/security/seccomp/
* https://github.com/docker/docker-bench-security.git
* https://docs.chef.io/inspec/resources/docker
* https://dev-sec.io
