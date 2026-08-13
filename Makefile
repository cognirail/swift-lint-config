.PHONY: install lint format smoke

install:
	brew bundle

lint:
	./scripts/lint.sh

format:
	./scripts/format.sh

smoke:
	./scripts/smoke.sh
