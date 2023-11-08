all: fmt generate lint test

fmt:
	./lint-jsonnet.sh -i

generate: dashboards_out
	tox -ealerts-fix

vendor: jsonnetfile.lock.json
	tox -ejsonnet-bundler-install

dashboards_out: vendor dashboards
	tox -ejsonnet-fix
	# COS has a newer enough version of Grafana with the embedded
	# piechart support instead of installing an external piechart
	# plugin. This is a quick workaround until
	# https://tracker.ceph.com/issues/56651 is fixed in the ustream
	sed -i -e 's/grafana-piechart-panel/piechart/' dashboards_out/*.json

lint:
	tox -ejsonnet-lint
	tox -ealerts-lint

test: generate
	tox -ejsonnet-check
	tox -epromql-query-test
	tox -ealerts-test
check: test

.PHONY: all fmt generate lint test check
