local container = import 'container.libsonnet';
local defaults = import 'defaults.libsonnet';
local deployment = import 'deployment.libsonnet';
local networking = import 'networking.libsonnet';
local port = import 'port.libsonnet';
local service = import 'service.libsonnet';
local serviceAccount = import 'service_account.libsonnet';

{
  _config:: {
    name: 'adservice',
    port: 9555,
  },
  networkPolicy:
    networking.networkPolicy.new($._config.name, [
      networking.networkPolicy.ingress($._config.port, 'TCP', { app: 'frontend' }),
    ], []),
  service: service.forWorkload(self.deployment, 'ClusterIP'),
  serviceAccount: serviceAccount.new($._config.name),
  deployment: deployment.new(
    name=$._config.name,
    replicas=1,
    containers=[
      container.new($._config.name, 'gcr.io/google-samples/microservices-demo/adservice:v0.10.0')
      + container.ports([port.newNamed($._config.port, 'grpc')])
      + container.readinessProbe.grpc($._config.port, 20, 15)
      + container.livenessProbe.grpc($._config.port, 20, 15)
      + container.env({ PORT: std.toString($._config.port) })
      + container.resources.new(cpu='200m', memory='300Mi')
      + container.security.default,
    ],
    podLabels={ app: $._config.name },
  ) + deployment.securityContext.default,
}
