# HarmonyOS 5: In-App Notification with SubWindow — A Coffee-Break Implementation

## 1. Introduction

While HarmonyOS 5 supports system-level notifications, business apps often require in-app notices—such as updates, alerts, or marketing messages—especially when users deny system-level notification permissions.

This article walks through how to implement an in-app floating notification banner using `SubWindow` in a **single-Ability Stage-based app architecture**, inspired by Android's `DecorView` overlay. The notification appears at the top of the screen and supports animation and interactivity—ideal for alerting users without interrupting their current workflow.

> Questions or suggestions? Feel free to leave a comment or contact me directly. 🙏

------

## 2. WindowStage & SubWindow

HarmonyOS 5 Stage model uses `@ohos.window` for window management. The two core APIs are:

- **`WindowStage`**: Manages window units.
- **`Window`**: Represents each window instance, including subwindows.

We use `WindowStage.createSubWindow()` to display a custom notification banner.

### Example: Creating and Displaying a SubWindow

```ts
let mainWindowStage: window.WindowStage = null;
let subWindow: window.Window = null;

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage) {
    mainWindowStage = windowStage;
    this.showSubWindow();
  }

  showSubWindow() {
    mainWindowStage.createSubWindow("NoticeSubWindow", (err, data) => {
      if (err.code) return;

      subWindow = data;
      subWindow.moveWindowTo(0, 0);

      let mainWidth = mainWindowStage.getMainWindowSync()
                          .getWindowProperties().windowRect.width;
      subWindow.resize(mainWidth, 500);

      subWindow.setUIContent("pages/SubWindowNotice", (err) => {
        if (err.code) return;
        subWindow.setWindowBackgroundColor("#00FFFFFF");  // Transparent window
        subWindow.showWindow();
      });
    });
  }

  destroySubWindow() {
    subWindow?.destroyWindow();
  }
}
```

### SubWindow Lifecycle Steps

1. **Create subwindow** using `createSubWindow`.
2. **Configure size/position** with `resize` and `moveWindowTo`.
3. **Inject content** via `setUIContent`.
4. **Show or destroy** as needed.

This approach gives us an overlay-like notification that's completely decoupled from the current page.

------

## 3. SubWindow UI — Notification Banner

We define a reusable notification component within a dedicated page (`pages/SubWindowNotice`), structured as:

```ts
@Entry
@Preview
@Component
struct SubWindowNotice {
  mHeight: number = vp(40)

  build() {
    Row({ space: vp(3) }) {
      Image($r("app.media.icon_default"))
        .autoResize(true)
        .margin({ top: vp(5), bottom: vp(5) })
        .width(vp(25))

      Column() {
        Text("Notification Title")
        Text("This is a brief description.")
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button("Action").fontSize("10fp")
    }
    .height(this.mHeight)
    .padding({ left: vp(5), right: vp(5), bottom: vp(3), top: vp(3) })
    .border({ radius: vp(10) })
    .margin({ left: vp(5), right: vp(5) })
    .backgroundColor(0x33000000)
  }
}
```

This banner includes:

- Icon
- Title + Description
- Optional action button

------

## 4. Display & Animation Logic

To manage display and animation, we introduce two states:

```ts
@State isShow: boolean = false  // Toggle visibility
```

Use conditional rendering:

```ts
if (this.isShow) {
  Row(...) {
    ...
  }
  .transition({
    type: TransitionType.All,
    opacity: 1,
    translate: { x: 0, y: -this.mHeight }
  })
}
```

### Animation Trigger

We toggle `isShow` via `animateTo`, with entry and exit after delay:

```ts
onPageShow() {
  setTimeout(() => {
    this.toggleAnimation();
    setTimeout(() => {
      this.toggleAnimation();
    }, 3000);  // Visible for 3s
  }, 300);     // Delay start
}

toggleAnimation() {
  animateTo({ duration: 1000 }, () => {
    this.isShow = !this.isShow;
  });
}
```

------

## 5. Full Component Code

```ts
@Entry
@Preview
@Component
struct SubWindowNotice {
  @State isShow: boolean = false
  @State isRunning: boolean = false
  mHeight: number = vp(40)
  textValue: string = "textValue"

  build() {
    if (this.isShow) {
      Row({ space: vp(3) }) {
        Image($r("app.media.icon_default"))
          .autoResize(true)
          .margin({ top: vp(5), bottom: vp(5) })
          .width(vp(25))

        Column() {
          Text("Title")
          Text("This is a notification message")
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button("Close").fontSize("10fp")
      }
      .transition({
        type: TransitionType.All,
        opacity: 1,
        translate: { x: 0, y: -this.mHeight }
      })
      .height(this.mHeight)
      .padding({ left: vp(5), right: vp(5), bottom: vp(3), top: vp(3) })
      .border({ radius: vp(10) })
      .margin({ left: vp(5), right: vp(5) })
      .backgroundColor(0x33000000)
    }
  }

  onPageShow() {
    setTimeout(() => {
      this.toggleAnimation()
      setTimeout(() => {
        this.toggleAnimation()
      }, 3000)
    }, 300)
  }

  toggleAnimation() {
    animateTo({ duration: 1000 }, () => {
      this.isShow = !this.isShow
    })
  }
}
```

------

## 6. Conclusion

In a single-Ability HarmonyOS 5 Stage application, `SubWindow` provides a convenient way to overlay global notices across all pages.

This approach is well-suited for:

- In-app alerts
- Persistent banners
- Floating global widgets

Limitations:

- No public APIs for custom SubWindow animation (must be handled within page UI)
- `@Extend` cannot be used across files (a minor annoyance)

Still, this workaround delivers a robust, elegant notification UX suitable for business apps.

> Feedback, corrections, and ideas are always welcome. 