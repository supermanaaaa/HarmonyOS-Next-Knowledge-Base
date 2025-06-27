# Hidden Gems in HarmonyOS 5 for Business App Development — Graphic Transformations

## 1. Introduction

During the development of business applications with HarmonyOS 5, we often encounter subtle yet powerful features buried within the framework. These transformations—such as rotation, translation, and scaling—can significantly enhance UI interactions and animations when used appropriately.

This article aims to explore these transformation capabilities in a concise, developer-oriented way, helping you better understand how to create smooth and dynamic user experiences in your HarmonyOS-based applications.

> If you have questions, suggestions, spot any issues, or have a better solution, feel free to leave a comment or reach out via direct message or email. Thank you for your support. 🙏

------

## 2. Translate

The `translate` transformation primarily involves the following parameters:

- `x`: Distance to move along the horizontal axis
- `y`: Distance to move along the vertical axis
- `z`: Distance to move along the depth axis (3D)

In a 2D translation, adjusting `x` and `y` allows you to move an element across the plane.

### About the `z` Axis:

When `z` tends toward negative infinity, the component appears to shrink. Once `z` goes below `-250`, the object actually enlarges and flips.

This is likely due to a **viewpoint** positioned around `z = -250`. The closer a component gets to the viewpoint, the larger it appears—further away, the smaller it looks.

------

## 3. Rotate

Compared to translation, rotation comes with more parameters—angle, axis of rotation, transformation center, and perspective depth:

| Name        | Type          | Description                                                  |
| ----------- | ------------- | ------------------------------------------------------------ |
| x           | number        | X coordinate of the rotation axis vector                     |
| y           | number        | Y coordinate of the rotation axis vector                     |
| z           | number        | Z coordinate of the rotation axis vector                     |
| angle       | number/string | Rotation angle (positive = clockwise, negative = counterclockwise). Can use values like `'90deg'`. |
| centerX     | number/string | X coordinate of the rotation center                          |
| centerY     | number/string | Y coordinate of the rotation center                          |
| centerZ     | number        | Z coordinate of the 3D rotation center                       |
| perspective | number        | Distance from the viewpoint to the z=0 plane                 |

The `x`, `y`, and `z` values define the rotation axis. The `angle` determines how much to rotate, and other parameters define the center and visual depth of the rotation.

------

### 3.1 Rotate Around Z Axis (Center Rotation)

```json
{
  "x": 0,
  "y": 0,
  "z": 1,
  "angle": 45,
  "centerX": "50%",
  "centerY": "50%"
}
```

------

### 3.2 Rotate Around Y Axis (Left-Right Flip)

```json
{
  "x": 0,
  "y": 1,
  "z": 0,
  "angle": 45,
  "centerX": "50%",
  "centerY": "50%"
}
```

------

### 3.3 Rotate Around X Axis (Top-Bottom Flip)

```json
{
  "x": 1,
  "y": 0,
  "z": 0,
  "angle": 45,
  "centerX": "50%",
  "centerY": "50%"
}
```

------

### 3.4 centerX / centerY / centerZ (Rotation Anchor)

By default, rotation is performed around the center of the shape. You can customize the pivot point by modifying `centerX`, `centerY`, and `centerZ`, making the effect more flexible and tailored to UI needs.

------

### 3.5 perspective (Depth Perception)

- **Without perspective** (`perspective = 0`): The rotation looks flat with no depth variation—like spinning a card on a table.
- **With perspective** (`perspective > 0`): Adds a 3D effect where the object appears larger when closer and smaller when further away.

This mimics real-world depth—imagine a straight road that narrows as it vanishes into the distance.

> In practice, the effect may not always be visually striking, especially for small rotations or components.

------

## 4. Scale

| Name    | Type          | Description                                                  |
| ------- | ------------- | ------------------------------------------------------------ |
| x       | number        | Scale factor along the X-axis. `x > 1` enlarges, `0 < x < 1` shrinks, `x < 0` flips and scales. |
| y       | number        | Same as above, for the Y-axis                                |
| z       | number        | Same as above, for the Z-axis                                |
| centerX | number/string | X coordinate of the scaling center                           |
| centerY | number/string | Y coordinate of the scaling center                           |

> In 2D views, scaling along the Z axis often has no direct visual effect.

------

## 5. Coming Up Next

In the next article, we plan to explore **matrix transformations**—stay tuned!

------

## 6. Conclusion

That’s it for now.

If you have any questions, feedback, corrections, or alternative approaches, please feel free to comment, message, or email. Your input is greatly appreciated. 