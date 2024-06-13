{
  networkPolicy:
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'redis-cart',
        namespace: 'default',
      },
      spec: {
        podSelector: {
          matchLabels: {
            app: 'redis-cart',
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
                    app: 'cartservice',
                  },
                },
              },
            ],
            ports: [
              {
                port: 6379,
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
      name: 'redis-cart',
      namespace: 'default',
    },
  },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'redis-cart',
        namespace: 'default',
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'redis-cart',
        },
        ports: [
          {
            name: 'tcp-redis',
            port: 6379,
            targetPort: 6379,
          },
        ],
      },
    },
  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'redis-cart',
      namespace: 'default',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'redis-cart',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'redis-cart',
          },
        },
        spec: {
          serviceAccountName: 'redis-cart',
          securityContext: {
            fsGroup: 1000,
            runAsGroup: 1000,
            runAsNonRoot: true,
            runAsUser: 1000,
          },
          containers: [
            {
              name: 'redis',
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
              image: 'redis:alpine@sha256:0389bb8416d7c6ed065c25745179bf5d358e5d9472dd30a687ab36ffbb650262',
              ports: [
                {
                  containerPort: 6379,
                },
              ],
              readinessProbe: {
                periodSeconds: 5,
                tcpSocket: {
                  port: 6379,
                },
              },
              livenessProbe: {
                periodSeconds: 5,
                tcpSocket: {
                  port: 6379,
                },
              },
              volumeMounts: [
                {
                  mountPath: '/data',
                  name: 'redis-data',
                },
              ],
              resources: {
                limits: {
                  memory: '256Mi',
                  cpu: '125m',
                },
                requests: {
                  cpu: '70m',
                  memory: '200Mi',
                },
              },
            },
          ],
          volumes: [
            {
              name: 'redis-data',
              emptyDir: {},
            },
          ],
        },
      },
    },
  },
}
