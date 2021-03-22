# Apps

## Networking

Apps are deployed using services of type `LoadBalanced` to the IP address `192.168.86.201` (the ingress already uses `192.168.86.200` and is a nice to have). For the sake of simplicity, all apps will use sequential ports starting from 9000. Here are the currently requisitioned ports.

Access each service by using `https://192.168.86.201:<HTTPS Port>` e.g. `https://192.168.86.201:9000` to access the dashboard.

- Kubernetes Dashboard
    - Port: 9000, TCP/HTTPS
- Next Cloud
    - Port: 9001, TCP/HTTP
    - Port: 9002, TCP/HTTPS


### Ingress

It would be preferable to use the ingress mechanism rather than services, but this requires either the managing the host names of the ingress resources or managing DNS and certifications. To avoid that, I've decided to use the scheme above.