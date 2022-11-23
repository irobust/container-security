# Container Security
## D01 Secure User Mapping
### Build Node with non-root user
* docker build -t nodejs -f node.Dockerfile .
* docker run -d nodejs
* docker exec [Contianer ID] ps -o pid,user

### Compare with user in host machine
* docker inspect --format='{{ .State.Pid }}' [Container ID]
* ps -p [Process ID from previous command] -o pid,user

### Hadolint
* hadolint /path/to/Dockerfile
* hadolint /path/to/Dockerfile --ignore DL3006
* hadolint /path/to/Dockerfile -t error
* hadolint /path/to/Dockerfile --error DL3006
* hadolint /path/to/Dockerfile --no-fail
* echo $? (On Mac)
* $LastExitCode (On Windows PowerShell)

## D02 Patch Management Strategy
### Clair
* https://github.com/quay/clair.git
* cd clair
* docker-compose up -d
* goto dashboard at http://localhost:8080
* docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock jgsqware/clairctl clairctl analyze -l infoslack/dvwa

#### ClairCtl command
* clairctl analyze -l infoslack/dvwa
* clairctl report -l infoslack/dvwa
* clairctl report -l -f json infoslack/dvwa

### Anchore Engine
* docker-compose up -d
* docker-compose ps
* docker-compose exec api
* docker-compose exec api anchore-cli system status
* docker-compose exec api anchore-cli system feeds list
* docker-compose exec api anchore-cli --u admin --p foobar image add alpine:3.9
* docker-compose exec api anchore-cli --u admin --p foobar image get alpine:3.9
* docker-compose exec api anchore-cli --u admin --p foobar image content alpine:3.9 os
* docker-compose exec api anchore-cli --u admin --p foobar image vuln alpine:3.9 all (Waiting until analyzed)
* docker-compose exec api anchore-cli --u admin --p foobar evaluate check alpine:3.9 

### Anchore Syft
* syft [image-name]
* syft package [image-name]
* syft -o json [image-name]
* syft dir:.

### Anchore Grype
* grype dir:.
* grype [image-name]
* grype [image-name] --scope all-layers
* grype sbom:./sbom.json
* grype dir:. --exclude './out/**/*.json'
* grype [image-name] -o json
* grype [image-name] --fail-on medium

### Trivy
* trivy image python:3.4-alpine
* trivy image --reset python:3.4-alpine
* trivy image --exit-code 2 python:3.4-alpine
* trivy image --list-all-pkgs python:3.4-alpine
* trivy image --serverity CRITICAL,HIGH,MEDIUM python:3.4-alpine
* trivy image  --ignore-unfixed python:3.4-alpine
* trivy repo https://github.com/AnaisUrlichs/react-article-display
* git clone https://github.com/AnaisUrlichs/react-article-display
* trivy config ./manifest
* git clone https://github.com/nccgroup/sadcloud
* trivy config sadcloud
* trivy fs --security-checks vuln,secret,config [path to source code]
* trivy k8s --report summary cluster

## D03 Network Segment and Firewall
### Kube Hunter
* kube-hunter
* kube-hunter --list
* kube-hunter --list --active
* kube-hunter --remote [HOST]
* kube-hunter --remote [HOST] --statistics
* kube-hunter --cidr 192.168.0.0/24
* kube-hunter --log LOGLEVEL
* kube-hunter --report json
* kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-hunter/main/job.yaml
* kubectl logs po/kube-hunter-xxxx

## D04 Secure Defaults and Hardening
### Docker Bench
* git clone https://github.com/docker/docker-bench-security.git
* cd docker-bench-security
* sudo chmod +x docker-bench-security.sh
* ./docker-bench-security.sh

### Using Apparmor
* apparmor_parser -r -W deny-write-etc (Linux Only)
* docker run -d alpine --security-opt apparmor=sample-one

### Using seccomp
* docker run --security-opt seccomp=profile.json -it nginx bash
* docker run --security-opt seccomp=black-list-profile.json -it nginx bash

