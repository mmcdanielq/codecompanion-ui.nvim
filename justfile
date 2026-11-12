# Run all tests
test *ARGS:
    busted {{ ARGS }}

# Check formatting
fmt-check:
    treefmt --fail-on-change

# Format code
fmt:
    treefmt

# Run selene
lint:
    selene ./lua/ ./tests/

# Run all checks
check: fmt-check lint test
