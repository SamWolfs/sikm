{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'cartservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'cartservice',
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
          ],
          ports: [
            {
              port: 7070,
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
        name: 'cartservice',
        namespace: 'default',
      },
    },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'cartservice',
        namespace: 'default',
        labels: {
          app: 'cartservice',
        },
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'cartservice',
        },
        ports: [
          {
            name: 'grpc',
            port: 7070,
            targetPort: 7070,
          },
        ],
      },
    },
  deployment:
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'cartservice',
        namespace: 'default',
        labels: {
          app: 'cartservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'cartservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'cartservice',
            },
          },
          spec: {
            serviceAccountName: 'cartservice',
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
                image: 'gcr.io/google-samples/microservices-demo/cartservice:v0.10.0',
                ports: [
                  {
                    containerPort: 7070,
                  },
                ],
                env: [
                  {
                    name: 'REDIS_ADDR',
                    value: 'redis-cart:6379',
                  },
                ],
                resources: {
                  limits: {
                    cpu: '300m',
                    memory: '128Mi',
                  },
                  requests: {
                    cpu: '200m',
                    memory: '64Mi',
                  },
                },
                readinessProbe: {
                  initialDelaySeconds: 15,
                  grpc: {
                    port: 7070,
                  },
                },
                livenessProbe: {
                  initialDelaySeconds: 15,
                  periodSeconds: 10,
                  grpc: {
                    port: 7070,
                  },
                },
              },
            ],
          },
        },
      },
    },

}
