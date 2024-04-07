.PHONY: noop
noop:

.PHONY: minimize
minimize:
	# Minimize the fetch size of the repository not to hit the timeout
	# by deleting all directories except for "monitoring", but don't
	# delete the top level files such as COPYING
	# https://github.com/canonical/cos-configuration-k8s-operator/issues/75
	find . -mindepth 1 -maxdepth 1 -type d ! -regex './\(\.git\|\.github\|monitoring\)' -exec rm -r {} \;

.PHONY: fork-for-cos
fork-for-cos: minimize
	# Temporarily disable "rgw-s3-analytics" dashboard
	# https://github.com/canonical/cos-configuration-k8s-operator/issues/87
	sed -i -e "s|^    \((import 'dashboards/rgw-s3-analytics\.libsonnet.*\)|    \# \1|" \
	    monitoring/ceph-mixin/dashboards.libsonnet
	rm -f monitoring/ceph-mixin/dashboards_out/rgw-s3-analytics.json

	# Use COS specific variables
	# https://github.com/canonical/grafana-k8s-operator/issues/274
	sed -i -Ez \
	    -e 's/\s+\.?addTemplate\([ \n]*g\.template\.datasource\([^\)]+\)\n*\s*\)\.?//g' \
	    monitoring/ceph-mixin/dashboards/*.libsonnet
	sed -i \
	    -e 's/\($${\?\)DS_PROMETHEUS\(}\?\)/\1prometheusds\2/' \
	    -e 's/\($${\?\)datasource\(}\?\)/\1prometheusds\2/' \
	    monitoring/ceph-mixin/dashboards/*.libsonnet

	# job
	# https://bugs.launchpad.net/charm-ceph-mon/+bug/2044062

	# Replace the upstream doc link with the charmhub one
	sed -i -e 's|https://docs\.ceph\.com/en/latest/mgr/prometheus/#rbd-io-statistics|https://charmhub.io/ceph-mon/configure#rbd-stats-pools|' \
	    monitoring/ceph-mixin/dashboards/rbd.libsonnet

	# Regenerate
	(cd monitoring/ceph-mixin; tox -e jsonnet-fix)
