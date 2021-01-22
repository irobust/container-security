# Container Security
## Day 1
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
* git clone https://github.com/dev-sec/linux-baseline
* inspec exec linux-baseline-master/-t docker://eba962138009
* inspec supermarket profiles
* inspec supermarket exec dev-sec/linux-baseline -t docker://eba962138009

## Day 2

### Anchore
* docker-compose up -d
* docker-compose ps
* docker-compose exec api
* docker exec contianer-security_api_1 anchore-cli system status
* docker exec contianer-security_api_1 anchore-cli system feeds list
* docker-compose exec api anchore-cli --u admin --p foobar image add alpine:3.9
* docker-compose exec api anchore-cli --u admin --p foobar image get alpine:3.9
* docker-compose exec api anchore-cli --u admin --p foobar image content alpine:3.9 os
* docker-compose exec api anchore-cli --u admin --p foobar image vuln alpine:3.9 all (Waiting until analyzed)
* docker-compose exec api anchore-cli --u admin --p foobar evaluate check alpine:3.9 

### Assign pod to node
* kubectl apply -f nginx.node-selector.yaml
* kubectl get po --watch
* kubectl describe po/nginx
* kubectl get nodes --show-labels
* kubectl label no/docker-desktop disktype=ssd
* kubectl get po
* kubectl apply -f nginx.pod-affinity.yaml
* kubectl delete -f nginx.node-selector.yaml

```
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 100
    podAffinityTerm:
        labelSelector:
        matchExpressions:
        - key: app
            operator: In
            values:
            - web
    topologyKey: "kubernetes.io/hostname"
```

### Kubernetes Secret
* kubectl create secret generic apikey --from-literal=api_key=123456789
* kubectl get secret apikey -o yaml
* kubectl apply -f secretreader-deployment.yaml

```
    valueFrom:
        secretKeyRef:
            name: apikey
            key: api_key
```

### Monitor container with CLI
* docker stats [container name]
* docker stats --format "{{.Container}} : {{.CPUPerc}}" [container name]
* docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" [container name]
* docker stats --no-stream [container name]
* curl --unix-socket /var/run/docker.sock http://localhost/containers/[container name]/stats
* docker system events

### Read Only container
* docker container run --rm --read-only alpine touch hello.txt
* docker container run --rm --read-only --tmpfs /var alpine touch hello.txt

## References
### DAY 1
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

### DAY 2
* https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node

