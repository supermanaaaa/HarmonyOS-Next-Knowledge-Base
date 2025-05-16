# Empowering Smart Classrooms: In-Depth Practice of HarmonyOS 5 Intelligent Voice Technology in Educational Applications

## Introduction
In the wave of digital education transformation, HarmonyOS 5 has opened up a new paradigm of intelligent interaction for educational software through its innovative distributed capabilities and AI technology stack. Taking the **K12 oral training scenario** as an entry point, this article deeply analyzes how to use the ArkUI framework and AI voice services to create smart education solutions with functions such as real-time speech evaluation and intelligent transcription of classroom content, achieving three major breakthroughs:

**▍ Technical Highlights**  
✅ Multimodal Interaction: Dual-channel input of voice and touch, supporting teaching scenarios such as classroom quick response and oral follow‑up  
✅ Educational‑Level Latency: 1.2‑second edge‑side speech recognition response to ensure smooth classroom interaction  
✅ Accessibility Support: Real‑time subtitle generation technology to assist in special education scenarios

**▍ Value in Educational Scenarios**  

- **Language Learning**: AI speech evaluation enables real‑time scoring of pronunciation accuracy  
- **Classroom Recording**: Automatically generates timestamped text of teaching content  
- **Homework Grading**: Quickly invokes question bank resources via voice commands

Build a real‑time speech‑to‑text function that supports long‑pressing a button to trigger recording and dynamically displays recognition results. Suitable for scenarios such as voice input and real‑time subtitles.

---

## Detailed Development Process

### 1. Environment Preparation
**System Requirements**: HarmonyOS 5 API 9+  
**Device Support**: Requires verification of device microphone hardware capabilities

```typescript
// Device capability detection
if (!canIUse('SystemCapability.AI.SpeechRecognizer')) {
  promptAction.showToast({ message: 'Device does not support speech recognition' })
}
```

### 2. Permission Configuration

**Step Description**:

1. Declare permissions: Add to `module.json5`:

```json
"requestPermissions": [
  {
    "name": "ohos.permission.MICROPHONE",
    "reason": "$string:microphone_permission_reason",
    "usedScene": {
      "abilities": ["EntryAbility"],
      "when": "always"
    }
  }
]
```

1. Dynamic permission request:

```typescript
private async requestPermissions() {
  const atManager = abilityAccessCtrl.createAtManager();
  try {
    const result = await atManager.requestPermissionsFromUser(
      getContext(),
      ['ohos.permission.MICROPHONE']
    );
    this.hasPermissions = result.authResults.every(
      status => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    );
  } catch (err) {
    console.error(`Permission request failed: ${err.code}, ${err.message}`);
  }
}
```

### 3. Speech Engine Management

**Lifecycle Control**:

```typescript
// Engine initialization
private async initEngine() {
  this.asrEngine = await speechRecognizer.createEngine({
    language: 'zh-CN',  // Supports multiple languages like en-US
    online: 1           // Online recognition mode
  });

  this.configureCallbacks();
}

// Resource release
private releaseEngine() {
  this.asrEngine?.finish('10000');
  this.asrEngine?.cancel('10000');
  this.asrEngine?.shutdown();
  this.asrEngine = undefined;
}
```

### 4. Core Configuration Parameters

**Audio Parameters**:

```typescript
const audioConfig: speechRecognizer.AudioInfo = {
  audioType: 'pcm',     // Recommended lossless format
  sampleRate: 16000,    // Standard speech sampling rate
  soundChannel: 1,      // Monophonic recording
  sampleBit: 16         // 16‑bit sampling depth
};
```

**Recognition Parameters**:

```typescript
const recognitionParams = {
  recognitionMode: 0,   // 0 – Streaming recognition, 1 – Single-sentence recognition
  vadBegin: 2000,       // Voice start detection threshold (ms)
  vadEnd: 3000,         // Voice end silence judgment
  maxAudioDuration: 60000 // Maximum recording time
};
```

### 5. Callback Event Handling

```typescript
private configureCallbacks() {
  const _this = this;

  this.asrEngine.setListener({
    onResult(sessionId, result) {
      _this.text = result.result;  // Incrementally update recognition results

      if (result.isLast) {
        _this.handleRecognitionEnd();
      }
    },

    onError(sessionId, code, msg) {
      promptAction.showToast({ message: `Recognition error: ${msg}` });
      _this.resetState();
    }
  });
}

private handleRecognitionEnd() {
  this.isRecording = false;
  this.releaseEngine();
  promptAction.showToast({ message: 'Recognition completed' });
}
```

------

## Complete Implementation Code

### View Component

```typescript
@Entry
@ComponentV2
struct SpeechRecognitionView {
  @State private displayText: string = '';
  @State private recordingStatus: boolean = false;
  private recognitionEngine?: speechRecognizer.SpeechRecognitionEngine;

  build() {
    Column() {
      // Result display area
      Scroll() {
        Text(this.displayText)
          .fontSize(18)
          .textAlign(TextAlign.Start)
      }
      .layoutWeight(1)
      .padding(12)

      // Voice control button
      VoiceButton({
        recording: this.recordingStatus,
        onStart: () => this.startRecognition(),
        onEnd: () => this.stopRecognition()
      })
    }
    .height('100%')
    .backgroundColor(Color.White)
  }
}
```

### Custom Voice Button Component

```typescript
@ComponentV2
struct VoiceButton {
  @Link recording: boolean;
  onStart: () => void;
  onEnd: () => void;

  build() {
    Button(this.recording ? 'Release to End' : 'Long Press to Speak')
      .size({ width: '80%', height: 80 })
      .backgroundColor(this.recording ? '#FF6B81' : '#3498DB')
      .gesture(
        LongPressGesture()
          .onActionStart(() => {
            this.onStart();
            this.recording = true;
          })
          .onActionEnd(() => {
            this.onEnd();
            this.recording = false;
          })
      )
  }
}
```

------

## Best Practice Recommendations

### Performance Optimization

1. **Resource Management**: Ensure engine release when components are unloaded

   ```typescript
   aboutToDisappear(): void {
     this.releaseEngine();
   }
   ```

2. **Throttling Processing**: Avoid frequent state updates

   ```typescript
   private updateText(newText: string) {
     if (Date.now() - this.lastUpdate > 200) {
       this.displayText = newText;
       this.lastUpdate = Date.now();
     }
   }
   ```

### User Experience Enhancement

1. **Add audio waveform animation**:

   ```typescript
   // Add dynamic effects to the button
   @Builder
   WaveEffect() {
     Circle()
       .width(this.recording ? 30 : 0)
       .height(this.recording ? 30 : 0)
       .opacity(0.5)
       .animate({ duration: 1000, iterations: -1 })
   }
   ```

2. **Error recovery mechanism**:

   ```typescript
   private async retryRecording() {
     await this.releaseEngine();
     await new Promise(resolve => setTimeout(resolve, 500));
     await this.initEngine();
     this.startRecognition();
   }
   ```

------

## Technical Key Points Summary

| Module                       | Key Technical Points                                         |
| ---------------------------- | ------------------------------------------------------------ |
| **Permission Management**    | Dynamic permission request mechanism + exception fallback handling |
| **Audio Processing**         | PCM audio stream configuration + VAD silence detection parameter optimization |
| **State Management**         | UI and logic state synchronization via @State/@Link          |
| **Performance Optimization** | Engine lifecycle management + throttling update strategy     |
| **Exception Handling**       | Error code mapping table + automatic retry mechanism         |

Through this case, developers can master the core development model of HarmonyOS 5 voice services and quickly build high‑quality voice interaction functions.
