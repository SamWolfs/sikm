local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local sa = k.core.v1.serviceAccount,
  new(name):: sa.new(name),
}
