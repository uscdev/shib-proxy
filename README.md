# shib-proxy
USC Shibboleth SP Reverse Proxy

For instructions: [virtualstaticvoid/shibboleth-nginx](https://hub.docker.com/r/virtualstaticvoid/shibboleth-nginx/). Thanks vsv!

This container has been extended to forward to the USC Shibboleth SP.
It expects our standard container environment:

- Docker Swarm
- The Shib key and cert in the secrets store:
  ````bash
  docker secret create sp-cert.pem sp-cert.pem
  docker secret create sp-key.pem sp-key.pem
  ````
- An overlay network at web-bus
  ````bash
  docker network create --driver overlay proxy
  ````
- Your proxied web application running on a private overlay network.
(For an example see [uscdev/shib-test-site](https://hub.docker.com/r/uscdev/shib-test-site/))
- Start your container using the standard stack command:
  ````bash
  docker stack deploy --container-file docker-compose.yml shib-proxy
  ````
  