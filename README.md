# Obfuscate-Annotation

[English](#english) | [中文](#中文)

---

## English

> Annotations for controlling code obfuscation behavior in **Zelix KlassMaster** and **JNIC Native Obfuscator**

### Overview

This project provides a collection of Java annotations designed to work with popular obfuscation tools:
- **Zelix KlassMaster** - A powerful Java bytecode obfuscator
- **JNIC Native Obfuscator** - Native code obfuscation tool

These annotations enable fine-grained control over which parts of your code get obfuscated, allowing you to protect sensitive logic while keeping public APIs readable and maintainable.

### Features

- 🔒 Selective obfuscation control
- 📝 Clean, intuitive annotation syntax
- 🔧 Compatible with industry-standard obfuscators
- ⚡ Zero runtime overhead (annotations are compile-time only)

### Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Annotations](#annotations)
- [Examples](#examples)
- [License](#license)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/Obfuscate-Annotation.git
cd Obfuscate-Annotation

# Build with Maven (if applicable)
mvn clean package
```

### Usage

Add the annotation JAR to your project classpath and use annotations in your Java code:

```java
@NoStringObfuscate
public class SensitiveClass {
    // String obfuscation will be skipped for this class
}
```

### Annotations

#### ZKM (Zelix KlassMaster) Annotations

| Annotation | Target | Description |
|-----------|--------|-------------|
| `@ZKMIndy` | Class, Method | Enable invokedynamic obfuscation |
| `@NoRenameObfuscate` | Class, Method | Disable class/method renaming |
| `@NoStringObfuscate` | Class, Method | Disable string obfuscation |
| `@NoLongObfuscate` | Class, Method | Disable long constant obfuscation |
| `@NoIntegerObfuscate` | Class, Method | Disable integer obfuscation |
| `@NoFlowObfuscate` | Class, Method | Disable control flow obfuscation |
| `@NoExceptionsObfuscate` | Class, Method | Disable exception flow obfuscation |
| `@NoParameterChange` | Class, Method | Disable parameter transformation |
| `@NoReferencesObfuscate` | Class, Method | Disable invokedynamic obfuscation |

#### JNIC (JNIC Native Obfuscator) Annotations

| Annotation | Target | Description |
|-----------|--------|-------------|
| `@JNICInclude` | Class, Method | Include for native code obfuscation |
| `@JNICExclude` | Class, Method | Exclude from native code obfuscation |

### Examples

```java
// Protect a class from renaming, useful for reflection
@NoRenameObfuscate
public class ConfigLoader {
    public String loadConfig(String name) {
        return "config";
    }
}

// Keep strings readable for API calls
@NoStringObfuscate
public class APIClient {
    public void connect() {
        String endpoint = "https://api.example.com";
    }
}

// Include critical security code for native obfuscation
@JNICInclude
public class CryptoUtils {
    public String encrypt(String data) {
        // Sensitive encryption logic
        return data;
    }
}

// Disable multiple obfuscation types
@NoStringObfuscate
@NoFlowObfuscate
public class LegacyModule {
    // This module won't have string or control flow obfuscation
}
```

### Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

### License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 中文

> 用于控制 **Zelix KlassMaster** 和 **JNIC Native Obfuscator** 代码混淆行为的注解库

### 概述

本项目提供了一套 Java 注解库，用于与流行的混淆工具配合使用：
- **Zelix KlassMaster** - 功能强大的 Java 字节码混淆器
- **JNIC Native Obfuscator** - 本地代码混淆工具

这些注解可以对代码的混淆行为进行细粒度控制，让你在保护敏感逻辑的同时保持公共 API 的可读性和可维护性。

### 功能特点

- 🔒 细粒度混淆控制
- 📝 简洁直观的注解语法
- 🔧 兼容行业标准混淆工具
- ⚡ 零运行时开销（注解仅用于编译时）

### 目录

- [安装](#安装)
- [使用方法](#使用方法)
- [注解说明](#注解说明)
- [使用示例](#使用示例)
- [许可证](#许可证)

### 安装

```bash
# 克隆仓库
git clone https://github.com/yourusername/Obfuscate-Annotation.git
cd Obfuscate-Annotation

# 使用 Maven 构建
mvn clean package
```

### 使用方法

将注解 JAR 添加到项目的 classpath 中，然后在 Java 代码中使用注解：

```java
@NoStringObfuscate
public class SensitiveClass {
    // 该类的字符串混淆将被跳过
}
```

### 注解说明

#### ZKM (Zelix KlassMaster) 注解

| 注解 | 作用范围 | 功能说明 |
|------|--------|--------|
| `@ZKMIndy` | 类、方法 | 启用 invokedynamic 混淆 |
| `@NoRenameObfuscate` | 类、方法 | 禁用类/方法重命名 |
| `@NoStringObfuscate` | 类、方法 | 禁用字符串混淆 |
| `@NoLongObfuscate` | 类、方法 | 禁用长整型常量混淆 |
| `@NoIntegerObfuscate` | 类、方法 | 禁用整数混淆 |
| `@NoFlowObfuscate` | 类、方法 | 禁用控制流混淆 |
| `@NoExceptionsObfuscate` | 类、方法 | 禁用异常流混淆 |
| `@NoParameterChange` | 类、方法 | 禁用参数转换 |
| `@NoReferencesObfuscate` | 类、方法 | 禁用 invokedynamic 混淆 |

#### JNIC (JNIC Native Obfuscator) 注解

| 注解 | 作用范围 | 功能说明 |
|------|--------|--------|
| `@JNICInclude` | 类、方法 | 纳入本地代码混淆 |
| `@JNICExclude` | 类、方法 | 排除本地代码混淆 |

### 使用示例

```java
// 保护类名不被重命名，对于反射调用很有用
@NoRenameObfuscate
public class ConfigLoader {
    public String loadConfig(String name) {
        return "config";
    }
}

// 保持字符串可读，用于 API 调用
@NoStringObfuscate
public class APIClient {
    public void connect() {
        String endpoint = "https://api.example.com";
    }
}

// 将关键安全代码纳入本地混淆
@JNICInclude
public class CryptoUtils {
    public String encrypt(String data) {
        // 敏感加密逻辑
        return data;
    }
}

// 禁用多种混淆方式
@NoStringObfuscate
@NoFlowObfuscate
public class LegacyModule {
    // 该模块不会进行字符串和控制流混淆
}
```

### 贡献指南

欢迎提交 Issue 和 Pull Request！

### 许可证

本项目采用 MIT 许可证 - 详见 LICENSE 文件
