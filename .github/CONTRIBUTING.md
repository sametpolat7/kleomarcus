# Contributing Guide

This document defines the development standards for this repository. All contributors must follow these rules to ensure code quality, consistency, and long-term maintainability.

---

## 1. Branching Strategy

### Protected Branch

* `main` is always deployable
* Direct commits to `main` are **not allowed**
* All changes must go through a Pull Request (PR)

### Branch Naming Convention

**Format**

```
<type>/<scope>-<short-description>
```

**Allowed types**

* `feature` – New functionality
* `bugfix` – Bug fixes
* `hotfix` – Urgent production fixes
* `refactor` – Code restructuring without behavior change
* `chore` – Tooling, configuration, dependencies
* `test` – Tests only
* `docs` – Documentation only

**Examples**

```
feature/auth-otp-login
bugfix/users-avatar-upload
refactor/services-payment
chore/configure-rubocop
```

---

## 2. Creating a Branch

Always branch from `main`:

```bash
git checkout main
git pull origin main
git checkout -b feature/users-profile-edit
```

This ensures your branch starts from stable, up-to-date code.

---

## 3. Commit Message Convention

This project follows **Conventional Commits**.

**Format**

```
<type>(<scope>): <short description>
```

**Examples**

```
feat(auth): add OTP verification
fix(users): prevent duplicate email
refactor(api): extract pagination logic
chore(ci): add brakeman scan
```

**Rules**

* Use present tense
* Keep commits small and focused
* One logical change per commit

---

## 4. Pull Request Rules

Every PR must:

* Target `main`
* Be focused on a single responsibility
* Pass all CI checks
* Be reviewed before merge

**PR Title Format**

```
<type>(<scope>): <short description>
```

---

## 5. Code Quality & CI

All PRs must pass the following checks:

### Ruby / Rails

* RuboCop
* ERB Lint
* Brakeman
* RSpec

### JavaScript

* ESLint
* Prettier

CI failures must be fixed before merging.

---

## 6. Refactor Policy

Refactor branches must:

* Change **structure only**, not behavior
* Not introduce new features or fixes
* Be clearly named using `refactor/*`

Example:

```
refactor/controllers-users
```

---

## 7. Hotfix Process

Hotfixes are used only for urgent production issues.

**Flow**

```bash
git checkout main
git checkout -b hotfix/auth-session-expiration
```

* Create PR targeting `main`
* Merge immediately after approval
* Deploy without delay

---

## 8. After Merge

* Squash or rebase commits if required
* Delete the branch after merge
* Ensure `main` remains deployable

---

## 9. General Rules

* One branch = one responsibility
* No direct commits to `main`
* CI must always pass
* Follow existing project patterns
* Prefer clarity over cleverness

---

By contributing to this repository, you agree to follow these standards.
