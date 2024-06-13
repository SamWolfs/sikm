{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'shippingservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'shippingservice',
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
              port: 50051,
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
        name: 'shippingservice',
        namespace: 'default',
      },
    },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'shippingservice',
        namespace: 'default',
        labels: {
          app: 'shippingservice',
        },
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'shippingservice',
        },
        ports: [
          {
            name: 'grpc',
            port: 50051,
            targetPort: 50051,
          },
        ],
      },
    },
  deployment:
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'shippingservice',
        namespace: 'default',
        labels: {
          app: 'shippingservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'shippingservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'shippingservice',
            },
          },
          spec: {
            serviceAccountName: 'shippingservice',
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
                image: 'gcr.io/google-samples/microservices-demo/shippingservice:v0.10.0',
                ports: [
                  {
                    containerPort: 50051,
                  },
                ],
                env: [
                  {
                    name: 'PORT',
                    value: '50051',
                  },
                  {
                    name: 'DISABLE_PROFILER',
                    value: '1',
                  },
                ],
                readinessProbe: {
                  periodSeconds: 5,
                  grpc: {
                    port: 50051,
                  },
                },
                livenessProbe: {
                  grpc: {
                    port: 50051,
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
