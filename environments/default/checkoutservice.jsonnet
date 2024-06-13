{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'checkoutservice',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'checkoutservice',
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
              port: 5050,
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
        name: 'checkoutservice',
        namespace: 'default',
      },
    },
  service:
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'checkoutservice',
        namespace: 'default',
        labels: {
          app: 'checkoutservice',
        },
      },
      spec: {
        type: 'ClusterIP',
        selector: {
          app: 'checkoutservice',
        },
        ports: [
          {
            name: 'grpc',
            port: 5050,
            targetPort: 5050,
          },
        ],
      },
    },
  deployment:
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'checkoutservice',
        namespace: 'default',
        labels: {
          app: 'checkoutservice',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'checkoutservice',
          },
        },
        template: {
          metadata: {
            labels: {
              app: 'checkoutservice',
            },
          },
          spec: {
            serviceAccountName: 'checkoutservice',
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
                image: 'gcr.io/google-samples/microservices-demo/checkoutservice:v0.10.0',
                ports: [
                  {
                    containerPort: 5050,
                  },
                ],
                readinessProbe: {
                  grpc: {
                    port: 5050,
                  },
                },
                livenessProbe: {
                  grpc: {
                    port: 5050,
                  },
                },
                env: [
                  {
                    name: 'PORT',
                    value: '5050',
                  },
                  {
                    name: 'PRODUCT_CATALOG_SERVICE_ADDR',
                    value: 'productcatalogservice:3550',
                  },
                  {
                    name: 'SHIPPING_SERVICE_ADDR',
                    value: 'shippingservice:50051',
                  },
                  {
                    name: 'PAYMENT_SERVICE_ADDR',
                    value: 'paymentservice:50051',
                  },
                  {
                    name: 'EMAIL_SERVICE_ADDR',
                    value: 'emailservice:5000',
                  },
                  {
                    name: 'CURRENCY_SERVICE_ADDR',
                    value: 'currencyservice:7000',
                  },
                  {
                    name: 'CART_SERVICE_ADDR',
                    value: 'cartservice:7070',
                  },
                ],
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
