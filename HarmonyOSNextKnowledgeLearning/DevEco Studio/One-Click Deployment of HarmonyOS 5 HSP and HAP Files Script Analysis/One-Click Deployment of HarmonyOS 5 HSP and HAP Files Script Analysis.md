# One-Click Deployment of HarmonyOS 5 HSP and HAP Files: Script Analysis

During HarmonyOS 5 application development and testing, frequent installation and update of test packages are common needs. This article introduces how to use an automated batch script (`install_v1.0.1.bat`) to quickly uninstall, install, and launch HarmonyOS 5 applications, significantly improving development and testing efficiency.

---

## Core Functions of the Script

The script achieves the following functions:

1. **Dynamic Package Name Reading**: Supports automatic package name retrieval from a configuration file (`config.txt`) or manual input.
2. **Automatic Uninstallation of Old Versions**: Cleans up old applications via the `hdc uninstall` command.
3. **Batch Installation of HSP Files**: Scans all `.hsp` files (Harmony Shared Packages) in the current directory and installs them sequentially.
4. **Main HAP File Installation**: Detects and installs `.hap` files (Harmony Application Packages) in the directory, proceeding only if all HSP installations succeed.
5. **Automatic Application Launch**: Starts the application's EntryAbility via `hdc shell` after successful installation.
6. **Robust Error Handling**: Real-time installation status detection, with process interruption and detailed error prompts on failure.

---

## File Description

### 1. Configuration File `config.txt`

* **Purpose**: Stores the HarmonyOS 5 application package name (e.g., `com.atomicservice.5765880207855877209`).
* **Advantage**: Avoids repeated input, suitable for fixed-package-name testing scenarios.
* **Format Requirement**: Single-line content with no additional syntax.

### 2. Batch Script `install_v1.0.1.bat`

* **Compatibility**: Supports Windows environments.
* **Dependent Tool**: Requires pre-configured HarmonyOS 5 Device Connector (`hdc`) added to the system path.

---

## Usage Steps

### Step 1: Prepare Files

1. Place the script file `install_v1.0.1.bat` and configuration file `config.txt` in the project root directory.
2. Ensure the current directory contains `.hsp` (shared packages) and `.hap` (application packages) to be installed.

### Step 2: Configure Package Name (Optional)

* **Directly Modify `config.txt`**: Write the target package name (overwriting existing content).
* **No Configuration File Modification**: Manually input the package name when running the script.

### Step 3: Run the Script

Double-click `install_v1.0.1.bat` and follow the prompts:

1. If `config.txt` exists and contains a valid package name, it will be automatically read to uninstall the old version.
2. If no package name is configured, the script will prompt for manual input.
3. Install all HSP files in sequence, then install the HAP file.
4. After successful installation, the application will start automatically with log output.

---

## Key Code Analysis

### 1. Dynamic Package Name Reading

```bat
if exist config.txt (
    for /f "delims=" %%i in (config.txt) do set PACKAGE_NAME=%%i
)
```

* Reads the first line of `config.txt` as the package name if the file exists.

### 2. Error Interruption Logic

```bat
if %errorlevel% neq 0 (
    echo Failed to install HSP file: %%~nxf
    set INSTALL_SUCCESS=0
    goto END
)
```

* Immediately terminates the process and marks failure if any HSP installation fails.

### 3. Automatic Application Launch

```bat
hdc shell aa start -a EntryAbility -b %PACKAGE_NAME% -m entry
```

* Starts the application's EntryAbility via HarmonyOS 5' `aa` command, requiring the `EntryAbility` name to match the project configuration.

---

## Common Issues and Recommendations

1. **Difference Between HSP and HAP**

   * **HSP (Harmony Shared Package)**: Reusable shared function modules for multiple applications.
   * **HAP (Harmony Application Package)**: Main application package containing entry logic.

2. **Troubleshooting Script Execution Failures**

   * Check if the `hdc` tool is properly connected to the device.
   * Ensure the HAP file exists and is not corrupted.
   * Confirm the package name matches the project configuration (to avoid permission conflicts).

3. **Expansion Suggestions**

   * Modify the script to support multi-HAP installation (requires adjusting loop logic).
   * Add version number validation to prevent repeated installation of the same version.

---

## Conclusion

This script enables developers to quickly deploy HarmonyOS 5 test packages, achieving an automated "one-click install+launch" process. It is particularly suitable for scenarios requiring frequent feature validation or bug fixing. With dynamic configuration file reading and rigorous error handling, it enhances efficiency while reducing manual operation errors.

Download the script now to experience efficient HarmonyOS 5 development!

---

**Appendix**:

* [HarmonyOS hdc Tool Usage Guide](https://developer.huawei.com/consumer/cn/doc/HarmonyOS 5-guides-V14/hdc-V14)
* Script Source Code Address: [GitHub Example Repository](https://gitee.com/qq1963861722/harmony-deploy/blob/master/README.md)
* How to Cache Images Quickly in Ability: [Recommended Reading](https://juejin.cn/post/7478653035117264911)