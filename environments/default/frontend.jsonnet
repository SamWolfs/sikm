{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'frontend',
      namespace: 'default',
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'frontend',
        },
      },
      policyTypes: [
        'Ingress',
        'Egress',
      ],
      ingress: [
        {},
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
        name: 'frontend',
        namespace: 'default',
      },
    },
  service:
    [
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: 'frontend',
          namespace: 'default',
          labels: {
            app: 'frontend',
          },
        },
        spec: {
          type: 'ClusterIP',
          selector: {
            app: 'frontend',
          },
          ports: [
            {
              name: 'http',
              port: 80,
              targetPort: 8080,
            },
          ],
        },
      },
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: 'frontend-external',
          namespace: 'default',
        },
        spec: {
          type: 'LoadBalancer',
          selector: {
            app: 'frontend',
          },
          ports: [
            {
              name: 'http',
              port: 80,
              targetPort: 8080,
            },
          ],
        },
      },
    ],
  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'frontend',
      namespace: 'default',
      labels: {
        app: 'frontend',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'frontend',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'frontend',
          },
          annotations: {
            'sidecar.istio.io/rewriteAppHTTPProbers': 'true',
          },
        },
        spec: {
          serviceAccountName: 'frontend',
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
              image: 'gcr.io/google-samples/microservices-demo/frontend:v0.10.0',
              ports: [
                {
                  containerPort: 8080,
                },
              ],
              readinessProbe: {
                initialDelaySeconds: 10,
                httpGet: {
                  path: '/_healthz',
                  port: 8080,
                  httpHeaders: [
                    {
                      name: 'Cookie',
                      value: 'shop_session-id=x-readiness-probe',
                    },
                  ],
                },
              },
              livenessProbe: {
                initialDelaySeconds: 10,
                httpGet: {
                  path: '/_healthz',
                  port: 8080,
                  httpHeaders: [
                    {
                      name: 'Cookie',
                      value: 'shop_session-id=x-liveness-probe',
                    },
                  ],
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
                  name: 'CURRENCY_SERVICE_ADDR',
                  value: 'currencyservice:7000',
                },
                {
                  name: 'CART_SERVICE_ADDR',
                  value: 'cartservice:7070',
                },
                {
                  name: 'RECOMMENDATION_SERVICE_ADDR',
                  value: 'recommendationservice:8080',
                },
                {
                  name: 'SHIPPING_SERVICE_ADDR',
                  value: 'shippingservice:50051',
                },
                {
                  name: 'CHECKOUT_SERVICE_ADDR',
                  value: 'checkoutservice:5050',
                },
                {
                  name: 'AD_SERVICE_ADDR',
                  value: 'adservice:9555',
                },
                {
                  name: 'SHOPPING_ASSISTANT_SERVICE_ADDR',
                  value: 'shoppingassistantservice:80',
                },
                {
                  name: 'ENV_PLATFORM',
                  value: 'local',
                },
                {
                  name: 'CYMBAL_BRANDING',
                  value: 'false',
                },
                {
                  name: 'ENABLE_ASSISTANT',
                  value: 'false',
                },
                {
                  name: 'ENABLE_SINGLE_SHARED_SESSION',
                  value: 'false',
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
