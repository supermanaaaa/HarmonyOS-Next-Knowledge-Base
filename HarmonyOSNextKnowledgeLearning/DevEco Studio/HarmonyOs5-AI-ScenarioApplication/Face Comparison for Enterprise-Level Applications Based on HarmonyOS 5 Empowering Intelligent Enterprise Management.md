# Face Comparison for Enterprise-Level Applications Based on HarmonyOS 5: Empowering Intelligent Enterprise Management

## I. Case Value and Effect
This case implements cross-device facial feature comparison based on HarmonyOS 5’s AI basic vision capabilities. Users can select two facial photos from the album, and the system automatically extracts facial features and calculates similarity—applicable to scenarios such as identity verification and intelligent album classification.

**Core Function Highlights**  
- Asynchronous dual-image selection mechanism  
- Real-time facial feature vector comparison  
- Visual similarity percentage display  
- Cross-device compatibility handling

---

## II. Detailed Development Implementation

### 1. Environment Preparation
#### Permission Configuration  
Add necessary permissions in `module.json5`:
```json
"requestPermissions": [
  {
    "name": "ohos.permission.READ_IMAGEVIDEO"
  }
]
```

### 2. Module Dependency Description

```typescript
import { photoAccessHelper } from '@kit.MediaLibraryKit';  // Media library access
import { fileIo } from '@kit.CoreFileKit';                // File operations
import { image } from '@kit.ImageKit';                    // Image processing
import { faceComparator } from '@kit.CoreVisionKit';      // Core AI vision
import { promptAction } from '@kit.ArkUI';                // UI interactions
import { BusinessError } from '@kit.BasicServicesKit';    // Exception handling
```

### 3. Dual-Image Selection Implementation

#### Optimized Image Picker

```typescript
private async selectImage(): Promise<PixelMap> {
  try {
    const picker = new photoAccessHelper.PhotoViewPicker();
    const { photoUris } = await picker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1
    });

    const file = await fileIo.open(photoUris[0], fileIo.OpenMode.READ_ONLY);
    const imageSource = image.createImageSource(file.fd);
    return await imageSource.createPixelMap({
      desiredSize: { width: 512, height: 512 } // Optimize memory usage
    });
  } catch (error) {
    promptAction.showToast({ message: `Selection failed: ${error.message}` });
    throw error;
  }
}
```

### 4. Core Face Comparison Logic

#### Feature Comparison Implementation

```typescript
private async compareFaces() {
  if (!this.chooseImage1 || !this.chooseImage2) return;

  const config: faceComparator.VisionInfo[] = [
    { pixelMap: this.chooseImage1 },
    { pixelMap: this.chooseImage2 }
  ];

  try {
    const { similarity, isSamePerson } = await faceComparator.compareFaces(...config);
    this.showResult(similarity, isSamePerson);
  } catch (e) {
    this.handleError(e as BusinessError);
  }
}

private showResult(similarity: number, isSame: boolean) {
  promptAction.showDialog({
    title: 'Comparison Result',
    message: `Similarity: ${(similarity * 100).toFixed(1)}%\n${isSame ? 'Same Person' : 'Different Persons'}`,
    buttons: [{ text: 'OK' }]
  });
}

private handleError(error: BusinessError) {
  const errorMap = {
    1001: 'Face detection failed',
    1002: 'Feature extraction error',
    1003: 'Device does not support AI acceleration'
  };
  promptAction.showToast({
    message: errorMap[error.code] || `Error code: ${error.code}`
  });
}
```

------

## III. UI Component Implementation

### Interactive Interface Design

