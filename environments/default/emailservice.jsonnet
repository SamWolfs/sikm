{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'emailservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'emailservice',
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
        name: 'emailservice',
        namespace: 'default',
      },
    },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'emailservice',
        namespace: 'default',
        labels: {
          app: 'emailservice',
        },
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'emailservice',
        },
        ports: [
          {
            name: 'grpc',
            port: 5000,
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
        name: 'emailservice',
        namespace: 'default',
        labels: {
          app: 'emailservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'emailservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'emailservice',
            },
          },
          spec: {
            serviceAccountName: 'emailservice',
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
                image: 'gcr.io/google-samples/microservices-demo/emailservice:v0.10.0',
                ports: [
                  {
                    containerPort: 8080,
                  },
                ],
                env: [
                  {
                    name: 'PORT',
                    value: '8080',
                  },
                  {
                    name: 'DISABLE_PROFILER',
                    value: '1',
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
