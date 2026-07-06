.PHONY: setup check test lint

setup:
	pip install -r requirements-dev.txt

check:
	python tools/check_template.py templates/*/*/

test:
	pytest tools/tests -q
	@set -e; for d in templates/*/*/; do \
	  if [ -d "$$d/tests" ]; then \
	    echo "== $$d =="; \
	    ( cd "$$d" && python -m pytest tests -q ) || { code=$$?; [ $$code -eq 5 ] || exit $$code; }; \
	  fi; \
	done

lint:
	ruff check .
