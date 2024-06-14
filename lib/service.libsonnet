local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local service = k.core.v1.service,
  forWorkload(workload, type='NodePort')::
    k.util.serviceFor(workload) + service.mixin.spec.withType(type),
}
