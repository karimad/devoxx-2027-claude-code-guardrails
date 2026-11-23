---
name: verify
description: Run tests to verify changes work before marking work complete
---

# Verify Changes

Run the project's test suite to verify that changes work correctly before claiming completion.

## Steps

1. **Identify the test command** based on the project:
   - Node/JS projects: `npm test` or `yarn test` or `pnpm test`
   - Python projects: `pytest` or `python -m pytest` or `make test`
   - Rust projects: `cargo test`
   - Go projects: `go test ./...`
   - Java/Maven: `mvn test`
   - Java/Gradle: `./gradlew test`
   - Check for project-specific commands in README, Makefile, or package.json scripts

2. **Run the tests** using the Bash tool

3. **Report results** concisely:
   - If tests pass: "✓ All tests pass"
   - If tests fail: Show the failure output and identify which tests failed

## Notes

- If no tests exist in the project, report that and skip verification
- For large test suites, consider running only relevant tests if the project supports it (e.g., `pytest path/to/test_file.py`)
- If tests require setup (database, env vars), check for setup instructions in the project
