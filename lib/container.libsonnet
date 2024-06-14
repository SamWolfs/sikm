local k = import 'k.libsonnet';

{
  local container = k.core.v1.container,
  new(name, image):: container.new(name, image),
  env(env):: container.withEnvMap(env),
  livenessProbe:: {
    grpc(port, delay, period)::
      container.mixin.livenessProbe.grpc.withPort(port)
      + container.mixin.livenessProbe.withInitialDelaySeconds(delay)
      + container.mixin.livenessProbe.withPeriodSeconds(period),
  },
  ports(ports):: container.withPorts(ports),
  readinessProbe:: {
    grpc(port, delay, period)::
      container.mixin.readinessProbe.grpc.withPort(port)
      + container.mixin.readinessProbe.withInitialDelaySeconds(delay)
      + container.mixin.readinessProbe.withPeriodSeconds(period),
  },
  resources:: {
    new(cpu, memory):: self.cpu(cpu) + self.memory(memory),
    cpu(cpu):: container.resources.withRequestsMixin({ cpu: cpu }),
    memory(memory)::
      container.resources.withRequestsMixin({ memory: memory })
      + container.resources.withLimitsMixin({ memory: memory }),
  },
  security:: {
    default:
      container.securityContext.withAllowPrivilegeEscalation(false)
      + container.securityContext.withPrivileged(false)
      + container.securityContext.withReadOnlyRootFilesystem(true)
      + container.securityContext.capabilities.withDrop('ALL'),
  },
}