```typescript
@Entry
@ComponentV2
struct FaceComparator {
  @Local chooseImage1?: PixelMap
  @Local chooseImage2?: PixelMap

  build() {
    Column({ space: 20 }) {
      // Image selection area
      GridRow({ columns: 2 }) {
        GridCol() {
          ImageBox("First Image", this.chooseImage1, () => this.selectImage(1))
        }
        GridCol() {
          ImageBox("Second Image", this.chooseImage2, () => this.selectImage(2))
        }
      }
      .height('40%')

      // Action button
      Button('Start Comparison', { type: ButtonType.Capsule })
        .width('80%')
        .onClick(() => this.compareFaces())
    }
    .padding(15)
  }
}

@Builder
function ImageBox(label: string, image: PixelMap, handler: () => void) {
  Column() {
    if (image) {
      Image(image)
        .aspectRatio(1)
    } else {
      Image($r('app.media.placeholder'))
    }
    Text(label)
  }
  .onClick(handler)
}
```

------

## IV. Key Technologies and Considerations

### 1. Performance Optimization Strategies

- **Image preprocessing**: Resize to 512 px to reduce memory usage
- **Asynchronous loading**: Prevent UI thread blocking
- **Resource release**: Call `release()` to free `PixelMap` when the page is destroyed

### 2. Accuracy Enhancement Techniques

```typescript
// Recommended threshold configuration
const THRESHOLD = 0.75;

function isSamePerson(similarity: number) {
  return similarity > THRESHOLD;
}
```

### 3. Common Issue Handling

| Error Code | Cause Analysis       | Solution                              |
| ---------- | -------------------- | ------------------------------------- |
| 1001       | Face not detected    | Ensure full frontal face in the image |
| 1002       | Low image quality    | Use images with clarity ≥ 720 p       |
| 1003       | Device not supported | Verify system version ≥ 4.0           |

------

## V. Complete Implementation Code

```typescript
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { faceComparator } from '@kit.CoreVisionKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@ComponentV2
struct FaceComparator {
  @Local chooseImage1?: PixelMap
  @Local chooseImage2?: PixelMap

  async chooseImage(): Promise<PixelMap> {
    const picker = new photoAccessHelper.PhotoViewPicker();
    const result = await picker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1
    });
    const uri = result.photoUris[0];

    const fileSource = await fileIo.open(uri, fileIo.OpenMode.READ_ONLY);
    const imageSource = image.createImageSource(fileSource.fd);
    const pixelMap = await imageSource.createPixelMap();
    fileIo.close(fileSource);
    return pixelMap;
  }

  build() {
    Column({ space: 20 }) {
      Image(this.chooseImage1)
        .alt($r('sys.media.save_button_picture'))
        .width(200)
        .aspectRatio(1)
        .onClick(async () => {
          this.chooseImage1 = await this.chooseImage();
        })
      Image(this.chooseImage2)
        .alt($r('sys.media.save_button_picture'))
        .width(200)
        .aspectRatio(1)
        .onClick(async () => {
          this.chooseImage2 = await this.chooseImage();
        })
      Button('Face Comparison')
        .id('FaceComparatorButton')
        .onClick(async () => {
          if (this.chooseImage1 && this.chooseImage2) {
            try {
              const result = await faceComparator.compareFaces(
                { pixelMap: this.chooseImage1 },
                { pixelMap: this.chooseImage2 }
              );
              promptAction.showDialog({ message: JSON.stringify(result) });
            } catch (e: any) {
              promptAction.showToast({ message: (e as BusinessError).message });
            }
          }
        })
    }
    .padding(15)
    .height('100%')
    .width('100%')
  }
}
```

------

## VI. Extended Application Directions

1. **Liveness Detection Enhancement**: Integrate blink detection to improve security
2. **Multi-Face Processing**: Implement multi-face comparison via `faceDetection`
3. **Cloud Collaboration**: Upload feature vectors to the cloud for large-scale retrieval

**Technology Evolution Roadmap**

```mermaid
graph LR
  A[Local Single-Image Detection] --> B[Local Dual-Image Comparison]
  B --> C[Cloud Feature Library Retrieval]
  C --> D[Dynamic Video Stream Analysis]
```

Through this case, developers can quickly master HarmonyOS AI vision services and extend functionality based on specific business needs. For production, add loading indicators and result caching to enhance user experience.
