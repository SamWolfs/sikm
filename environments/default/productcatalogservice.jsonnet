{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'productcatalogservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'productcatalogservice',
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
            {
              podSelector: {
                matchLabels: {
                  app: 'checkoutservice',
                },
              },
            },
            {
              podSelector: {
                matchLabels: {
                  app: 'recommendationservice',
                },
              },
            },
          ],
          ports: [
            {
              port: 3550,
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
        name: 'productcatalogservice',
        namespace: 'default',
      },
    },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'productcatalogservice',
        namespace: 'default',
        labels: {
          app: 'productcatalogservice',
        },
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'productcatalogservice',
        },
        ports: [
          {
            name: 'grpc',
            port: 3550,
            targetPort: 3550,
          },
        ],
      },
    },
  deployment:
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'productcatalogservice',
        namespace: 'default',
        labels: {
          app: 'productcatalogservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'productcatalogservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'productcatalogservice',
            },
          },
          spec: {
            serviceAccountName: 'productcatalogservice',
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
                image: 'gcr.io/google-samples/microservices-demo/productcatalogservice:v0.10.0',
                ports: [
                  {
                    containerPort: 3550,
                  },
                ],
                env: [
                  {
                    name: 'PORT',
                    value: '3550',
                  },
                  {
                    name: 'DISABLE_PROFILER',
                    value: '1',
                  },
                  {
                    name: 'EXTRA_LATENCY',
                    value: null,
                  },
                ],
                readinessProbe: {
                  grpc: {
                    port: 3550,
                  },
                },
                livenessProbe: {
                  grpc: {
                    port: 3550,
                  },
                },
                resources: {
                  limits: {
                    cpu: '200m',
                    memory: '128Mi',
                  },
                  requests: {
                    cpu: '100m',
                    memory: '64Mi',
                  },
                },
              },
            ],
          },
        },
      },
    },
}
