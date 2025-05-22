# Mastering Paradigm Shifts: Practical Applications of Cangjie's Functional and Object-Oriented Programming in HarmonyOS 5

If the powerful type system and type inference lay a solid foundation for the Cangjie language, then its flexible integration of multi-paradigm programming truly endows developers with great freedom and creativity.

In HarmonyOS 5 application development, I have personally experienced that whether it is complex business modeling, concurrent processing, or data flow, as long as the functional and object-oriented paradigms are reasonably switched, Cangjie can always express clear and efficient logic in the most elegant way.

In this article, let me take you on an exploration of how to master different programming paradigms in Cangjie and grasp the best practices in actual development.

------

## Functional Programming: A Concise Tool for Expressing Business Logic

In Cangjie, functions are "first-class citizens." This means:

1. Functions can be assigned, passed, and returned like ordinary variables.
2. Supports higher-order functions, lambda expressions, and currying.
3. Rich pattern matching (`match-case`) greatly simplifies conditional branches.

------

### Practical Example: Higher-Order Functions + Lambda

Suppose we need to process an array of integers, find all even numbers, and square them. The implementation in Cangjie's functional style is very natural:

```python
func isEven(x: Int): Bool {
    x % 2 == 0
}

func square(x: Int): Int {
    x * x
}

main() {
    let nums = [1, 2, 3, 4, 5, 6]

    let result = nums
      .filter(isEven)
      .map(square)

    println(result) // [4, 16, 36]
}
```

1. `filter` and `map` are commonly used higher-order functions.
2. Lambda expressions can be further simplified:

```python
let result = nums
  .filter({ it => it % 2 == 0 })
  .map({ it => it * it })
```

**Practical Experience**:
 Cangjie's functional programming syntax closely adheres to the natural expression of business logic. The code is not only concise but also highly readable.

------

## Object-Oriented Programming: The Foundation for Modeling Complex Systems

Although Cangjie has strong support for functional programming, its object-oriented (OOP) capabilities are equally solid, especially in the following scenarios:

1. Complex business modeling (such as order, payment, and logistics systems)
2. Interface component encapsulation (UI controls, interaction logic)
3. Cross-module communication (service interfaces, protocol definitions)

------

### Summary Table of Cangjie OOP Core Features

| Feature                            | Description                                                  |
| ---------------------------------- | ------------------------------------------------------------ |
| Single Inheritance                 | A class can have only one parent class                       |
| Multiple Interface Implementations | A class can implement multiple interfaces                    |
| `open` Modifier                    | Controls whether a class or method can be inherited/overridden |
| All Classes Inherit `Any`          | Ensures a unified basic object model                         |

------

### Practical Example: Classes, Interfaces, and Polymorphism

```python
public interface Shape {
    func area(): Float64
}

public class Circle <: Shape {
    let radius: Float64

    init(r: Float64) {
        this.radius = r
    }

    public func area(): Float64 {
        3.1415 * radius * radius
    }
}

public class Rectangle <: Shape {
    let width: Float64
    let height: Float64

    init(w: Float64, h: Float64) {
        this.width = w
        this.height = h
    }

    public func area(): Float64 {
        width * height
    }
}

main() {
    let shapes: Array = [Circle(3.0), Rectangle(4.0, 5.0)]

    for (let shape in shapes) {
        println(shape.area())
    }
}
```

**Output:**

```
28.2735  
20.0
```

1. `Shape` is an interface that defines a common behavior.
2. `Circle` and `Rectangle` implement specific logic respectively.
3. Polymorphic calls are achieved through the interface array `Array<Shape>`.

**Practical Experience**:
 Cangjie's OOP model is clean and concise, without the problems of complex multiple inheritance, and can meet most object-oriented requirements, making it very suitable for large system modeling.

------

## Mixed Paradigm Practice: Smooth Switching, at Ease

In real projects, we often need to combine functional and object-oriented programming.

For example, in a chat application, the `MessageProcessor` class may be organized in an object-oriented way, while the internal specific processing logic is combined in a functional style.

```python
public class MessageProcessor {
    public func process(messages: Array): Array {
        messages
          .filter({ msg => msg != "" })
          .map({ msg => msg.trim() })
          .map({ msg => "Processed: " + msg })
    }
}

main() {
    let rawMessages = [" Hello ", "", "World "]
    let processor = MessageProcessor()
    let cleanMessages = processor.process(rawMessages)

    println(cleanMessages)
}
```

**Output:**

```
["Processed: Hello", "Processed: World"]
```

1. The class encapsulates the overall processing flow.
2. Internally, `filter` + `map` higher-order functions are used to quickly process the collection.

This way of using a mixed paradigm is extremely natural in Cangjie, and the development experience is very smooth without a sense of fragmentation.

------

## Conclusion

In HarmonyOS 5 development, the multi-paradigm feature of the Cangjie language is not a gimmick but a real productivity tool.

| Scenario                    | Recommended Paradigm | Reason                   |
| --------------------------- | -------------------- | ------------------------ |
| Collection Operations       | Functional           | Concise, highly abstract |
| Process Control             | Imperative           | Simple and intuitive     |
| Business Modeling           | Object-Oriented      | Clear structure          |
| Complex System Architecture | Mixed Paradigm       | Flexible and efficient   |

Practical experience tells me that developers who know how to flexibly switch paradigms can complete complex tasks more quickly and with higher quality.
 And Cangjie is born for this flexibility.