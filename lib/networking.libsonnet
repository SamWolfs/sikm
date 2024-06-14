local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local networking = k.networking.v1;

{
  networkPolicy:: {
    new(name, ingresses, egresses)::
      networking.networkPolicy.new(name)
      + networking.networkPolicy.spec.withIngress(ingresses)
      + networking.networkPolicy.spec.withEgress(egresses),
    ingress(port, protocol, labels)::
      networking.networkPolicyIngressRule.withPortsMixin([
        networking.networkPolicyPort.withPort(port)
        + networking.networkPolicyPort.withProtocol(protocol),
      ])
      + networking.networkPolicyIngressRule.withFromMixin([
        networking.networkPolicyPeer.podSelector.withMatchLabels(labels),
      ]),
  },
}
