.PHONY: resolve-deps

resolve-deps:
	@python3 mk/resolve.py "$(package)"
