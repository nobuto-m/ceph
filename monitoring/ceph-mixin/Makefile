all: fmt generate lint test

fmt:
	./lint-jsonnet.sh -i

generate: dashboards_out

vendor: jsonnetfile.lock.json
	tox -ejsonnet-bundler-install

dashboards_out: vendor dashboards
	tox -ejsonnet-fix
	# native pie chart support has been backported to quincy:
	# https://github.com/ceph/ceph/commit/bc8527a9049b358de9471b28176f573983f91298
	# However, there is a left over but the fix is not cleanly backportable:
	# https://github.com/ceph/ceph/commit/c2f4aa7887d8322bc58cd1cb322746246ccebe32
	# This is a quick workaround.
	sed -i -e 's/grafana-piechart-panel/piechart/' dashboards_out/*.json

lint:
	tox -ejsonnet-lint
	tox -ealerts-lint

test: generate
	tox -ejsonnet-check
	tox -epromql-query-test
	tox -ealerts-check
check: test

.PHONY: all fmt generate lint test check
