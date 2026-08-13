.PHONY: install lint lint-strict format smoke

install:
	brew bundle

lint:
	./scripts/lint.sh

lint-strict:
	./scripts/lint-strict.sh

format:
	./scripts/format.sh

smoke:
	./scripts/smoke.sh
