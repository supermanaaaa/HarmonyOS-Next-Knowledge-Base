# HarmonyOS 5 Educational Scenario Practice: Building an Intelligent Text Reading System with AI Speech Technology

## Preface: When HarmonyOS Meets Smart Education

In the booming era of digital education, HarmonyOS 5 is reshaping the development paradigm of educational applications with its powerful distributed capabilities and AI technology stack. The three core capabilities brought by this upgrade inject new momentum into the education sector:

1. **Distributed AI**: Seamless collaboration across devices.
2. **AI Speech**: High‑quality, low‑latency text‑to‑speech (TTS).
3. **ArkUI**: Declarative UI for rapid, maintainable interfaces.

------

## I. Case Overview

### 1. Scenario Value

This case uses HarmonyOS’s AI speech capabilities to transform literary text into expressive voice broadcasts, applicable to:

- **Accessible reading**: Helping visually impaired users enjoy the beauty of literature
- **Multimodal experience**: Adding an auditory dimension to traditional reading
- **Content consumption**: Enabling an “audiobook”‑style consumption mode

### 2. Effect Preview

## II. Implementation Analysis

### 1. Capability Integration

```typescript
// Core speech capability module
import { textToSpeech } from '@kit.CoreSpeechKit';
// UI interaction components
import { promptAction } from '@kit.ArkUI';
```

- **`textToSpeech`**: Provides intelligent TTS, supporting multiple languages and voices.
- **`promptAction`**: Enables lightweight user feedback to ensure smooth interaction.

------

### 2. Component Architecture

```typescript
@Entry
@ComponentV2
struct ArticlePlayer {
  // Literary content (optimized for long-text typesetting)
  private readonly literaryContent: string = `
    [Original text content preserved here]
  `;

  // TTS engine instance
  private ttsEngine?: textToSpeech.TextToSpeechEngine;

  // Playback status management
  @Local isPlaying: boolean = false;

  // Lifecycle management
  aboutToAppear(): void {
    this.initializeTTS();
  }

  aboutToDisappear(): void {
    this.releaseResources();
  }
}
```

- **State isolation**: Component‑level state via `@Local`.
- **Resource control**: Engine management tied to lifecycle events.
- **Type safety**: TypeScript annotations enhance robustness.

------

### 3. Speech Engine Management

```typescript
private async initializeTTS() {
  if (!canIUse('SystemCapability.AI.TextToSpeech')) {
    promptAction.showToast({ message: 'TTS not supported on this device' });
    return;
  }

  try {
    this.ttsEngine = await textToSpeech.createEngine({
      language: 'zh-CN',   // Mandarin Chinese
      person: 0,           // Default speaker
      online: 1            // Cloud-enhanced
    });

    this.ttsEngine.on('play', () => this.handlePlaybackStatus(true));
    this.ttsEngine.on('finish', () => this.handlePlaybackStatus(false));
  } catch (error) {
    console.error(`TTS init failed: ${error.code} ${error.message}`);
  }
}

private releaseResources() {
  this.ttsEngine?.stop();
  this.ttsEngine?.shutdown();
  this.ttsEngine = undefined;
}
```

- **Compatibility checks** and error handling
- **Observer pattern** for playback status
- **Explicit cleanup** to avoid leaks

------

### 4. Playback Control Logic

```typescript
private handlePlaybackStatus(playing: boolean) {
  this.isPlaying = playing;
  if (!playing) {
    promptAction.showToast({ message: 'Playback completed', duration: 1500 });
  }
}

play() {
  if (!this.ttsEngine) return;

  if (this.ttsEngine.isBusy()) {
    promptAction.showToast({ message: 'Processing audio request...' });
    return;
  }

  this.ttsEngine.speak(this.literaryContent, {
    requestId: Date.now().toString(),  // Unique identifier
    speed: 1.0,                        // Playback speed
    volume: 0.8                        // Output volume
  });
}
```

