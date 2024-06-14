local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local deployment = k.apps.v1.deployment,
  new:: deployment.new,
  securityContext:: {
    local securityContext = deployment.spec.template.spec.securityContext,
    default:
      securityContext.withFsGroup(1000)
      + securityContext.withRunAsGroup(1000)
      + securityContext.withRunAsNonRoot(true)
      + securityContext.withRunAsUser(1000),
  },
}
