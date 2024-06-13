{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'currencyservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'currencyservice',
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
              port: 7000,
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
        name: 'currencyservice',
        namespace: 'default',
      },
    },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'currencyservice',
        namespace: 'default',
        labels: {
          app: 'currencyservice',
        },
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'currencyservice',
        },
        ports: [
          {
            name: 'grpc',
            port: 7000,
            targetPort: 7000,
          },
        ],
      },
    },
  deployment:
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'currencyservice',
        namespace: 'default',
        labels: {
          app: 'currencyservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'currencyservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'currencyservice',
            },
          },
          spec: {
            serviceAccountName: 'currencyservice',
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
                image: 'gcr.io/google-samples/microservices-demo/currencyservice:v0.10.0',
                ports: [
                  {
                    name: 'grpc',
                    containerPort: 7000,
                  },
                ],
                env: [
                  {
                    name: 'PORT',
                    value: '7000',
                  },
                  {
                    name: 'DISABLE_PROFILER',
                    value: '1',
                  },
                ],
                readinessProbe: {
                  grpc: {
                    port: 7000,
                  },
                },
                livenessProbe: {
                  grpc: {
                    port: 7000,
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
