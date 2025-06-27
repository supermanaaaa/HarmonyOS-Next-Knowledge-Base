# HarmonyOS 5 Business App Development Insights — In-Depth State Management

## 1. Introduction

In building real-world business applications on HarmonyOS 5, state management is one of the most critical aspects of ArkUI development. It directly impacts UI responsiveness, interaction accuracy, and data consistency across components.

This article dives into state management mechanisms introduced in HarmonyOS 5 API version 11+, including frequently encountered challenges and practical solutions. We’ll cover decorators like `@State`, `@Prop`, `@Link`, and `@Watch`—key tools for managing component communication, reactivity, and rendering control in large-scale apps.

> If you have any questions, suggestions, or corrections, feel free to comment, message, or email. Your support is greatly appreciated. 🙏

------

## 2. @State

### 1. Initialization Behavior

When a component initializes, `@State` can only accept a value once from its parent. Changes made to the parent state afterward won’t affect the child. This is why it's known as internal component state.

```ts
@Entry
@Component
export struct ExpComponent {
  @State title: string = "Title"

  build() {
    Column() {
      ExpChildComponent({
        childTitle: this.title
      })
      Button(this.title)
        .onClick(() => {
          this.title = "Click"
        })
    }
  }
}

@Component
export struct ExpChildComponent {
  @State childTitle: string = "????"

  build() {
    Text(this.childTitle)
  }
}
```

In this example, `ExpChildComponent` won’t update after `onClick`.

------

### 2. Too Many @State Variables

For complex pages, declaring multiple `@State` variables can clutter your code. A better approach is wrapping state in a class:

```ts
@Component
export struct ExpComponent {
  @State uiState: ExpUIState = new ExpUIState()

  build() {
    Text(this.uiState.title)
  }
}

class ExpUIState {
  title: string = ""
}
```

This keeps your components clean and organized.

------

### 3. Arrays

`@State` supports arrays and observes changes like:

```ts
@State title: Model[] = [new Model(1), new Model(2)];

this.title = [new Model(2)];
this.title[0] = new Model(2);
this.title.pop();
this.title.push(new Model(12));
```

However, nested property updates are not observed:

```ts
this.title[0].value = 6;
```

Updates to object properties inside arrays will not trigger reactivity.

------

### 4. Scope Effects

Due to JavaScript’s closure behavior, arrow functions inherit `this` from the context in which they are defined—not from the execution context.

```ts
@Component
export struct ExpComponent {
  @State uiState: ExpUIState = new ExpUIState()

  build() {
    Column() {
      Text(this.uiState.title)
      Button("Click").onClick(() => {
        this.uiState.autoRefreshTitle()
      })
    }
  }
}

class ExpUIState {
  title: string = "??"
  autoRefreshTitle = () => {
    this.title = "AutoRefreshTitle"
  }
}
```

The above won't trigger a UI update. Use this pattern instead:

```ts
@Component
export struct ExpComponent {
  @State uiState: ExpUIState = new ExpUIState()

  build() {
    Column() {
      Text(this.uiState.title)
      Button("Click").onClick(() => {
        let ref = this.uiState
        this.uiState.autoRefreshTitle(ref)
      })
    }
  }
}

class ExpUIState {
  title: string = "??"
  autoRefreshTitle = (st: ExpUIState) => {
    st.title = "AutoRefreshTitle"
  }
}
```

------

### 5. Nested Objects

When `@State` decorates an object that contains sub-objects or arrays:

```ts
class ExpUIState {
  childs: ExpChild[] = []
  firstChild: ExpChild = new ExpChild()
}
```

Only the top-level reference is reactive. Updating inner fields (e.g. `uiState.firstChild.subTitle = ""`) will not update the UI.

Solution: avoid using `@State` for deeply nested structures.

------

## 3. @Prop

### 1. Initialization Behavior

Similar to `@State`, but `@Prop` values are updated from parent components. However, changes made within the child will not reflect back to the parent.

------

### 2. Prop Chaining

Using `@Prop` across multiple nested components can get messy. Consider switching to `@Provide`.

------

### 3. @Require

`@Prop` can be combined with `@Require` to enforce required properties:

```ts
@Require @Prop index: number
```

------

### 4. @Observed

To observe changes in nested objects passed via `@Prop`, use `@Observed`.

```ts
@Component
export struct ExpComponent {
  @State uiState: ExpUIState = new ExpUIState()

  build() {
    Column() {
      ExpChildComponent({
        child: this.uiState.firstChild
      })
      Button("Click").onClick(() => {
        this.uiState.firstChild.subTitle = "????"
      })
    }
  }
}

@Component
export struct ExpChildComponent {
  @Require @Prop child: ExpChild

  build() {
    Text(this.child.subTitle)
  }
}

@Observed
class ExpUIState {
  childs: ExpChild[] = []
  firstChild: ExpChild = new ExpChild()
}

@Observed
class ExpChild {
  subTitle: string = "啊"
}
```

Every layer must be marked with `@Observed` and received via `@Prop`.

------

## 4. @Link

### 1. Initialization Behavior

`@Link` creates two-way bindings between parent and child:

```ts
Comp({ aLink: this.aState })  // since API 9
Comp({ aLink: $aState })      // also supported
```

------

### 2. Used in Dialogs

`@Link` works well for synchronizing data within dialog components:

```ts
@CustomDialog
struct CustomDialog01 {
  @Link inputValue: string;
  controller: CustomDialogController;

  build() {
    Column() {
      Text('Change text')
        .fontSize(20)
        .margin({ top: 10, bottom: 10 })

      TextInput({ placeholder: '', text: this.inputValue })
        .height(60)
        .width('90%')
        .onChange((value: string) => {
          this.inputValue = value;
        })
    }
  }
}

@Entry
@Component
struct DialogDemo01 {
  @State inputValue: string = 'click me';
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialog01({
      inputValue: $inputValue
    })
  })

  build() {
    Column() {
      Button(this.inputValue)
        .onClick(() => {
          this.dialogController.open();
        })
        .backgroundColor(0x317aff)
    }
    .width('100%')
    .margin({ top: 5 })
  }
}
```

You can also pass in a function if needed.

------

### 3. Deeply Nested @Link

Like `@Prop`, using deeply nested `@Link` structures is discouraged. Use `@Provide`/`@Consume` instead.

------

## 5. @Watch

`@Watch` is a direct way to observe changes to state variables.

------

### 1. Avoid Mutating Watched Variables Inside Watchers

```ts
@State @Watch("onUiStateChange") uiState: ExpUIState = new ExpUIState()

onUiStateChange() {
  this.uiState.firstChild = new ExpChild()  // Infinite loop!
}
```

------

### 2. Event Propagation from Child to Parent

You can use `@Link` or `@Provide`/`@Consume` to sync data between components, and use `@Watch` for observation.

------

### 3. Not Sticky

`@Watch` doesn’t trigger on initial assignment—only on changes.

------

### 4. Logging Use Case

`@Watch` is great for logging state changes.

------

## 6. Coming Soon

Next post may continue exploring:
 `@State`, `@Prop`, `@Provide`, `@ObjectLink`, `@ObjectLinkV2`, `@Link`, `@Watch`, and `@Track` (tentative)

------

## 7. Conclusion

That’s it!

If you have any questions, suggestions, or feedback, feel free to comment, message, or email. Thank you for reading 🙏