### Chef Inspec
* inspec exec linux_control_01.rb
* inspec exec docker_control_01.rb
* inspec exec inside-container_01.rb -t docker://eba962138009 <- Container ID
* git clone https://github.com/dev-sec/linux-baseline
* inspec exec linux-baseline-master/-t docker://eba962138009
* inspec exec https://github.com/dev-sec/cis-docker-benchmark
* inspec exec https://github.com/dev-sec/cis-kubernetes-benchmark
* inspec supermarket profiles
* inspec supermarket exec dev-sec/linux-baseline -t docker://eba962138009
* inspec init profile --platform os my-profile 
* inspec check my-profile

## D05 Maintain Security Context
No content for this topic

## D06 Protect Secret
### Environment Variable is not secure
#### First Tab
* docker run -it --rm -e SECRET=mypassword alpine /bin/bash
* env | grep SECRET
* sleep 5000

#### Second Tab
* docker inspect [container-name] -f "{{.Config.Env }}"
* docker exec -it [container-name] pidof sleep
* docker exec-it [container-name] /bin/bash
* cat /proc/[process-id-from-pidof-command]/environ

### Kubernetes Secret
* kubectl create secret generic apikey --from-literal=api_key=123456789
* kubectl get secret apikey -o yaml
* kubectl apply -f secretreader-deployment.yaml
* kubectl exec -it po/secretreader-84f8f674f6-wmmx7 -- bash

```
    valueFrom:
        secretKeyRef:
            name: apikey
            key: api_key
```

### HashiCrop Vault
#### Start Vault server in dev mode
* vault server -dev
* $env:VAULT_ADDR="http://127.0.0.1:8200"
* vault login

### Working with secret engine
* vault secrets list
* vault secrets enable -path=mysecret kv
* vault secrets enable -path=secretv2 kv-v2
* vault secrets tune -description="describe your path here" mysecret
* vault secrets move mysecret mysecret-v1
* vault secrets disable mysecret-v1

### Writing secret value
* vault kv put secretv2/apikeys/demo token=0123456789
* vault kv list secretv2/apikeys
* vault kv get secretv2/apikeys/demo
* vault kv get -version=1 secretv2/apikeys/demo
* vault kv delete -version=1 secretv2/apikeys/demo
* vault kv destroy -version=1 secretv2/apikeys/demo
* vault secret enable mysecret kv
* vault kv enable-versioning mysecret

## D07 Resource Protection 
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

## D08 Container Image Integrity and Trust
### Docker Content Trust
* export DOCKER_CONTENT_TRUST=1 (On Windows setting Enviroment Variables)
* docker pull williamyeh/json-server (Can't pull this image)
* docker pull --disable-content-trust=true williamyeh/json-server (Pull unsign image sucessfully)
* notary -s https://notary.docker.io list docker.io/library/alpine

### Porteris
* git clone https://github.com/IBM/portieris
* sh portieris/gencerts
* Config tlsCert, tlsKey and caCert in Values.yaml
* helm install portieris --create-namespace --namespace portieris ./portieris
* kubectl apply -f portieris/cluster-image-policy.yml
* kubectl apply -f portieris/helloworld-deployment.yml

## D09 Follow Immutable Paradigm
### Read Only container
* docker container run --rm --read-only alpine touch hello.txt
* docker container run --rm --read-only --tmpfs /var alpine touch hello.txt
* docker diff [Container ID]

## D10 Logging and Monitoring
### Monitor container with CLI
* docker stats [container name]
* docker stats --format "{{.Container}} : {{.CPUPerc}}" [container name]
* docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" [container name]
* docker stats --no-stream [container name]
* curl --unix-socket /var/run/docker.sock http://localhost/containers/[container name]/stats
* docker system events

## References
### Introduction to container security
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

#### Image scanner
* https://github.com/quay/clair
* https://anchore.com/opensource/
* https://github.com/aquasecurity/trivy
* https://github.com/aquasecurity/kube-hunter

#### Managing resources
* https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node
* https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/

#### Docker registry
* https://docs.docker.com/registry/spec/api/
* https://hub.docker.com/_/registry

#### Secret Management
* https://docs.docker.com/engine/swarm/secrets
* https://kubernetes.io/docs/concepts/configuration/secret/
* https://www.vaultproject.io

#### TUF and Notary
* https://www.youtube.com/watch?v=JK70k_B87mw&t=1420s

#### Logging and monitoring
* https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
* https://www.datadoghq.com
