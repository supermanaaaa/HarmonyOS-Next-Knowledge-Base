# HarmonyOS 5 Building a Draggable Floating View Component in Your Application

## Introduction

In HarmonyOS development, implementing a floating draggable UI component (DragView) can greatly improve user experience. This is particularly useful for creating floating entries, quick access widgets, or contextual helpers. This article introduces a reusable DragView component that supports smooth dragging, edge constraint, magnetic snapping, and customizable initial alignment.

## Design Concept

HarmonyOS provides built-in gesture support, such as `PanGesture`, which makes it straightforward to implement draggable interactions. The idea is simple:

- Track drag offset using `PanGesture`.
- Dynamically update the UI's `.position()` with the calculated offset.
- After the drag ends, trigger a smooth snapping animation (`animateTo`) to snap the view to the nearest edge or position.

## DragView Container

We start by defining the `DragView` component using `.position(this.curPosition)` to place it on the screen, and accept a builder function `dragContentBuilder` to support flexible content injection.

```ts
@State private curPosition: Position = { x: 0, y: 0 };

build() {
  Stack() {
    if (this.dragContentBuilder) {
      this.dragContentBuilder()
    } else {
      this.defDragView()
    }
  }
  .position(this.curPosition)
  .onClick(this.onClickListener)
}
```

## Edge Constraints

To ensure the drag stays within a desired area, we define a `BoundArea` object to encapsulate the bounding logic.

```ts
export class BoundArea {
  constructor(start: number, top: number, end: number, bottom: number) {
    this.start = start
    this.top = top
    this.end = end
    this.bottom = bottom
    this.width = end - start
    this.height = bottom - top
    this.centerX = this.width / 2 + start
    this.centerY = this.height / 2 + top
  }
  // ... other fields
}
```

By default, the bounding area is set to the full screen.

## Measuring View Dimensions

Since the DragView content is dynamic, we calculate its width and height using `.onAreaChange`.

```ts
.onAreaChange((oldValue: Area, newValue: Area) => {
  if (newValue.width && newValue.height) {
    this.dragWidth = newValue.width
    this.dragHeight = newValue.height
  }
})
```

## Implementing Drag Interaction

We use `PanGesture` with `PanDirection.All` to allow free dragging in all directions.

```ts
PanGesture({ direction: PanDirection.All })
  .onActionStart(event => this.changePosition(event.offsetX, event.offsetY))
  .onActionUpdate(event => this.changePosition(event.offsetX, event.offsetY))
  .onActionEnd(() => this.adsorbToEnd(this.curPosition.x, this.curPosition.y))
```

The actual dragging logic applies clamping to keep the view within bounds:

```ts
private changePosition(offsetX: number, offsetY: number) {
  let targetX = clamp(this.endPosition.x + offsetX, this.boundArea.start, this.boundArea.end - this.dragHeight);
  let targetY = clamp(this.endPosition.y + offsetY, this.boundArea.top, this.boundArea.bottom - this.dragWidth);
  this.curPosition = { x: targetX, y: targetY };
}
```

## Magnetic Snapping Animation

After the drag ends, the component snaps to the closest horizontal edge and clamps vertically within bounds:

```ts
private adsorbToEnd(startX: number, startY: number) {
  let targetX = (startX <= this.boundArea.centerX)
    ? this.boundArea.start + this.dragMargin.left
    : this.boundArea.end - this.dragWidth - this.dragMargin.right;

  let targetY = clamp(
    startY,
    this.boundArea.top + this.dragMargin.top,
    this.boundArea.bottom - this.dragWidth - this.dragMargin.bottom
  );

  this.startMoveAnimateTo(targetX, targetY);
}
```

## Customizing Initial Alignment

To improve usability, we allow customizing the initial position using `dragAlign` and `dragMargin`:

```ts
dragAlign: Alignment = Alignment.BottomStart;
dragMargin: Margin = {};
```

The position is calculated once after the component's dimensions are known:

```ts
private initAlign() {
  switch (this.dragAlign) {
    case Alignment.BottomEnd:
      this.curPosition = {
        x: this.boundArea.end - this.dragWidth - this.dragMargin.right,
        y: this.boundArea.bottom - this.dragHeight - this.dragMargin.bottom
      };
      break;
    // ... other alignments
  }
  this.endPosition = this.curPosition;
}
```

## Example Usage

A simple usage example:

```ts
DragView({
  dragAlign: Alignment.Center,
  dragMargin: bothway(10),
  dragContentBuilder: this.defDragView()
})

@Builder
defDragView() {
  Stack() {
    Text("Drag Me")
      .width(50).height(50)
      .fontSize(15)
  }
  .shadow({ radius: 1.5, color: "#80000000", offsetX: 0, offsetY: 1 })
  .padding(18)
  .borderRadius(30)
  .backgroundColor(Color.White)
  .animation({ duration: 200, curve: Curve.Smooth })
}
```

## Conclusion

With this DragView component, you can easily implement reusable floating views inside HarmonyOS applications. It supports customizable boundaries, snapping logic, initial placement, and dynamic UI content.

If you're building a system-wide floating assistant or cross-page notice, consider combining this approach with `SubWindow`, as discussed in the [in-app notice article](https://juejin.cn/post/7329141961092284468).