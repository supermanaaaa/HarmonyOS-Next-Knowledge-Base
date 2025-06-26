> # Leveraging HarmonyOS 5 Service Cards in Business Applications
>
> ## 1. ArkTS Card-Related Modules
>
> ### 1.1 form_config.json
>
> The `form_config.json` file under the `resources/base/profile/` directory is used to configure card layout, scheduled updates, dynamic/static settings, etc.
>
> Refer to the official documentation for full field definitions: [form_config.json Field Reference](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V13/arkts-ui-widget-configuration-V13)
>
> This file is an array structure that allows multiple card configurations of different dimensions. The `src` field specifies the layout file path.
>
> ```json
> {
>   "forms": [
>     {
>       "name": "widget1",
>       "displayName": "$string:widget_display_name",
>       "description": "$string:widget_desc",
>       "src": "./ets/widget/pages/WidgetCard.ets",
>       "uiSyntax": "arkts",
>       "window": {
>         "designWidth": 720,
>         "autoDesignWidth": true
>       },
>       "colorMode": "auto",
>       "isDynamic": false,
>       "isDefault": true,
>       "updateEnabled": false,
>       "scheduledUpdateTime": "10:30",
>       "updateDuration": 1,
>       "defaultDimension": "2*4",
>       "supportDimensions": ["2*4"]
>     },
>     {
>       "name": "widget2",
>       "displayName": "$string:widget_display_name",
>       "description": "$string:widget_desc",
>       "src": "./ets/widget/pages/WidgetCard.ets",
>       "uiSyntax": "arkts",
>       "window": {
>         "designWidth": 720,
>         "autoDesignWidth": true
>       },
>       "colorMode": "auto",
>       "isDynamic": false,
>       "isDefault": false,
>       "updateEnabled": false,
>       "scheduledUpdateTime": "10:30",
>       "updateDuration": 1,
>       "defaultDimension": "4*4",
>       "supportDimensions": ["4*4"]
>     }
>   ]
> }
> ```
>
> ### 1.2 EntryFormAbility
>
> Implement lifecycle methods of `FormExtensionAbility` in `EntryFormAbility.ets`:
>
> ```ts
> import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
> import { Want } from '@kit.AbilityKit';
> 
> export default class EntryFormAbility extends FormExtensionAbility {
>   onAddForm(want: Want) {
>     let formData = '';
>     return formBindingData.createFormBindingData(formData);
>   }
>   onCastToNormalForm(formId: string) {}
>   onUpdateForm(formId: string) {}
>   onFormEvent(formId: string, message: string) {}
>   onRemoveForm(formId: string) {}
>   onAcquireFormState(want: Want) {
>     return formInfo.FormState.READY;
>   }
> };
> ```
>
> ### 1.3 Saving Card IDs Including Temporary Ones
>
> - `onAddForm` can be called multiple times.
> - `onRemoveForm` should remove IDs for non-pinned cards.
>
> ```ts
> import { preferences } from '@kit.ArkData';
> 
> private saveServiceCardId(want: Want): void { ... }
> private deleteServiceCardId(formId: string): void { ... }
> ```
>
> The core logic saves all card IDs in `onAddForm`, and filters them in `onRemoveForm`.
>
> ### 1.4 Getting IDs of Pinned Cards
>
> The app provider can read the IDs of cards pinned to the home screen like this:
>
> ```ts
> private getFormIds(): void {
>   let options = { name: 'CloudPhoneCard' };
>   preferences.removePreferencesFromCacheSync(getContext(this), options);
>   let formIds = preferences.getPreferencesSync(getContext(this), options);
>   Logger.debug(`EntryAbility getFormIds: ${formIds.getSync('formIds', '[]')}`);
> }
> ```
>
> ### 1.5 Updating Network Images in Cards
>
> Only dynamic cards support image updates. Network images must be downloaded to local storage first, and accessed using the `memory://` prefix.
>
> ```ts
> private async updateNetImg(formId: string, src: string): Promise<void> {
>   let fileName = 'file' + Date.now();
>   let tmpFile = this.context.getApplicationContext().tempDir + '/' + fileName;
>   let imgMap: Record<string, number> = {};
> 
>   class FormDataClass {
>     updateImg: string = fileName;
>     formImages: Record<string, number> = imgMap;
>   }
> 
>   let httpRequest = http.createHttp();
>   let data = await httpRequest.request(src);
> 
>   if (data?.responseCode == http.ResponseCode.OK) {
>     try {
>       let imgFile = fileIo.openSync(tmpFile, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
>       imgMap[fileName] = imgFile.fd;
>       let writeLen = await fileIo.write(imgFile.fd, data.result as ArrayBuffer);
>       let formData = new FormDataClass();
>       let formInfo = formBindingData.createFormBindingData(formData);
>       await formProvider.updateForm(formId, formInfo);
>       fileIo.closeSync(imgFile);
>     } catch (error) {
>       Logger.debug(`Failed to write image: ${JSON.stringify(error)}`);
>     }
>   }
>   httpRequest.destroy();
> }
> ```
>
> > Official reference: [Image Update Guide](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V13/arkts-ui-widget-image-update-V13)