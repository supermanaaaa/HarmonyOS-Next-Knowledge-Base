# Exploring Cangjie: The Next-Gen Development Experience on HarmonyOS 5

As HarmonyOS 5 gradually matures, developers have set higher demands for programming languages in the new ecosystem: they need to enable efficient development, ensure performance and security, and easily adapt to complex scenarios of smart terminals, edge computing, and cloud collaboration. Against this backdrop, **Cangjie language** emerges.

As an engineer actually involved in HarmonyOS 5 application development, I deeply feel during my use of Cangjie that this is not just a simple language replacement, but a complete innovation from language design to development experience. In this article, I will *combine，practice)* to take you through the charm of Cangjie language, starting from its language features, paradigm support, and basic syntax.

## Introduction to Cangjie and the Background of HarmonyOS 5

HarmonyOS 5 focuses on an **"omni-scenario intelligent ecosystem"**, no longer compatible with traditional Linux kernel applications (such as APKs), but instead builds a new application ecosystem entirely based on a self-developed kernel and unified compilation system. Cangjie language is tailor-made for this goal:

| Feature                               | Description                                                  |
| ------------------------------------- | ------------------------------------------------------------ |
| Multi-Paradigm Programming            | Supports the integration of functional, imperative, and object-oriented paradigms |
| Extreme Performance Optimization      | Frontend IR optimization + backend instruction-level optimization + runtime optimization |
| Strong Security                       | Static type system + automatic memory management + multiple runtime checks |
| Concurrency-Friendly                  | Lightweight user-space threads + concurrency object library  |
| Ease of Use and Extensibility         | Rich syntactic sugar, type inference, type extension support |
| Omni-Scenario Application Development | Full coverage from mobile phones to IoT devices, from edge to cloud |

In essence, **Cangjie is the default preferred language for HarmonyOS 5 application development**, with extremely high official support, and future new features will also be prioritized in the Cangjie language system.

------

## Cangjie's Multi-Paradigm Support: Truly Developer-Centric

In real projects, the most intuitive feeling I have with Cangjie is that it is not confined to a single paradigm but **naturally integrates multiple programming styles**, allowing us to freely choose the most suitable expression according to business characteristics.

### 1. Object-Oriented Programming (OOP)

Cangjie fully supports traditional class and interface models:

```swift
public open class Animal {
    public open func speak(): Unit {
        println("Animal speaks")
    }
}

public class Dog <: Animal {
    public override func speak(): Unit {
        println("Dog barks")
    }
}

main() {
    let a: Animal = Dog()
    a.speak() // Dynamic dispatch, outputs "Dog barks"
}
```

- Supports single inheritance and multiple interface implementations
- Controls inheritance and override permissions via `open`
- All types implicitly inherit from `Any`, with a unified object model

**Practical Experience:**
 Highly consistent with the design philosophy of modern programming languages (such as Kotlin/Swift), reducing redundancy while being inherently secure.

### 2. Functional Programming (FP)

In Cangjie, functions are **first-class citizens**, freely assignable, passable, and returnable:

```swift
let square = {x: Int => x * x}

func apply(f: (Int) -> Int, v: Int): Int {
    return f(v)
}

main() {
    println(apply(square, 5)) // Outputs 25
}
```

- Supports Lambda expressions
- Supports higher-order functions and currying
- Built-in **pattern matching (match-case)** mechanism, greatly enhancing expressiveness

**Practical Experience:**
 In scenarios like list manipulation, state machines, and asynchronous orchestration, Cangjie's functional features are incredibly handy.

### 3. Imperative Programming

Of course, for most daily business logic, such as UI control and IO handling, traditional imperative programming fits seamlessly in Cangjie:

```swift
var total = 0
for (let i in 1..10) {
    total += i
}
println(total)
```

**Practical Experience:**
 It maintains familiarity without forcing developers to adapt to a "highbrow" style, making it very user-friendly.

## Cangjie's Basic Syntax and First Hello World Example

If you already know modern languages like Swift or Kotlin, getting started with Cangjie will be very easy. Its syntax design is concise and consistent, without excessive verbose keywords or symbols.

| Feature               | Cangjie Example                                  |
| --------------------- | ------------------------------------------------ |
| Variable Declaration  | `let a = 10` (immutable) `var b = 20` (mutable)  |
| Function Definition   | `func add(x: Int, y: Int): Int { return x + y }` |
| Conditional Statement | `if (a > b) { ... } else { ... }`                |
| Loop Statement        | `for (let i in 0..10) { ... }`                   |
| Class and Object      | `class A { ... } let obj = A()`                  |

### Hello World Example

```swift
func main() {
    println("Hello, HarmonyOS 5!")
}
```

Note:
 Cangjie's `main` function is the default program entry, omitting cumbersome modifiers like `public static void main`.

### A Slightly More Complete Example

```swift
public class Greeter {
    let message: String

    init(msg: String) {
        this.message = msg
    }

    public func greet(): Unit {
        println(this.message)
    }
}

main() {
    let greeter = Greeter("Welcome to HarmonyOS 5 with Cangjie!")
    greeter.greet()
}
```

**Output:**

```
Welcome to HarmonyOS 5 with Cangjie!
```

## Conclusion

Cangjie is not just developed for development's sake; it embodies **HarmonyOS 5's strategic vision** for future ecosystems.

From my actual development experience, Cangjie is **modern, concise, and powerful**, especially suitable for building intelligent applications oriented toward device collaboration and edge-cloud coordination.

Whether for small IoT applications or complex mobile and in-vehicle systems, **Cangjie strikes an excellent balance between development efficiency and execution performance**.

**Next Steps:**
 Cangjie's **type inference**, **generics**, and **concurrency model** will be key to determining development efficiency and are the directions I plan to delve into.