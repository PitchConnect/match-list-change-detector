# Code Quality Improvements Tracking

## Overview

As part of PR #3, we temporarily relaxed some code quality checks to align pre-commit hooks with the CI/CD pipeline and prevent local-only failures. This document tracks the work needed to fix the underlying violations and re-enable stricter checks.

## Checks Currently Relaxed

### 1. Mypy Type Checking
**Status:** Skipped in pre-push hook (matching CI behavior with `continue-on-error: true`)

**Files excluded from mypy checks:**
- `health_server.py`
- `logging_config.py`
- `match_list_change_detector.py`
- `centralized_api_client.py`
- `tests/test_utils.py`
- `docs/` directory

**Violations to fix:**
- Missing type annotations for functions
- Incompatible type assignments
- Missing return type annotations
- Type errors in class assignments

### 2. Flake8 Linting
**Status:** Excluded specific files with known issues

**Files excluded from flake8 checks:**
- `health_server.py` - E402 errors (module level imports not at top of file)
- `logging_config.py` - E402 errors (module level imports not at top of file)
- `tests/test_utils.py` - Docstring-related errors

**Violations to fix:**
- E402: Move module-level imports to the top of files
- Docstring issues in test utilities

### 3. Pydocstyle
**Status:** Skipped in CI (`SKIP=pydocstyle` in ci.yml)

**Note:** Pydocstyle runs locally but doesn't block CI builds. Consider whether to enforce it in CI.

## Proposed Plan

### Phase 1: Fix Flake8 E402 Errors (Low-hanging fruit)
- [ ] Fix import ordering in `health_server.py`
- [ ] Fix import ordering in `logging_config.py`
- [ ] Remove these files from flake8 exclusion list

### Phase 2: Add Type Annotations
- [ ] Add type annotations to functions in `match_list_change_detector.py`
- [ ] Add type annotations to functions in `centralized_api_client.py`
- [ ] Add type annotations to `health_server.py`
- [ ] Add type annotations to `logging_config.py`
- [ ] Add type annotations to `docs/source/conf.py`

### Phase 3: Fix Type Compatibility Issues
- [ ] Fix incompatible type assignments in `logging_config.py` (line 121)
- [ ] Fix return type issues in `centralized_api_client.py` (line 161)
- [ ] Fix class assignment issues in `match_list_change_detector.py`
- [ ] Fix attribute errors (missing `build_payload`, `fetch_matches_list_json`)

### Phase 4: Add Missing Docstrings
- [ ] Add docstrings to test utilities in `tests/test_utils.py`
- [ ] Consider re-enabling pydocstyle in CI

### Phase 5: Re-enable Checks
- [ ] Remove files from mypy exclusion list in `.pre-commit-config.yaml`
- [ ] Remove files from flake8 exclusion list in `.pre-commit-config.yaml`
- [ ] Update pre-push hook to remove `mypy` from SKIP list
- [ ] Consider removing `continue-on-error: true` from CI linting job

## Timeline

Suggested approach: Fix violations incrementally over the next 2-4 weeks
- Week 1: Phase 1 (E402 errors)
- Week 2: Phase 2 (Type annotations)
- Week 3: Phase 3 (Type compatibility)
- Week 4: Phase 4 & 5 (Docstrings and re-enable checks)

## Success Criteria

- [ ] All files pass mypy type checking without exclusions
- [ ] All files pass flake8 linting without exclusions
- [ ] Pre-push hook runs all checks (no SKIP parameters)
- [ ] CI/CD pipeline enforces all quality checks (no `continue-on-error`)
- [ ] Local development and CI/CD remain aligned

## Related

- PR #3: Initial harmonization of pre-commit hooks with CI/CD

---

*This document was created as part of the pre-commit hook harmonization effort to ensure we don't lose sight of improving code quality while maintaining development velocity.*
