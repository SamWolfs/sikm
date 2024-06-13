{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'adservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'adservice',
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
              port: 9555,
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
  serviceAccount: {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: 'adservice',
      namespace: 'default',
    },
  },
  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'adservice',
      namespace: 'default',
      labels: {
        app: 'adservice',
      },
    },
    spec: {
      type: 'ClusterIP',
      selector: {
        app: 'adservice',
      },
      ports: [
        {
          name: 'grpc',
          port: 9555,
          targetPort: 9555,
        },
      ],
    },
  },
  deployment:
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'adservice',
        namespace: 'default',
        labels: {
          app: 'adservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'adservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'adservice',
            },
          },
          spec: {
            serviceAccountName: 'adservice',
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
                image: 'gcr.io/google-samples/microservices-demo/adservice:v0.10.0',
                ports: [
                  {
                    containerPort: 9555,
                  },
                ],
                env: [
                  {
                    name: 'PORT',
                    value: '9555',
                  },
                ],
                resources: {
                  limits: {
                    cpu: '300m',
                    memory: '300Mi',
                  },
                  requests: {
                    cpu: '200m',
                    memory: '180Mi',
                  },
                },
                readinessProbe: {
                  initialDelaySeconds: 20,
                  periodSeconds: 15,
                  grpc: {
                    port: 9555,
                  },
                },
                livenessProbe: {
                  initialDelaySeconds: 20,
                  periodSeconds: 15,
                  grpc: {
                    port: 9555,
                  },
                },
              },
            ],
          },
        },
      },
    },
}
