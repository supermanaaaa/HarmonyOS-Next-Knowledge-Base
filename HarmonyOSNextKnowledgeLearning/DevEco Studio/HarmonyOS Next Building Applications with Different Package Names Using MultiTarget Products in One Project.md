# HarmonyOS Next: Building Applications with Different Package Names Using Multi-Target Products in One Project

## Introduction

In daily development, manually switching signature files and package names when dealing with **multi-signature** and multi-product build outputs is error-prone and time-consuming. HarmonyOS provides custom hvigor plugins and multi-target product building capabilities. We can use hvigor plugins to dynamically modify project configurations, ensuring that a single codebase can switch between different package names while maintaining core functionality. This allows us to generate customized build products through multi-target product building.

## I. Understanding Multi-Target Product Building

### 1. What is Multi-Target Product Building?

Simply put, multi-target products refer to highly customized output modules. Developers can build different HAP, HAR, HSP, APP, etc., by defining different build configurations to achieve differentiation between products. For detailed customization options, see: https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-multi-target#section19846433183815

### 2. Build Schematic Diagram

![img](data:image/svg+xml,%3csvg%20xmlns=%27http://www.w3.org/2000/svg%27%20version=%271.1%27%20width=%27400%27%20height=%27256%27/%3e)![image](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20250418154627.64703285563402700451040688667200:50001231000000:2800:BC8D743FEC9618A1BB43BA5947170F4C6B851E59029B48AB88A96E1F35A9D8F8.png)

## II. Implementing Multi-Target Product Building in a Project

*(Source code reference branch: feature/multiTargetProduct)*

### 1. Configuring Multi-Target Product Building

Multi-target product building requires modifying configuration files like `build-profile.json5` and `module.json5` to define different `product` and `target` entries. Developers can specify device types, source sets, resources, and assign different targets to products. The build tool generates targets based on these configurations and combines them into customized products.

#### Configure Signing Configs for Different Projects:

Define `default`, `demo_debug`, and `demo_release` signing configurations for debugging and release builds:

```typescript
"signingConfigs": [
  {
    "name": "default", // Default certificate
    "type": "HarmonyOS",
    "material": { /* ... default certificate details ... */ }
  },
  {
    "name": "demo_debug", // Debugging certificate
    "type": "HarmonyOS",
    "material": { /* ... debug certificate details ... */ }
  },
  {
    "name": "demo_release", // Release certificate
    "type": "HarmonyOS",
    "material": { /* ... release certificate details ... */ }
  }
]
```

#### Define Products with Different Signing Configs:

Each product uses a specific signing configuration to generate 差异化 outputs:

```typescript
"products": [
  {
    "name": "default",
    "signingConfig": "default", // Default product uses default certificate
    "compatibleSdkVersion": "5.0.1(13)",
    "runtimeOS": "HarmonyOS",
    "buildOption": { /* ... build options ... */ }
  },
  {
    "name": "products_debug",
    "signingConfig": "demo_debug", // Debug product uses debug certificate
    "compatibleSdkVersion": "5.0.1(13)",
    "runtimeOS": "HarmonyOS",
    "buildOption": { /* ... build options ... */ }
  },
  {
    "name": "products_release",
    "signingConfig": "demo_release", // Release product uses release certificate
    "compatibleSdkVersion": "5.0.1(13)",
    "runtimeOS": "HarmonyOS",
    "buildOption": { /* ... build options ... */ }
  }
]
```

#### Link Products to Targets in HAP/HSP Modules:

Configure targets in `modules` to associate products with build outputs:

```typescript
"modules": [
  {
    "name": "entry",
    "srcPath": "./entry",
    "targets": [
      {
        "name": "default",
        "applyToProducts": [
          "default",
          "products_debug",
          "products_release"
        ]
      }
    ]
  }
]
```

### 2. Switching Product Configurations and Output Packages

#### Manual Switching Interface:

![image-20250422101824117](C:\Users\admin\Desktop\md导出\博客\鸿蒙NEXT生态进阶：基于hvigor插件实现多目标产物高效构建\image-20250422101824117.png)

![image-20250422101908531](C:\Users\admin\Desktop\md导出\博客\鸿蒙NEXT生态进阶：基于hvigor插件实现多目标产物高效构建\image-20250422101908531.png)

## III. Building Different Package Names and Configurations on Multi-Target Products

*(Source code reference branch: feature/differentPackageConfigurations)*

### 1. Adding Signing and Product Configs for a Second App

#### New Signing Configuration for Second App:

```typescript
"signingConfigs": [
  // ... existing configs ...
  {
    "name": "demo_debug_test2", // Signing for the second app
    "type": "HarmonyOS",
    "material": { /* ... testDemo2 certificate details ... */ }
  }
]
```

#### Define a New Product with Unique Identifiers:

Configure `label`, `icon`, `bundleName`, and `output` for differentiation. Use `buildProfileFields` for custom parameters:

```typescript
"products": [
  // ... existing products ...
  {
    "name": "products_debug_test2",
    "signingConfig": "demo_debug_test2",
    "compatibleSdkVersion": "5.0.1(13)",
    "runtimeOS": "HarmonyOS",
    "label": "$string:app_name_test2", // Second app's name
    "icon": "$media:app_icon_test2", // Second app's icon
    "bundleName": "com.atomicservice.6917571239128090930", // Second app's package name
    "buildOption": { /* ... build options ... */ },
    "output": { "artifactName": "products_debug_test2" } // Unique output directory
  }
]
```

### 2. Implementation Results After Configuration

#### Output Product Information:

![image-20250422112242772](C:\Users\admin\Desktop\md导出\博客\鸿蒙NEXT生态进阶：基于hvigor插件实现多目标产物高效构建\image-20250422112242772.png)

  Desktop icon and application name after it takes effect:

![image-20250422111847105](C:\Users\admin\Desktop\md导出\博客\鸿蒙NEXT生态进阶：基于hvigor插件实现多目标产物高效构建\image-20250422111847105.png)

### 3. Querying and Using Custom Constants

Use `buildProfileFields` to define product-specific parameters for code differentiation.

#### Configure Custom Constants in Products:

```typescript
"products": [
  {
    "name": "default",
    "buildOption": {
      "arkOptions": {
        "buildProfileFields": {
          "isStartNet": false,
          "isDebug": true,
          "productsName": "default"
          // ... other custom parameters ...
        }
      }
    }
  },
  // ... repeat for other products with unique values ...
]
```

#### Access Custom Configs in Code:

![image-20250422113557272](C:\Users\admin\Desktop\md导出\博客\鸿蒙NEXT生态进阶：基于hvigor插件实现多目标产物高效构建\image-20250422113557272.png)

Import `BuildProfile` and use parameters in UI:

```typescript
import BuildProfile from 'BuildProfile';  
Column() {  
  Text(`productsName:${BuildProfile.productsName}`)  
  // ... other Text components for custom fields ...  
}  
```

#### UI Display of Custom Parameters:

![image-20250422114531440](C:\Users\admin\Desktop\md导出\博客\鸿蒙NEXT生态进阶：基于hvigor插件实现多目标产物高效构建\image-20250422114531440.png)

## IV. Conclusion

Multi-target product building allows rapid switching between different build configurations and solves package name differentiation for scenarios like multi-entity app submissions (e.g., domestic vs. foreign entities on AG). While this covers basic customization, advanced needs (e.g., dynamic `client_id`/`app_id` in `module.json5`) require integration with **hvigor plugins**. Future articles will explore using custom scripts to modify hard-coded configurations during builds.

## VI. Source Code Repository

[Repository Address](https://gitee.com/qq1963861722/MultiBuildDemo.git)

## VII. Reference Materials

[Multi-Target Product Building Practice - Huawei HarmonyOS Developers](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-multi-target)
[HarmonyOS Multi-Environment Building Guide - Juejin](https://juejin.cn/post/7427050728719368202)