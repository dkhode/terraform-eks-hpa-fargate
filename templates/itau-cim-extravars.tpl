replicaCount: 1

envVars:
  - name: DATASOURCES_DEFAULT_URL
    value: "jdbc:postgresql://${aurora-endpoint}:5432/micronaut_poc_db"
  - name: DATASOURCES_DEFAULT_USERNAME
    value: "itau_cim"
  - name: DATASOURCES_DEFAULT_PASSWORD
# To Do - usar secret engine
    value: "iQGlsbfLk08ZwMAM"

  - name: DATASOURCES_READ_URL
    value: "jdbc:postgresql://aurora-cluster-micronaut-poc.cluster-ro-clot4myvrfmk.us-east-1.rds.amazonaws.com:5432/micronaut_poc_db"
  - name: DATASOURCES_READ_USERNAME
    value: "itau_cim"
  - name: DATASOURCES_READ_PASSWORD
# To Do - usar secret engine
    value: "iQGlsbfLk08ZwMAM"

image:
  repository: itau-cim
  tag: latest
  pullPolicy: Always

service:
  name: itau-cim
  type: NodePort
  ports:
  - name: http
    port: 8080

configmaps:
  enabled: false
  files: {}

startcommand: 
  enabled: false
  value: ["/bin/sh","-c","sleep infinity"]

ingress:
  enabled: true
  path: /*
  hosts:
    - name: ${demo-itau-address}
      port: http    
  annotations: 
     kubernetes.io/ingress.class: alb
     alb.ingress.kubernetes.io/scheme: internet-facing
     alb.ingress.kubernetes.io/subnets: ${subnets}
     alb.ingress.kubernetes.io/certificate-arn: ${certificate-arn-demo-itau}
     alb.ingress.kubernetes.io/healthcheck-path: /health
     external-dns.alpha.kubernetes.io/hostname: ${demo-itau-address}


resources:
   limits:
    cpu: 1
    memory: 1536Mi
   requests:
    cpu: 128m
    memory: 256Mi

nodeSelector: {}

tolerations: []

affinity: {}

hpa:
  enabled: true

annotations:
  - name: hpa.autoscaling.banzaicloud.io/maxReplicas
    value: 8
  - name: hpa.autoscaling.banzaicloud.io/minReplicas
    value: 1
  - name: prometheus.customMetricName.hpa.autoscaling.banzaicloud.io/query
    value: sum by (job) (rate(http_server_requests_seconds_count{release="itau-cim",uri="/customer"}[1m]))
  - name: prometheus.customMetricName.hpa.autoscaling.banzaicloud.io/targetValue
    value: "100"

svcAnnotations:
  - name: prometheus.io/scrape
    value: true
  - name: prometheus.io/path
    value: /prometheus
  - name: prometheus.io/port
    value: 8080
    

livenessProbe:
  enabled: true
  failureThreshold: 3
  httpGet:
    path: /health
    port: 8080
    scheme: HTTP
  initialDelaySeconds: 5
  periodSeconds: 30
  successThreshold: 1
  timeoutSeconds: 1
readinessProbe:
  failureThreshold: 3
  httpGet:
    path: /health
    port: 8080
    scheme: HTTP
  initialDelaySeconds: 3
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
istio:
  enabled: true

imageCredentials:
  registry: 237930432518.dkr.ecr.sa-east-1.amazonaws.com
