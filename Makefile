PHONY: generate generate/delete generate/watch

lint:
	@echo "Linting..."
	dart analyze

lint/fix:
	@echo "Linting and fixing..."
	dart fix --dry-run
	dart fix --apply

format:
	@echo "Formatting..."
	dart format .



generate:
	@echo "Generating..."
	dart run build_runner build

generate/delete:
	@echo "Deleting generated files..."
	dart run build_runner build --delete-conflicting-outputs

generate/watch:
	@echo "Watching for changes..."
	dart run build_runner watch