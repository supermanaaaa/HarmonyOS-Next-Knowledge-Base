# How to Test HarmonyOS  5 Apps: Must-Have Toolkit for Developers

With over 4,000 applications now integrated into the HarmonyOS ecosystem, Huawei has made remarkable progress in the native development of HarmonyOS NEXT. The ecosystem offers developers a comprehensive suite of tools including **DevEco Studio**, **DevEco Testing**, and the **Hypium automation testing framework**. This blog introduces key tools and services essential for HarmonyOS development and testing.

------

## HarmonyOS Development Toolkit Overview

Huawei provides developers with a rich set of tools and services for HarmonyOS application development, debugging, and testing. These include:

### 1. AppGallery Connect (AGC)

A one-stop service platform for app ideation, development, distribution, operation, and monetization.

- [AGC Portal](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html#/)

### 2. DevEco Studio

An integrated development platform that supports distributed development across multiple devices.

- Features: smart code editing, low-code development, bidirectional preview, lightweight build tool **DevEco Hvigor**, and local emulator.
- [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/)

### 3. DevEco Testing

Provides comprehensive HarmonyOS application and device testing solutions.

- [DevEco Testing Portal](https://devecotesting.huawei.com/userPortal/)
- [Developer Documentation](https://developer.huawei.com/consumer/cn/next/deveco-testing/)

### 4. HarmonyOS Design

A continually updated design resource library with icons, colors, typography, sounds, components, and templates.

- [HarmonyOS Design](https://developer.huawei.com/consumer/cn/design/)

### 5. ArkTS

HarmonyOS's official application development language, built on TypeScript with stricter static typing and UI/state management capabilities.

- [ArkTS Documentation](https://developer.huawei.com/consumer/cn/arkts/)

### 6. ArkUI

A declarative UI development framework optimized for building distributed app interfaces.

- [ArkUI Overview](https://developer.huawei.com/consumer/cn/arkui/)

### 7. ArkCompiler

Huawei's unified programming platform that supports cross-device compilation and execution.

- [ArkCompiler](https://developer.huawei.com/consumer/cn/arkcompiler/)

------

## Automated Testing Frameworks

### ArkxTest: HarmonyOS Automation Framework

Huawei offers a robust automation testing framework that supports JS/TS-based unit and UI testing for HarmonyOS.

**Key Components:**

- **Unit Testing Framework**: For validating application APIs and logic.
- **UI Testing Framework**: For end-to-end testing using UI interactions.

> Note: The UI framework is supported from HarmonyOS 3.0 onwards.

Full guidelines: [ArkxTest Documentation](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkxtest-guidelines-0000001478061625-V3)

------

### Hypium: Next-Gen Automated Testing for HarmonyOS

**"Hypium" = "Hyper Automation + ium"**
 A new plugin-based framework for DevEco Studio that simplifies test case creation and execution during the development cycle.

**Key Modules:**

- **HJsUnit**: Unit testing interface for logic validation.
- **HUiTest**: Simple API to test UI elements and user interactions.

By integrating into DevEco Studio, Hypium auto-generates test directories, classes, and templates, reducing the setup time and increasing test productivity.

Learn more:

- [Hypium Overview](https://developer.huawei.com/consumer/cn/next/deveco-testing/)

------

## HarmonyOS Special-Purpose Testing Services

To deliver a smooth, secure, and responsive user experience, apps must undergo rigorous testing phases:

### Testing Lifecycle:

1. **Development Testing**: Basic validation of usability.
2. **Functional Testing**: Ensure feature completeness.
3. **Specialized Testing**: Validate security, performance, power consumption, and stability.
4. **Pre-launch Review**: Final compliance checks based on HarmonyOS testing standards.

### Why Specialized Testing?

Conventional teams often lack resources for advanced testing. Different scenarios demand different skills and environments. Huawei addresses this gap with **DevEco Testing**, a professional, simplified, and intelligent testing service.

**DevEco Testing Capabilities:**

- Stability Testing
- Network Availability (Dial Testing)
- Performance Profiling
- Security Audits
- Standard Compliance Validation

These services streamline the entire testing pipeline, allowing both developers and testers to validate HarmonyOS apps efficiently.

Full article: [Mastering HarmonyOS Specialized Testing](https://developer.huawei.com/consumer/cn/next/deveco-testing/)

