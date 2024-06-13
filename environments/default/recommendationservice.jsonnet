{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'recommendationservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'recommendationservice',
        },
      },
      policyTypes: [
        'Ingress',
        'Egress',
      ],
      ingress: [
        {
          from: [
            {
              podSelector: {
                matchLabels: {
                  app: 'frontend',
                },
              },
            },
          ],
          ports: [
            {
              port: 8080,
              protocol: 'TCP',
            },
          ],
        },
      ],
      egress: [
        {},
      ],
    },
  },
  serviceAccount:
    {
      apiVersion: 'v1',
      kind: 'ServiceAccount',
      metadata: {
        name: 'recommendationservice',
        namespace: 'default',
      },
    },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'recommendationservice',
        namespace: 'default',
        labels: {
          app: 'recommendationservice',
        },
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'recommendationservice',
        },
        ports: [
          {
            name: 'grpc',
            port: 8080,
            targetPort: 8080,
          },
        ],
      },
    },
  deployment:
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'recommendationservice',
        namespace: 'default',
        labels: {
          app: 'recommendationservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'recommendationservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'recommendationservice',
            },
          },
          spec: {
            serviceAccountName: 'recommendationservice',
            terminationGracePeriodSeconds: 5,
            securityContext: {
              fsGroup: 1000,
              runAsGroup: 1000,
              runAsNonRoot: true,
              runAsUser: 1000,
            },
            containers: [
              {
                name: 'server',
                securityContext: {
                  allowPrivilegeEscalation: false,
                  capabilities: {
                    drop: [
                      'ALL',
                    ],
                  },
                  privileged: false,
                  readOnlyRootFilesystem: true,
                },
                image: 'gcr.io/google-samples/microservices-demo/recommendationservice:v0.10.0',
                ports: [
                  {
                    containerPort: 8080,
                  },
                ],
                readinessProbe: {
                  periodSeconds: 5,
                  grpc: {
                    port: 8080,
                  },
                },
                livenessProbe: {
                  periodSeconds: 5,
                  grpc: {
                    port: 8080,
                  },
                },
                env: [
                  {
                    name: 'PORT',
                    value: '8080',
                  },
                  {
                    name: 'PRODUCT_CATALOG_SERVICE_ADDR',
                    value: 'productcatalogservice:3550',
                  },
                  {
                    name: 'DISABLE_PROFILER',
                    value: '1',
                  },
                ],
                resources: {
                  limits: {
                    cpu: '200m',
                    memory: '450Mi',
                  },
                  requests: {
                    cpu: '100m',
                    memory: '220Mi',
                  },
                },
              },
            ],
          },
        },
      },
    },
}
