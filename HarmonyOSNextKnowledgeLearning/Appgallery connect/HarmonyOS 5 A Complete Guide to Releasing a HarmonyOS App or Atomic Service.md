# HarmonyOS 5: A Complete Guide to Releasing a HarmonyOS App or Atomic Service

Given the lack of comprehensive official documentation on releasing an atomic service, this guide walks you through the complete process from start to finish. It is based on real experience preparing to release a HarmonyOS atomic service.

## Overview

The process is divided into the following steps:

1. Create the Project
2. AppGallery Setup
3. Development
4. Build and Package
5. Release

Let's begin.

## Step 1: Create an Atomic Service Project

Creating an atomic service project is slightly different from a standard HarmonyOS app.

1. In DevEco Studio, go to `File > New > Create Project`, then select **"Atomic Service"**. Choose a template (default: Empty Ability) and click **Next**.
2. The wizard will check your login status. If not logged in, you will be redirected to log in on the web.
3. After logging in, return to DevEco Studio and select your **App ID** from the dropdown. If none exist, click **"Register App ID"** to create one.
4. On the web page, fill in details such as `App Name`, `App Type`, etc.
5. After submitting, you will be prompted with a success message. You can view the project details in the console, although it's optional at this point.
6. Back in DevEco Studio, select your newly created project from the dropdown and click **Next**.
7. Provide basic project info such as `Project Name`, `Save Location`, etc., and click **Finish**.

Project creation is now complete.

## Step 2: AppGallery Setup

This step is mostly covered in Step 1. You create the App ID and can check the project info in AppGallery Connect.

## Step 3: Development

Now develop the actual features of your atomic service. Refer to the HarmonyOS documentation for specific development guidance.

## Step 4: Build and Package

Before packaging, additional AppGallery configuration is needed.

### AppGallery Configuration Overview

HarmonyOS requires a digital certificate and Profile file for signing atomic services before they can be released.

#### 4.1 Generate Key and CSR File

1. In DevEco Studio, go to `Build > Generate Key and CSR`.
2. In the dialog, fill in basic info. If this is your first time, click **New** to create a `.p12` key store file:
   - **Key store file**: Path and custom name.
   - **Password**: Set and remember it.
   - **Confirm Password**: Same as above.

Click **OK** to return. The `.p12` file path and password should now be auto-filled.

Next:

- **Alias**: Key alias (any memorable name).
- **Password**: Auto-filled, same as keystore password.
- **Validity**: Recommended 25+ years.
- **Certificate Info**: Organization, region, country code, etc.

Click **Next**, then choose CSR file path and name. Click **Finish**. You now have a `.p12` and a `.csr` file on your computer.

#### 4.2 Apply for a Release Certificate

1. Log in to AppGallery Connect.
2. Go to **Certificates, App IDs & Profiles**.
3. Under the **Certificates** tab, click **New Certificate**.
4. Fill in:
   - **Certificate Name**: Any name under 100 characters.
   - **Type**: Choose **Release Certificate**.
   - **CSR File**: Upload the `.csr` file you just generated.

Click **Submit** to generate the certificate. Download the `.cer` file afterward.

#### 4.3 Apply for a Release Profile

Profiles (.p7b) are required for packaging. On the Profile tab:

- **App Name**: Select from dropdown.
- **Package Name**: Auto-filled.
- **Profile Name**: Custom name (match atomic service name recommended).
- **Type**: Choose **Release**.
- **Certificate**: Select the one created earlier.
- **Permission Request**: Apply only if your app requires special permissions (optional).

Click **Add**, then download the `.p7b` profile file.

### Configure Signing Info for Build

Before building, configure the signing setup:

1. Open the `build-profile.json5` file. Note that `signingConfigs` may initially be empty.
2. In DevEco Studio, go to `File > Project Structure`, open the **Signing Configs** tab.
3. Uncheck **Auto Sign**.
4. Fill in:
   - **Store File**: Path to `.p12` file.
   - **Store Password**
   - **Key Alias**
   - **Key Password**
   - **Sign Algorithm**: `SHA256withECDSA`
   - **Profile File**: Path to `.p7b` file.
   - **CertPath File**: Path to downloaded `.cer` file.

Click **OK**. Reopen `build-profile.json5` to confirm `signingConfigs` has been populated.

### Build and Package the App

1. In DevEco Studio, go to `Build > Build Hap(s)/APP(s) > Build APP(s)`.
2. The compiled and signed output will appear under: `build/output/app/release/`

Example: `HistoryToday-default-signed.app` — ready for publishing.

## Step 5: Publish to AppGallery

1. Log in to AppGallery Connect and navigate to **My Atomic Services**.
2. Select the **HarmonyOS** tab, search for your service name, and click **Edit**.

Fill in required info:

- **Release Country/Region**
- **Basic Info**
- **Privacy Policy**: Add a link or create one.
- **User Agreement**: Provide a link.
- **Filing Info**: Choose appropriate filing type (e.g., standalone app).
- **Listing Schedule**: Choose immediate or scheduled release.
- **App Icon**: Must be 216x216. See [icon guidelines](https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/atomic-service-icon-generation-V5).

### Upload Package

Upload the package you built (e.g., `HistoryToday-default-signed.app`). Set **Usage Scenario** to **Testing and Official Release**.

Click **Submit for Review** and wait for approval.

After submission, your service will show status: **Pre-reviewing**.

Note: Review times can be slow — please be patient.