# 🏃 How to Run OTFHA Unit Tests

## Quick Start

### Run Phase 1 Tests (Validators & Formatters)

```powershell
# Navigate to the Flutter project
cd otfha

# Run all Phase 1 unit tests
flutter test test/unit/core/utils/
```

**Expected Output:**
```
00:07 +148: All tests passed!
```

---

## 📋 Step-by-Step Guide

### Prerequisites

1. **Flutter SDK** installed and in PATH
2. **Project dependencies** installed

```powershell
# Verify Flutter is installed
flutter --version

# Install dependencies (if not already done)
cd otfha
flutter pub get
```

### Running Tests

#### Option 1: Run All Phase 1 Tests
```powershell
cd otfha
flutter test test/unit/core/utils/
```

#### Option 2: Run Validators Tests Only
```powershell
flutter test test/unit/core/utils/validators_test.dart
```

#### Option 3: Run Formatters Tests Only
```powershell
flutter test test/unit/core/utils/formatters_test.dart
```

#### Option 4: Run With Verbose Output
```powershell
flutter test --reporter expanded test/unit/core/utils/
```

This shows each test name as it runs:
```
00:00 +0: Validators.required should return error for null value
00:00 +1: Validators.required should return error for empty string
00:00 +2: Validators.required should return error for whitespace only string
...
```

#### Option 5: Run With Coverage
```powershell
flutter test --coverage test/unit/core/utils/
```

This generates `coverage/lcov.info` with coverage data.

---

## 📊 Understanding Test Output

### Success Output
```
00:07 +148: All tests passed!
```

| Part | Meaning |
|------|---------|
| `00:07` | Execution time (7 seconds) |
| `+148` | 148 tests passed |
| `All tests passed!` | No failures |

### Failure Output (Example)
```
00:05 +50 -1: test/unit/core/utils/validators_test.dart: Validators.email should return error for empty email [E]
  Expected: 'Email is required'
    Actual: null
```

| Part | Meaning |
|------|---------|
| `+50` | 50 tests passed |
| `-1` | 1 test failed |
| `[E]` | Error marker |

---

## 🔧 Troubleshooting

### "No tests found"
```
Error: No tests found
```

**Solutions:**
1. Ensure you're in the `otfha` directory
2. Check test files exist in `test/unit/core/utils/`
3. Verify files end with `_test.dart`

### "Cannot find package"
```
Error: Target of URI doesn't exist: 'package:otfha/...'
```

**Solutions:**
1. Run `flutter pub get`
2. Check `pubspec.yaml` has correct package name

### Flutter command not found
```
'flutter' is not recognized as an internal or external command
```

**Solutions:**
1. Add Flutter to PATH
2. Run `flutter doctor` to verify installation

---

## 📁 Test File Locations

```
otfha/
└── test/
    ├── unit/
    │   └── core/
    │       └── utils/
    │           ├── validators_test.dart    # 69+ tests
    │           └── formatters_test.dart    # 79+ tests
    └── helpers/
        └── test_helpers.dart               # Shared utilities
```

---

## ✅ Verified Results

### Phase 1: Unit Tests (December 15, 2024)

**Command:**
```powershell
PS> flutter test test/unit/core/utils/
```

**Result:**
```
00:07 +148: All tests passed!
```

| Metric | Value |
|--------|-------|
| Total Tests | 148 |
| Passed | 148 |
| Failed | 0 |
| Execution Time | 7 seconds |

---

### Integration Tests (December 15, 2024)

**Command:**
```powershell
PS> flutter test test/integration/
```

**Result:**
```
00:03 +42: All tests passed!
```

| Metric | Value |
|--------|-------|
| Total Tests | 42 |
| Passed | 42 |
| Failed | 0 |
| Execution Time | 3 seconds |

---

### Security Tests (December 15, 2024)

**Command:**
```powershell
PS> flutter test test/security/
```

**Result:**
```
00:01 +89: All tests passed!
```

| Metric | Value |
|--------|-------|
| Total Tests | 89 |
| Passed | 89 |
| Failed | 0 |
| Execution Time | 1 second |

---

### Combined Results

| Category | Tests | Status |
|----------|-------|--------|
| Unit Tests | 148 | ✅ Passed |
| Integration Tests | 42 | ✅ Passed |
| Security Tests | 89 | ✅ Passed |
| **Total** | **279** | ✅ **All Passed** |

---

## 🚀 Run All Tests

```powershell
# Run ALL tests at once
flutter test

# Or run each category separately
flutter test test/unit/
flutter test test/integration/
flutter test test/security/
```

---

*Document Created: December 15, 2024*
*Last Updated: December 15, 2024*

