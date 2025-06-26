# HarmonyOS 5 DES Encryption and Decryption

## 1. Introduction to harmony

`harmony` is a powerful yet easy-to-use utility library for HarmonyOS, designed to help developers quickly build HarmonyOS applications. It encapsulates a variety of commonly used utilities, including but not limited to:

- **System & Device:** App info, device info, screen adaptation
- **User Interaction:** Dialogs, toasts, notifications, camera, QR code scanning
- **Storage & Data Processing:** User preferences, file operations, JSON, string manipulation, collections, encryption/decryption
- **Security:** DES/AES encryption and decryption, biometric authentication, exception capturing
- **Others:** Thread communication, logging, random number generation, Base64 encoding/decoding, etc.

Additionally, `picker_utils` is a sub-library extracted from `harmony`, which contains utilities such as `PickerUtil`, `PhotoHelper`, and `ScanUtil`.

### Installation

```bash
ohpm i @pura/harmony
ohpm i @pura/picker_utils
```

> Initialize the library globally in the `onCreate` method of your `UIAbility`:

```ts
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  AppUtil.init(this.context);
}
```

------

## 2. Introduction to DES Algorithm

DES (Data Encryption Standard) is the first standardized symmetric block cipher algorithm released by the United States in 1977. It features:

- **64-bit data blocks**
- **56-bit effective key** (plus 8 parity bits totaling 64 bits)
- **16-round Feistel network structure**

The encryption involves expansion permutation, nonlinear S-box transformation, and P-box permutation to enhance confusion and diffusion.

### Main drawbacks:

- Small key space of only 2562^{56}, vulnerable to brute-force attacks
- Existence of weak keys (e.g., all-zero key)
- Poor resistance to differential and linear cryptanalysis

Therefore, DES has been replaced by AES for modern cryptography, but it remains a classic teaching example and a milestone in cryptographic standardization.

------

## 3. Using DES APIs in harmony

### 3.1 Generate Symmetric Key

```ts
let symKey1 = await DES.generateSymKey();
let symKeyStr1 = CryptoHelper.dataBlobToStr(symKey1.getEncoded(), 'hex');
LogUtil.error(`Symmetric Key 1: ${symKeyStr1}`);

let symKey2 = DES.generateSymKeySync();
let symKeyStr2 = CryptoHelper.dataBlobToStr(symKey2.getEncoded(), 'base64');
LogUtil.error(`Symmetric Key 2: ${symKeyStr2}`);
```

------

### 3.2 ECB Mode Encryption & Decryption

#### Encryption

```ts
let plaintext = "HarmonyOS Tech Exchange QQ Group: 1029219059";
let base64Key = "bZen8i4KBFVMlomHBNWeExvFydWEXspO";
let symKey = CryptoUtil.getConvertSymKeySync('3DES192', base64Key, 'base64');
let dataBlob = CryptoHelper.strToDataBlob(plaintext, 'utf-8');

let encryptedBlob = await DES.encryptECB(dataBlob, symKey);
let encryptedStr = CryptoHelper.dataBlobToStr(encryptedBlob, 'utf-8');
LogUtil.error(`Encrypted (ECB, async): ${encryptedStr}`);
```

#### Decryption

```ts
let decryptedBlob = await DES.decryptECB(encryptedBlob, symKey);
let decryptedStr = CryptoHelper.dataBlobToStr(decryptedBlob, 'utf-8');
LogUtil.error(`Decrypted (ECB, async): ${decryptedStr}`);
```

> Synchronous versions available as `DES.encryptECBSync()` and `DES.decryptECBSync()`.

------

### 3.3 CBC Mode Encryption & Decryption (Supports IV)

#### Encryption

```ts
let ivParams = CryptoUtil.generateIvParamsSpec();
let plaintext = "harmony, a highly efficient HarmonyOS toolkit.";
let base64Key = "bZen8i4KBFVMlomHBNWeExvFydWEXspO";
let symKey = CryptoUtil.getConvertSymKeySync('3DES192', base64Key, 'base64');
let dataBlob = CryptoHelper.strToDataBlob(plaintext, 'utf-8');

let encryptedBlob = await DES.encryptCBC(dataBlob, symKey, ivParams);
let encryptedStr = CryptoHelper.dataBlobToStr(encryptedBlob, 'utf-8');
LogUtil.error(`Encrypted (CBC, async): ${encryptedStr}`);
```

#### Decryption

```ts
let decryptedBlob = await DES.decryptCBC(encryptedBlob, symKey, ivParams);
let decryptedStr = CryptoHelper.dataBlobToStr(decryptedBlob, 'utf-8');
LogUtil.error(`Decrypted (CBC, async): ${decryptedStr}`);
```

------

### 3.4 Custom Encryption Modes (e.g., OFB, PKCS7)

#### Encryption (OFB Mode)

```ts
let ivParams = CryptoUtil.generateIvParamsSpec();
let hexKey = "f1f8d34a21fd62ffb128b1ada4fd8f0758123e7d442b6273";
let symKey = await CryptoUtil.getConvertSymKey('3DES192', hexKey, 'hex');
let dataBlob = CryptoHelper.strToDataBlob("HarmonyOS Tech Exchange QQ Group: 1029219059", 'utf-8');

let encryptedBlob = await DES.encrypt(dataBlob, symKey, ivParams, '3DES192|OFB|PKCS7');
let encryptedStr = CryptoHelper.dataBlobToStr(encryptedBlob, 'utf-8');
LogUtil.error(`Encrypted (OFB mode, async): ${encryptedStr}`);
```

#### Decryption (OFB Mode)

```ts
let decryptedBlob = await DES.decrypt(encryptedBlob, symKey, ivParams, '3DES192|OFB|PKCS7');
let decryptedStr = CryptoHelper.dataBlobToStr(decryptedBlob, 'utf-8');
LogUtil.error(`Decrypted (OFB mode, async): ${decryptedStr}`);
```

------

## 4. Summary

- `harmony` provides comprehensive support for symmetric encryption and decryption, including multiple DES modes (ECB, CBC, OFB, etc.) with both synchronous and asynchronous APIs.
- With `CryptoUtil` and `CryptoHelper`, converting between strings and binary data is straightforward.
- For production use, CBC or higher-security algorithms (e.g., AES) are recommended instead of ECB.

