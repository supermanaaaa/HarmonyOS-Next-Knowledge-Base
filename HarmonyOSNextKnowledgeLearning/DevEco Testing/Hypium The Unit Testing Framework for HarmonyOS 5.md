# Hypium: The Unit Testing Framework for HarmonyOS 5

# 1. Overview

**Hypium** is the official unit testing framework for HarmonyOS 5. It supports writing test cases, executing them, and viewing results within DevEco Studio.

| Feature           | Description                              |
| ----------------- | ---------------------------------------- |
| Case Writing      | Mocha-style syntax (`describe`, `it`)    |
| Execution         | Package, suite, and method-level testing |
| Mock Support      | Supported from version 1.0.1             |
| Data-Driven Tests | Supported from version 1.0.2             |

------

## 2. Installation

Add the following dependency in your project's `package.json`:

```json
"dependencies": {
  "@ohos/hypium": "1.0.6"
}
```

Use `npm view @ohos/hypium version` to check the latest version.

Import Hypium APIs:

```ts
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
```

------

## 3. Feature Guide

### 3.1 Basic Flow

Use `describe` to group test cases and `it` for each test:

```ts
describe('ExampleTest', () => {
  it('should do something', 0, () => {
    // Your logic here
  });
});
```

------

### 3.2 Assertions

Hypium provides rich assertion methods for verifying expected outcomes.

| Method            | Description                      |
| ----------------- | -------------------------------- |
| `assertEqual`     | Checks for equality              |
| `assertContain`   | Checks if a substring is present |
| `assertUndefined` | Checks if value is `undefined`   |

**Example:**

```ts
import { describe, it, expect } from '@ohos/hypium';
export default function abilityTest() {
  describe('ActsAbilityTest', function () {
    it('assertContain', 0, function () {
      let a = 'abc';
      let b = 'b';
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    });
  });
}
```

------

### 3.3 Mock Support

Starting from v1.0.1, Hypium supports mocking of class methods.

```ts
import { describe, expect, it, MockKit, when } from '@ohos/hypium';

export default function ActsAbilityTest() {
  describe('ActsAbilityTest', function () {
    it('testMockfunc', 0, function () {
      let mocker = new MockKit();

      class ClassName {
        method_1(arg) { return '888888'; }
        method_2(arg) { return '999999'; }
      }

      let claser = new ClassName();
      let mockfunc = mocker.mockFunc(claser, claser.method_1);
      when(mockfunc)('test').afterReturnNothing();

      expect(claser.method_1('test')).assertUndefined();
    });
  });
}
```

------

### 3.4 Data-Driven Testing

From version `1.0.2`, Hypium supports parameterized and stress testing based on a `data.json` file.

**Sample data.json:**

```json
{
  "suites": [
    {
      "describe": ["actsAbilityTest"],
      "stress": 2,
      "params": {
        "suiteParams1": "suiteParams001",
        "suiteParams2": "suiteParams002"
      },
      "items": [
        {
          "it": "testDataDriverAsync",
          "stress": 2,
          "params": [
            { "name": "tom", "value": 5 },
            { "name": "jerry", "value": 4 }
          ]
        },
        {
          "it": "testDataDriver",
          "stress": 3
        }
      ]
    }
  ]
}
```

**Run with parameters:**

```ts
import AbilityDelegatorRegistry from '@ohos.application.abilityDelegatorRegistry';
import { Hypium } from '@ohos/hypium';
import testsuite from '../test/List.test';
import data from '../test/data.json';

Hypium.setData(data);
Hypium.hypiumTest(abilityDelegator, abilityDelegatorArguments, testsuite);
```

------

## 4. Running Tests

You can run tests in DevEco Studio via:

- **Package Level**: Run all test cases in a package
- **Suite Level**: Run all tests within a `describe` block
- **Method Level**: Run an individual test (`it` block)

