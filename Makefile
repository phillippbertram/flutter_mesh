PHONY: generate generate/delete generate/watch

generate:
	@echo "Generating..."
	dart run build_runner build

generate/delete:
	@echo "Deleting generated files..."
	dart run build_runner build --delete-conflicting-outputs

generate/watch:
	@echo "Watching for changes..."
	dart run build_runner watch