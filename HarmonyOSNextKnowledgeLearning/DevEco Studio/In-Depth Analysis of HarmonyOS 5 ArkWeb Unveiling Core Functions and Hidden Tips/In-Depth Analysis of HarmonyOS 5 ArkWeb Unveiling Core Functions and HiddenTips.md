# In-Depth Analysis of HarmonyOS 5 ArkWeb: Unveiling Core Functions and Hidden Tips

---

### I. Introduction: The Core Role of HarmonyOS 5 ArkWeb

In the HarmonyOS 5 ecosystem, ArkWeb serves as a key component for H5 page rendering and hybrid development. Although official documentation elaborates on basic functions, many advanced features and performance optimization techniques remain "under the iceberg." This article deeply dissects the core functionalities of ArkWeb and, combined with practical experience, reveals hidden tips not explicitly mentioned in official documents.

---

### II. Analysis of Core Functions

1. **Web Page Loading**
   ArkWeb can not only load remote or local web pages but also seamlessly integrate with native H5 features for hybrid development. In Abilities, ArkWeb can replace the RichText component to load rich text content.

   ```typescript
   import { webview } from '@kit.ArkWeb';  
   
   @Entry  
   @Component  
   struct WebComponent {  
     controller: webview.WebviewController = new webview.WebviewController();  
     
     build() {  
       Column() {  
         // Load local resource file  
         Web({ src: $rawfile("index.html"), controller: this.controller })  
         // Load online web page  
         Web({ src: 'www.example.com', controller: this.controller})  
       }  
     }  
   }  
   ```

   When the RichText component cannot be used in an Ability, rich text content can be loaded via ArkWeb:

   ```typescript
   @State data: string = '...'; // Rich text content  
   
   Button('Load Rich Text').onClick((event: ClickEvent) => {  
     this.controller.loadData(this.data, '', '')  
   })  
   ```