- **Unique request IDs** via timestamp
- **Configurable parameters** for speed and volume
- **User feedback** on completion or processing

------

### 5. Interface Design

```typescript
build() {
  Stack({ alignContent: Alignment.BottomEnd }) {
    // Content display area
    Scroll() {
      Text(this.literaryContent)
        .fontSize(16)
        .lineHeight(24)
        .textAlign(TextAlign.Start)
    }
    .padding(20)
    .width('100%')

    // Floating control console
    FloatingController({
      isPlaying: this.isPlaying,
      onPlay: () => this.play()
    })
  }
}
@ComponentV2
struct FloatingController {
  @Param isPlaying: boolean = false;
  @Param onPlay: () => void = () => {};

  build() {
    Column() {
      Image($r(this.isPlaying ? 'sys.media.AI_pause' : 'sys.media.AI_play'))
        .size({ width: 48, height: 48 })
        .onClick(() => this.onPlay())
    }
    .shadow(ShadowStyle.MEDIUM)
    .margin({ right: 40, bottom: 40 })
  }
}
```

- **Decoupled components** for reusability
- **Adaptive layout** for various screen sizes
- **Visual hierarchy** using shadow effects

------

## III. Technical Accumulation

### 1. Best Practices

- **Performance Optimization**

  - Preload TTS engine on initialization
  - Lazy‑load large text segments
  - Timely resource release

- **Exception Handling**

  ```typescript
  try {
    await this.ttsEngine.speak(content);
  } catch (error) {
    if (error.code === 1001) {
      promptAction.showToast({ message: 'Network error, please check your connection' });
    }
    // Additional error codes...
  }
  ```

- **Experience Enhancements**

  - Support for interruption (stop calls)
  - Progress indicators
  - Variable speed controls

### 2. Extension Directions

- Multi‑voice switching
- Real‑time subtitle synchronization
- Background music mixing
- Offline speech package support

------

## IV. Complete Implementation

This full example emphasizes:

1. **Maintainability**: Clear component splits and type declarations.
2. **User Experience**: Status feedback, exception handling.
3. **Extensibility**: Parameterized interfaces for future features.
4. **Readability**: Business value descriptions alongside technical details.

### Full Code

```typescript
import { textToSpeech } from '@kit.CoreSpeechKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@ComponentV2
struct CoreSpeechKit {
  text: string = `
    At 45 degrees north latitude in March...
    [Full literary text here]
  `;
  ttsEngine?: textToSpeech.TextToSpeechEngine;

  @Local isPlaying: boolean = false;

  async initTextToSpeechEngine() {
    if (canIUse('SystemCapability.AI.TextToSpeech')) {
      this.ttsEngine = await textToSpeech.createEngine({
        language: 'zh-CN',
        person: 0,
        online: 1
      });
    }
  }

  aboutToAppear(): void {
    this.initTextToSpeechEngine();
  }

  aboutToDisappear(): void {
    if (canIUse('SystemCapability.AI.TextToSpeech')) {
      this.ttsEngine?.stop();
      this.ttsEngine?.shutdown();
    }
  }

  play() {
    if (canIUse('SystemCapability.AI.TextToSpeech')) {
      if (this.ttsEngine?.isBusy()) {
        return promptAction.showToast({ message: 'Now broadcasting...' });
      }
      this.ttsEngine?.speak(this.text, { requestId: '10000' });
      this.isPlaying = true;
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      List() {
        ListItem() {
          Text(this.text).lineHeight(32);
        }
      }
      .padding({ left: 15, right: 15 })
      .height('100%')
      .width('100%')

      Row() {
        Image(this.isPlaying ? $r('sys.media.AI_playing') : $r('sys.media.AI_play'))
          .width(24)
          .onClick(() => this.play())
      }
      .borderRadius(24)
      .shadow({ color: Color.Gray, offsetX: 5, offsetY: 5, radius: 15 })
      .width(48)
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 50, bottom: 50 })
    }
    .height('100%')
    .width('100%')
  }
}
```
