# HarmonyOS 5's Cangjie Language: In-depth Analysis of Concurrent Programming Paradigms

In the development field of HarmonyOS 5, the concurrent programming paradigm of Cangjie Language brings brand-new ideas and methods to developers. It not only solves many problems in traditional concurrent programming but also provides powerful tools and features, making concurrent programming more efficient and secure. As a technical personnel with rich practical experience in this field, I will deeply analyze the concurrent programming paradigm of Cangjie Language by combining the experience in the actual development process below.

------

## 一、Basics of the Concurrency Model

### （一）Design Concepts of Parallel/Concurrency in Cangjie Language

When designing the concurrency model, Cangjie Language adheres to the concepts of efficiency, security, and ease of use. It aims to provide developers with a concise and powerful way to write concurrent programs and avoid common pitfalls in traditional concurrent programming, such as data races and deadlocks. Different from other languages, Cangjie Language regards concurrency as a first-class citizen and provides native support at the language level, enabling developers to write concurrent code more naturally.

### （二）Differences between the Traditional Thread Model (Java/Kotlin) and Cangjie

In traditional Java and Kotlin development, although the thread model is powerful, it is relatively complex to use. Developers need to manually manage the creation, destruction, and synchronization of threads, which often easily causes various problems. For example, when multiple threads access shared resources, lock mechanisms need to be used to ensure data consistency, but improper use of locks may lead to performance bottlenecks and deadlocks.

Cangjie Language adopts a more concise and secure approach. It automatically handles many details in concurrent programming through built-in concurrency primitives and a type system. For example, the problem of data races is effectively avoided in Cangjie Language because its Actor model communicates through message passing rather than shared memory, fundamentally eliminating the risk of data races.

The following is a simple example for comparison:

**Java Example:**

```java
public class SharedVariableExample {
    private static int sharedVariable = 0;

    public static void main(String[] args) {
        Thread thread1 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                sharedVariable++;
            }
        });

        Thread thread2 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                sharedVariable--;
            }
        });

        thread1.start();
        thread2.start();

        try {
            thread1.join();
            thread2.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("Final value of shared variable: " + sharedVariable);
    }
}
```

In this example, since the two threads simultaneously access and modify the shared variable `sharedVariable`, it may lead to data inconsistency problems.

**Cangjie Language Example:**

```cangjie
actor SharedVariableActor {
    instance var value: Int64 = 0;

    receiver func increment(): Unit {
        value += 1;
    }

    receiver func decrement(): Unit {
        value -= 1;
    }

    receiver func getValue(): Int64 {
        return value;
    }
}
```

Through the Actor model, different Actors communicate through message passing, avoiding the data race problem caused by shared memory.

------

## 二、Visual Tuning Tools

### （一）Practical Demonstration of Task Scheduling Statistics and Measure Lanes

In the development of Cangjie Language, visual tuning tools are a very powerful function. Among them, Measure lanes provide statistical information on Task scheduling under different concurrency modes. For example, in a multithreaded application, we can view the number of Running Tasks at different times through Measure lanes.

During specific operations, we only need to select the corresponding concurrency mode in the Measure lane of the visual tool and then hover over the corresponding time point to see the exact number of Running Tasks. This is very helpful for analyzing the performance bottlenecks of the system. For example, when we find that the number of Running Tasks is too large in a certain time period, it may mean that the system resources are overused, and the task scheduling strategy needs to be further optimized.

### （二）Skills for Locating Pseudo-Parallel Problems (with Performance Comparison Tables)

Pseudo-parallelism is a common problem in concurrent programming. Pseudo-parallelism refers to tasks that seemingly execute in parallel but actually do not really use the advantages of multi-core processors, resulting in insignificant performance improvement.

We can easily locate pseudo-parallel problems through visual tuning tools. For example, we can determine whether there is a pseudo-parallel problem by comparing performance indicators under different concurrency modes, such as task execution time and CPU utilization. The following is a simple performance comparison table:

| Concurrency Mode | Task Execution Time (ms) | CPU Utilization (%) | Whether Pseudo-Parallel Exists |
| ---------------- | ------------------------ | ------------------- | ------------------------------ |
| Mode A           | 1000                     | 50                  | Yes                            |
| Mode B           | 500                      | 80                  | No                             |

It can be seen from the table that Mode A has a long task execution time and low CPU utilization, and there is likely a pseudo-parallel problem. By further analyzing the data provided by the visual tool, we can find out the reasons for pseudo-parallelism, such as overly complex dependency relationships between tasks or unreasonable thread synchronization mechanisms, and carry out targeted optimization.

------

## 三、Initial Exploration of the Actor Model

### （一）The `actor` Keyword and Example Code for Message Passing

In Cangjie Language, the `actor` keyword is the key to implementing the Actor model. Through the `actor` keyword, we can define an Actor type and define various receiver functions in it to process the received messages.

For example, the following is a simple Actor example:

```cangjie
actor MessageReceiver {
    receiver func receiveMessage(message: String): Unit {
        print("Received message: \(message)");
    }
}
```

In this example, `MessageReceiver` is an Actor type, which defines a receiver function `receiveMessage` for processing received string messages. When an instance of `MessageReceiver` receives a message, it will call this receiver function and print the received message.

### （二）Advantages of Unified Programming for Distributed and Concurrent Systems

An important advantage of the Actor model in Cangjie Language is that it realizes unified programming for distributed and concurrent systems. This means that developers can use the same programming method to write concurrent programs and distributed programs and then easily deploy them in a distributed environment.

In traditional development, writing concurrent programs and distributed programs usually requires using different technologies and frameworks, which increases the complexity of development. In Cangjie Language, through the Actor model, developers can focus on the implementation of business logic without paying too much attention to the underlying distributed details. For example, in a distributed system, Actors on different nodes can communicate through message passing, just like in a local concurrent environment, which greatly simplifies the development process of distributed systems.

------

**Conclusion:**
 The concurrent programming paradigm of Cangjie Language brings many advantages to the development of HarmonyOS 5. Through its unique design concepts, powerful visual tuning tools, and Actor model, developers can write concurrent programs more efficiently and securely. In the actual development process, we should make full use of these features, continuously optimize our code, and improve the performance and reliability of the system.