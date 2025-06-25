# HarmonyOS 5 Demo Example of Bidirectional Communication between HarmonyOS Web Components and Embedded Web Pages

## I. Preface

In ArkUI development, the Web component (Web) allows developers to embed web pages within an application, enabling hybrid development scenarios.
 This article will elaborate on how to achieve bidirectional communication between ArkUI and embedded web pages through a complete demo, covering core technical points such as ArkUI calling web JS and web pages calling ArkUI objects via WebviewController.

## II. Principles of Bidirectional Communication Implementation

### 1. Concept of Bidirectional Communication

- **Web to ArkUI (reverse communication)**: Register the ArkUI object to the window object of the web page through `registerJavaScriptProxy`, allowing the web page to call the methods exposed by ArkUI via `window.xxx`.
- **ArkUI to Web (forward communication)**: Execute web JS code through `runJavaScript`, supporting callbacks to obtain return values and enabling native code to call web functions.

### 2. Flowchart of Bidirectional Communication

ArkUI Web
 ┌──────────────┐ ┌──────────────┐
 │ registerJS ├─────────────▶ window.objName │
 │ (Reverse Registration) │ ├──────────────┤
 ├──────────────┤ │ call test() │
 │ runJavaScript├─────────────▶ execute JS code │
 │ (Forward Call) │ ├──────────────┤
 └──────────────┘ └──────────────┘

## III. Steps to Implement Bidirectional Communication

### 1. ArkUI Defines Objects Callable by Web Pages

Create a `TestObj` class and declare methods allowed to be called by web pages (whitelist mechanism):

```typescript
class TestObj {
  // Method 1 callable by web pages: returns a string
  test(): string {
    return "ArkUI Web Component";
  }

  // Method 2 callable by web pages: prints logs
  toString(): void {
    console.log('Web Component toString');
  }

  // Method 3 callable by web pages: receives messages from web pages
  receiveMessageFromWeb(message: string): void {
    console.log(`Received from web: ${message}`);
  }
}
```

### 2. Core Code of ArkUI Components

Initialize the controller and state:

```typescript
@Entry
@Component
struct WebComponent {
  // Webview controller
  controller: webview.WebviewController = new webview.WebviewController();
  // ArkUI object registered to the web page
  @State testObj: TestObj = new TestObj();
  // Registration name (web page accesses via window.[name])
  @State regName: string = 'objName';
  // Receives data returned by the web page
  @State webResult: string = '';

  build() { /* Component layout and interaction logic */ }
}
```

Layout and interaction buttons, adding three core function buttons:

```typescript
Column() {
  // Displays data returned by the web page
  Text(`Web Returned Data: ${this.webResult}`).fontSize(16).margin(10);

  // 1. Register the ArkUI object to the web page
  Button('Register to Window')
    .onClick(() => {
      this.controller.registerJavaScriptProxy(
        this.testObj,  // ArkUI object
        this.regName,  // Web page access name
        ["test", "toString", "receiveMessageFromWeb"]  // Whitelist of allowed methods
      );
    })

  // 2. ArkUI calls web JS
  Button('Call Web Function')
    .onClick(() => {
      this.controller.runJavaScript(
        'webFunction("Hello from ArkUI!")',  // Execute web JS code
        (error, result) => {  // Callback to process return value
          if (!error) this.webResult = result || 'No return value';
        }
      );
    })

  // 3. Web component loading
  Web({ src: $rawfile('index.html'), controller: this.controller })
    .javaScriptAccess(true)  // Enable JS interaction permission
    .onPageEnd(() => {  // Triggered when page loading is complete
      // Automatically call the web test function after page loading
      this.controller.runJavaScript('initWebData()');
    })
}
```

### 3. The actual role of `registerJavaScriptProxy` is to bind the ArkUI object to the web page window, achieving reverse communication.

