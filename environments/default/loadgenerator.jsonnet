{
  networkPolicy: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: 'loadgenerator',
      namespace: 'default',
      labels: {
        app: 'loadgenerator',
      },
    },
    spec: {
      podSelector: {
        matchLabels: {
          app: 'loadgenerator',
        },
      },
      policyTypes: [
        'Egress',
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
        name: 'loadgenerator',
        namespace: 'default',
      },
    },
  deployment:
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'loadgenerator',
        namespace: 'default',
        labels: {
          app: 'loadgenerator',
        },
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'loadgenerator',
          },
        },
        replicas: 1,
        template: {
          metadata: {
            labels: {
              app: 'loadgenerator',
            },
            annotations: {
              'sidecar.istio.io/rewriteAppHTTPProbers': 'true',
            },
          },
          spec: {
            serviceAccountName: 'loadgenerator',
            terminationGracePeriodSeconds: 5,
            restartPolicy: 'Always',
            securityContext: {
              fsGroup: 1000,
              runAsGroup: 1000,
              runAsNonRoot: true,
              runAsUser: 1000,
            },
            initContainers: [
              {
                command: [
                  '/bin/sh',
                  '-exc',
                  "MAX_RETRIES=12\nRETRY_INTERVAL=10\nfor i in $(seq 1 $MAX_RETRIES); do\n  echo \"Attempt $i: Pinging frontend: ${FRONTEND_ADDR}...\"\n  STATUSCODE=$(wget --server-response http://${FRONTEND_ADDR} 2>&1 | awk '/^  HTTP/{print $2}')\n  if [ $STATUSCODE -eq 200 ]; then\n      echo \"Frontend is reachable.\"\n      exit 0\n  fi\n  echo \"Error: Could not reach frontend - Status code: ${STATUSCODE}\"\n  sleep $RETRY_INTERVAL\ndone\necho \"Failed to reach frontend after $MAX_RETRIES attempts.\"\nexit 1\n",
                ],
                name: 'frontend-check',
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
                image: 'busybox:latest@sha256:5eef5ed34e1e1ff0a4ae850395cbf665c4de6b4b83a32a0bc7bcb998e24e7bbb',
                env: [
                  {
                    name: 'FRONTEND_ADDR',
                    value: 'frontend:80',
                  },
                ],
              },
            ],
            containers: [
              {
                name: 'main',
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
                image: 'gcr.io/google-samples/microservices-demo/loadgenerator:v0.10.0',
                env: [
                  {
                    name: 'FRONTEND_ADDR',
                    value: 'frontend:80',
                  },
                  {
                    name: 'USERS',
                    value: '10',
                  },
                ],
                resources: {
                  limits: {
                    cpu: '500m',
                    memory: '512Mi',
                  },
                  requests: {
                    cpu: '300m',
                    memory: '256Mi',
                  },
                },
              },
            ],
          },
        },
      },
    },
}
