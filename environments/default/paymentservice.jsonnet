{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'paymentservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'paymentservice',
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
        name: 'paymentservice',
        namespace: 'default',
      },
    },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'paymentservice',
        namespace: 'default',
        labels: {
          app: 'paymentservice',
        },
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'paymentservice',
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
        name: 'paymentservice',
        namespace: 'default',
        labels: {
          app: 'paymentservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'paymentservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'paymentservice',
            },
          },
          spec: {
            serviceAccountName: 'paymentservice',
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
                image: 'gcr.io/google-samples/microservices-demo/paymentservice:v0.10.0',
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