```typescript
registerJavaScriptProxy(
  obj: Object,        // Object defined in ArkUI
  name: string,       // Name for web page access (e.g., window.name)
  methods: string[]   // Whitelist of allowed methods (strictly matches method names)
);
```

## Source Code Example

The complete code has been uploaded to the Gitee repository. Welcome to download and debug! If you have any questions, feel free to leave a message in the comment section for communication~

### Project Structure

├── xxx.ets # ArkUI component code
 └── index.html # Embedded web page file
 ![Insert image description here](https://chatgpt.com/img/remote/1460000046526091)

### WebViewPage.ets

```typescript
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

class TestObj {
  constructor() {
  }

  test(): string {
    return "ArkUI Web Component";
  }

  toString(): void {
    console.log('Web Component toString');
  }

  receiveMessageFromWeb(message: string): void {
    console.log(`Received message from web: ${message}`);
  }
}

@Entry
@Component
struct WebViewPage {
  controller: webview.WebviewController = new webview.WebviewController();
  @State testObjtest: TestObj = new TestObj();
  @State name: string = 'objName';
  @State webResult: string = '';

  build() {
    Column() {
      Text(this.webResult).fontSize(20)
      Button('refresh')
        .onClick(() => {
          try {
            this.controller.refresh();
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Button('Register JavaScript To Window')
        .onClick(() => {
          try {
            this.controller.registerJavaScriptProxy(this.testObjtest, this.name, ["test", "toString", "receiveMessageFromWeb"]);
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Button('deleteJavaScriptRegister')
        .onClick(() => {
          try {
            this.controller.deleteJavaScriptRegister(this.name);
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Button('Send message to web')
        .onClick(() => {
          try {
            this.controller.runJavaScript(
              'receiveMessageFromArkUI("Hello from ArkUI!")',
              (error, result) => {
                if (error) {
                  console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
                  return;
                }
                console.info(`Message sent to web result: ${result}`);
              }
            );
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Button('Get data from web')
        .onClick(() => {
          try {
            this.controller.runJavaScript(
              'getWebPageData()',
              (error, result) => {
                if (error) {
                  console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
                  return;
                }
                if (result) {
                  this.webResult = result;
                  console.info(`Data from web: ${result}`);
                }
              }
            );
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      Web({ src: $rawfile('index.html'), controller: this.controller })
        .javaScriptAccess(true)
        .onPageEnd(e => {
          try {
            this.controller.runJavaScript(
              'test()',
              (error, result) => {
                if (error) {
                  console.error(`run JavaScript error, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
                  return;
                }
                if (result) {
                  this.webResult = result;
                  console.info(`The test() return value is: ${result}`);
                }
              }
            );
            if (e) {
              console.info('url: ', e.url);
            }
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
        .width("100%")
        .height("50%")
    }
    .width("100%")
    .height("100%")
    .backgroundColor(Color.Black)
  }
}
```

### index.html

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Communication</title>
</head>

<body>
<button onclick="callArkUIMethod()">Call ArkUI Method</button>
<button onclick="sendMessageToArkUI()">Send message to ArkUI</button>
<div id="messageFromArkUI"></div>
<script>
    function callArkUIMethod() {
        const result = window.objName.test();
        console.log("Result from ArkUI: ", result);
    }

    function sendMessageToArkUI() {
        window.objName.receiveMessageFromWeb('Hello from web!');
    }

    function receiveMessageFromArkUI(message) {
        const messageDiv = document.getElementById('messageFromArkUI');
        messageDiv.textContent = `Received message from ArkUI: ${message}`;
    }

    function getWebPageData() {
        return "Data from web page";
    }

    function test() {
        return "Test function result from web";
    }
</script>
</body>

</html>
```

## Notes

Call `deleteJavaScriptRegister(name)` when the component is destroyed to cancel registration and avoid memory leaks:

```typescript
onDestroy() {
  this.controller.deleteJavaScriptRegister(this.regName);
}
```