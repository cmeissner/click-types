ifdef PYPI_REPO
TWINE_OPTIONS = --repository $(PYPI_REPO)
endif

ifdef PYPI_API_TOKEN
TWINE_OPTIONS += --username __token__ --password $(PYPI_API_TOKEN)
endif

ifdef PYPI_DRY_RUN
TWINE_CMD = echo twine
else
TWINE_CMD = twine
endif

default: help

help:
	@echo "Please use \`make <target>' where <target> is one of:"
		@echo "  help         - to show this message"
		@echo "  lint         - to run code linting"
		@echo "  clean        - clean workspace"
		@echo "  doc-setup    - prepare environment for creating documentation"
		@echo "  doc          - create documentation"
		@echo "  test-setup   - prepare environment for tests"
		@echo "  test-all     - run all tests"
		@echo "  test-<test>  - run a specifig test"
		@echo "  coverage     - display code coverage"
		@echo "  coverage-xml - create xml coverage report"

lint:
	flake8 click_types

dist:
	python3 setup.py sdist bdist_wheel

check: dist
	$(TWINE_CMD) check dist/*

publish: check
	$(TWINE_CMD) upload $(TWINE_OPTIONS) dist/*

clean:
	rm -Rf docs/{build,_build} {build,dist} *.egg-info coverage.xml .pytest_cache
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -rf {} +
	coverage erase

doc-setup:
	pip install --upgrade -r docs/requirements.txt

doc:
	install -d -m 750 ./docs/plugins
	sphinx-apidoc -M -f -o docs/plugins/ click_types
	make -C docs html

test-setup:
	pip install --upgrade -r requirements-dev.txt
	python setup.py install

test-all:
	coverage run -m pytest tests/test_cases/* -v

test-%:
	coverage run -m pytest tests/test_cases/$*_*.py -v

coverage: test-all
	coverage report -m --include 'click_types/*','click_types/**/*','tests/**/*'

coverage-xml: test-all
	coverage xml --include 'click_types/*','click_types/**/*','tests/**/*'

FORCE:

.PHONY: help dist lint publish FORCE
