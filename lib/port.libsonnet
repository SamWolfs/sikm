local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local port = k.core.v1.containerPort,
  newNamed:: port.newNamed,
}
