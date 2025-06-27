# HarmonyOS 5 Business App Tip — OTP Input Component

## 1. Introduction

In many business applications—such as login or payment flows—OTP (one-time password) or short passcode inputs are essential. When implementing an OTP input box in HarmonyOS 5, I encountered several tricky issues worth sharing.

This article walks through common obstacles, including incorrect approaches and best-practice solutions. Sections 2 and 3 show erroneous methods; if you only want the working solution, skip straight to section 4.

> Questions, feedback, bug reports, or better ideas are very welcome via comments, DMs, or email. Thank you for your support! 🙏

------

## 2. ForEach + TextInput

The first idea: replicate Android's multiple `EditText` method using HarmonyOS 5’s multiple `TextInput`. We created a reusable component:

```ts
@Component
struct CodeInputView {
  build() {
    TextInput()
      .backgroundColor("#CCFFFFFF")
      .borderRadius(10)
      .maxLength(1)
      .type(InputType.Number)
      .align(Alignment.Center)
  }
}
```

To handle multiple inputs, we used `ForEach` inside a `Row`:

```ts
@Preview
@Component
struct CodeInputView {
  @State codeKids: Array<string> = new Array(5).fill('')

  build() {
    Row({ space: 10 }) {
      ForEach(this.codeKids, (item: string, index: number) => {
        TextInput(this.codeKids[index])
          .backgroundColor("#CCFFFFFF")
          .borderRadius(10)
          .maxLength(1)
          .layoutWeight(1)
          .fontSize(25)
          .height("100%")
          .type(InputType.Number)
          .align(Alignment.Center)
      }, (item: string) => item)
    }
    .backgroundColor(Color.Black)
    .height(80)
  }
}
```

This displays N equal-sized OTP boxes. The preview shows the layout.

### Input + Focus Logic

Next, we added `onChange` to move focus automatically and collect the full OTP:

```ts
@Preview
@Component
struct CodeInputView {
  @State codeKids: Array<string> = new Array(5).fill('')
  inputResultCallback: (string) => void

  build() {
    Row({ space: vp(10) }) {
      ForEach(this.codeKids, (item: string, index: number) => {
        TextInput()
          .backgroundColor("#CCFFFFFF")
          .borderRadius(10)
          .maxLength(1)
          .layoutWeight(1)
          .fontSize(25)
          .height("100%")
          .type(InputType.Number)
          .align(Alignment.Center)
          .key(`code${index}`)
          .onChange((value) => {
            if (value.length <= 1) {
              this.codeKids[index] = value
            }
            if (index + 1 < this.codeKids.length) {
              focusControl.requestFocus(`code${index + 1}`)
            } else {
              this.inputResultCallback(this.codeKids.join(""))
            }
          })
      }, (item: string) => item)
    }
    .backgroundColor(Color.Black)
    .height(80)
  }
}
```

Key points:

- `inputResultCallback`: returns the OTP to the parent.
- `onChange`: stores value and auto-focuses the next box.
- `key()` is needed for `focusControl.requestFocus()`.

------

## 3. Odd Issues

### 3.1 Missing Initial Focus

On first render, no `TextInput` is focused. Fix by adding:

```ts
.defaultFocus(index == 0)
```

### 3.2 onChange Doesn’t Fire on Deletion

Surprisingly, deleting a character doesn’t trigger `onChange`. `onKeyEvent` wasn't reliable either:

```ts
.onKeyEvent((event) => {
  if (event.keyCode == KeyCode.KEYCODE_DEL) {}
})
```

So we had to look for alternatives.

### 3.3 Soft Keyboard Hides on Focus Switch

`focusControl.requestFocus(nextKey)` closes the soft keyboard. We found no clean workaround and suspect limitations in `TextInput`. Awaiting official fix.

------

## 4. Alternative: Single TextInput + Text Display

To avoid focus issues, we used a single hidden `TextInput` and multiple `Text` fields to display OTP:

