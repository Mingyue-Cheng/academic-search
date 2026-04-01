.PHONY: test test-release

CDP_PROXY_PORT ?= 4568

test:
	CDP_PROXY_PORT=$(CDP_PROXY_PORT) bash scripts/self-test.sh

test-release: test
	CDP_PROXY_PORT=$(CDP_PROXY_PORT) bash scripts/release-test.sh