2. **Supported Network Protocols and Resource Types**
   ArkWeb supports HTTP/HTTPS protocols and local file loading. Note that directly loading HTTP content may cause a white screen; mixed mode needs to be enabled:

   ```typescript
   .mixedMode(MixedMode.All)  
   ```

   [Reference Documentation Link](https://developer.huawei.com/consumer/cn/doc/HarmonyOS 5-references-V13/ts-basic-components-web-V13#mixedmode)

3. **Page Lifecycle and State Management**
   Common lifecycle callbacks include **onPageBegin**, **onPageEnd**, **onControllerAttached**, **onProgressChange**, etc. Among them, **onControllerAttached** is crucial during loading—controller operations must wait until the controller is bound, or crashes may occur. When the network is abnormal or the web page is unstable, the **onPageBegin** callback may delay, causing a white screen. In such cases, user experience can be optimized by adding a splash screen.

   ```typescript
   Web({  
         src: this.src,  
         controller: this.controller,  
       })  
         .width('100%')  
         .layoutWeight(1)  
   	  .onControllerAttached(() => {  
        })  
         .onPageBegin((event: OnPageBeginEvent) => {  
        })// Page starts loading  
         .onPageEnd((event: OnPageEndEvent) => {  
        })// Page loading completed  
         .onProgressChange((event: OnProgressChangeEvent) => {  
        })// Page loading progress  
   ```

4. **Security and Permission Control**

   * Sensitive interfaces (e.g., geolocation, camera) require permission requests via callbacks like **onPermissionRequest** and **onGeolocationShow**.
     The **geolocationAccess** flag must be set to `true` before requesting location permissions; otherwise, authorization will fail.

     ```typescript
     Web({  
           src: this.src,  
           controller: this.controller,  
         })  
           .width('100%')  
           .layoutWeight(1)  
           .geolocationAccess(true)// Must be true to request location permission  
           .onGeolocationShow(async (event: OnGeolocationShowEvent) => {  
             this.webLocationPermissionManager.locationStateManage(this.quickEntry)  
             event.geolocation.invoke(event.origin, true, false)  
           })  
           .onGeolocationHide(() => {  
             if (this.quickEntry ? this.quickEntry.isGetLocation : false) {  
               showToast('User did not grant location permission')  
               LogUtil.w(this.Tag, 'onGeolocationHide', 'Location permission request canceled')  
             }  
           })  
          .onPermissionRequest((event: OnPermissionRequestEvent) => {// Other permissions  
             PermissionUtil.handleWebPermissionRequest(event.request)  
           })  
     ```

   * Image download and upload are restricted by HarmonyOS 5 security policies—H5 cannot directly access the user’s gallery. When selecting gallery resources for file uploads, the **onShowFileSelector** callback can take over handling via **photoAccessHelper**:

     ````typescript
     Web({  
           src: this.src,  
           controller: this.controller,  
         })  
      .onShowFileSelector((event) => { // Take over for secure control  
           LogUtil.d('asda', event.result, event.fileSelector.getTitle(),  
            event.fileSelector.getMode(),  
            event.fileSelector.getAcceptType(),  
            event.fileSelector.isCapture())  
           if (this.hasIntersection(event.fileSelector.getAcceptType(),  
            this.supportedExtensions)) {  
             let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions()  
             PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE  
             PhotoSelectOptions.maxSelectNumber = this.selectPhotoMaxNumber  
             PhotoSelectOptions.isOriginalSupported = true  
             PhotoSelectOptions.subWindowName = 'aa'  
             const photoPicker = new photoAccessHelper.PhotoViewPicker()  
             photoPicker.select(PhotoSelectOptions)  
               .then(async (PhotoSelectResult) => {  
                 if (PhotoSelectResult.photoUris.length === 0) {  
                   console.warn('No image selected.')  
                   return  
                 }  
                 const srcUri = PhotoSelectResult.photoUris[0]  
                 let endings: string = this.extractFileExtension(srcUri) ? this.extractFileExtension(srcUri) as string : ''  
                 const context = getContext(this) as common.UIAbilityContext  
                 const destPath = `${context.tempDir}/` + Date.now() + `.` + endings  
                   // Storage operations for images  
                 return true  
               })  
         ```  

     ````

   * A common pitfall in hybrid development: the official **onDownloadStart** callback often fails to meet download requirements. In such cases, use **webview\.WebDownloadDelegate** to take over the download process, and use the secure control **SaveButton** to save files to the gallery. For detailed implementations, refer to: [HarmonyOS Hybrid Development – Quick Implementation of ArkWeb File Download Takeover](https://juejin.cn/post/7481143717245173786).

5. **Caching and Performance Optimization**
   Page rendering can be accelerated via pre-parsing, pre-connection, pre-loading, POST request capture, pre-compilation for cache generation, and offline resource injection without interception. Offline resource injection is particularly effective for lag or slow server access; refer to: [https://developer.huawei.com/consumer/cn/doc/HarmonyOS 5-guides-V5/web-predictor-V5#](https://developer.huawei.com/consumer/cn/doc/HarmonyOS 5-guides-V5/web-predictor-V5#).

---

### III. Hidden Tips Rarely Mentioned in Official Documentation

1. **Advanced Debugging Techniques**

   * Remote Chrome DevTools Integration: Debug ArkWeb pages via `chrome://inspect/#devices`. Enable debug mode and configure port mapping.

     ```typescript
     chrome://inspect/#devices  
     ```

     Enable debug mode:

     ```typescript
     aboutToAppear() {  
       // Enable web debugging mode  
       webview.WebviewController.setWebDebuggingAccess(true);  
     }  
     ```

     Enter in terminal:

     ```bash
     hdc fport tcp:9222 localabstract:webview_devtools_remote_53206  
     ```

     The number corresponds to the port visible in logs. Run twice to view web loading status.

   * Log Capture and Performance Analysis: Output H5 page logs to the console via **onConsole** callback.

     ```typescript
    .onConsole((event) => {  
       if (event) {  
         LogUtil.d(this.Tag, 'onConsole', 'getMessage:', event.message.getMessage(), 'getSourceId:',  
             event.message.getSourceId(), 'getLineNumber:', event.message.getLineNumber(), 'getMessageLevel:',  
             event.message.getMessageLevel())  
       }  
       return false;  
     })  
     ```
   
     

2. **Solutions for Special Scenarios**

   * Handle complex gesture conflicts, such as horizontal scrolling and page zooming.

     ```typescript
     Web({  
       src: this.url,  
       controller: this.controller,  
     })  
       .layoutWeight(1)  
       .zoomAccess(false)// Zoom control  
       .metaViewport(true)// Adaptive viewport  
       .horizontalScrollBarAccess(false)// Horizontal scroll bar control  
       .verticalScrollBarAccess(false)// Vertical scroll bar control  
     ```

   * Adapt to dark mode and dynamic theme switching.

     ```typescript
     .darkMode(WebDarkMode.Auto)// Enable web dark mode  
     ```

   * Compatibility handling for ArkWeb video full-screen playback.

     ```typescript
         .onFullScreenEnter((event) => {  
           // Detect full-screen event  
           window.getLastWindow(getContext(), (err: BusinessError, data) => {  
                 data?.setPreferredOrientation(window.Orientation.LANDSCAPE)  
             }  
           })  
         })  
         .onFullScreenExit(() => { // Detect exit full-screen event  
           this.handler?.exitFullScreen()  
           window.getLastWindow(getContext(), (err: BusinessError, data) => {  
           data?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED)  
           })  
         })  
     ```

### IV. Conclusion: Building an Efficient Hybrid Development Ecosystem

HarmonyOS 5 ArkWeb continues to evolve its technical architecture, providing developers with more powerful Web integration capabilities. The core tips revealed in this article have been validated in production environments, helping developers quickly build high-performance hybrid applications. The most challenging issues in hybrid development and ArkWeb usage are sudden white screens and debugging difficulties. The next article will focus on **ArkWeb white screen handling** and **debugging solutions for various functional points**.

Code repository for this issue: [Code Repository/ArkWebDemo](https://gitee.com/qq1963861722/ArkWebDemo)