```ts
@Preview
@Component
struct CodeInputView {
  @State codeKids: Array<string> = new Array(5).fill('')
  inputResultCallback: (string) => void

  build() {
    Stack() {
      Row({ space: vp(10) }) {
        ForEach(this.codeKids, (item: string, index: number) => {
          Text(item)
            .backgroundColor($r('app.color.white_80'))
            .height(match())
            .layoutWeight(1)
            .fontSize(fp(25))
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .borderRadius(vp(15))
            .focusable(false)
            .defaultFocus(false)
            .focusOnTouch(false)
        }, (item: string) => item)
      }
      .height(match())
      .width(match())

      TextInput()
        .maxLength(this.viewSize)
        .fontSize(fp(25))
        .borderRadius(vp(15))
        .type(InputType.Number)
        .key(this.inputKey)
        .onChange((value) => {
          let a = value.split('')
          this.codeKids.forEach((_, index) => {
            this.codeKids[index] = a[index] || ''
          })
          if (a.length >= this.viewSize) {
            this.inputResultCallback(value)
          }
          this.showCaret = (a.length == 0)
        })
        .copyOption(CopyOptions.None)
        .caretColor(this.showCaret ? Color.Black : Color.Transparent)
        .fontColor(Color.Transparent)
        .backgroundColor(Color.Transparent)
        .height(match())
        .width(match())
    }
    .height(vp(80))
  }
}
```

### Key Details

1. Transparent `TextInput` handles all input.
2. `Text` fields instantly reflect each character.
3. `caretColor` toggles visibility.
4. OTP completion triggers `inputResultCallback`.

Usage:

```ts
CodeInputView({ inputResultCallback: (code) => {
  // handle OTP code
}})
```

Preview of the effect shows a clean input experience.

------

## 5. Final Version

Below is the complete, configurable component:

```ts
@Preview
@Component
export struct CodeInputView {
  @State viewSize: number = 4
  inputResultCallback: (string) => void
  @Link codeKids: Array<string>
  @State showCaret: boolean = true
  private inputKey = "code_input"

  aboutToAppear() {
    if (this.codeKids == null) {
      this.codeKids = new Array(this.viewSize).fill('');
    }
  }

  build() {
    Stack() {
      if (this.codeKids != null) {
        Row({ space: vp(10) }) {
          ForEach(this.codeKids, (item: string, index: number) => {
            Text(item)
              .backgroundColor($r('app.color.white_80'))
              .height(match())
              .layoutWeight(1)
              .fontSize(fp(25))
              .textAlign(TextAlign.Center)
              .align(Alignment.Center)
              .borderRadius(vp(15))
              .focusable(false)
              .defaultFocus(false)
              .focusOnTouch(false)
              .onClick(() => {
                focusControl.requestFocus(this.inputKey)
              })
          }, (item: string) => item)
        }
        .height(match())
        .width(match())

        TextInput()
          .maxLength(this.viewSize)
          .fontSize(fp(25))
          .borderRadius(vp(15))
          .type(InputType.Number)
          .key(this.inputKey)
          .onChange((value) => {
            let a = value.split('')
            this.codeKids.forEach((_, idx) => {
              this.codeKids[idx] = a[idx] || ''
            })
            if (a.length >= this.viewSize) {
              this.inputResultCallback(value)
            }
            this.showCaret = (a.length == 0)
          })
          .copyOption(CopyOptions.None)
          .caretColor(this.showCaret ? Color.Black : Color.Transparent)
          .fontColor(Color.Transparent)
          .backgroundColor(Color.Transparent)
          // TODO: Pressed styles won’t work with transparent backgrounds
          .height(match())
          .width(match())
      }
    }
    .height(vp(80))
  }
}
```

------

## 6. Conclusion

That wraps up this OTP input component walkthrough. Feel free to suggest additional features or improvements in the comments.

HarmonyOS 5 ArkUI still lacks comprehensive documentation, and many patterns from Android don’t translate well. This blog aims to help navigate some of the quirks. Let’s adapt together! Amituofo. 