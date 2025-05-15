@echo off
:: 读取配置文件中的包名（如果存在）
set PACKAGE_NAME=
if exist config.txt (
    for /f "delims=" %%i in (config.txt) do set PACKAGE_NAME=%%i
)
echo config bundleName info :---------  %PACKAGE_NAME%  ------------
echo(
:: 如果未从配置文件获取，则允许用户输入
if "%PACKAGE_NAME%"=="" (
    set /p PACKAGE_NAME=Please enter the package name: 
)
echo(
:: 确保包名不为空
if "%PACKAGE_NAME%"=="" (
    echo Error: Package name is required!
    exit /b 1
)

:: 卸载应用（动态包名）
hdc uninstall %PACKAGE_NAME%

:: 获取脚本所在目录
set SCRIPT_DIR=%~dp0

:: 初始化标志
set INSTALL_SUCCESS=1

:: 扫描并安装所有 HSP 文件
echo Scanning for .hsp files in %SCRIPT_DIR%...
for %%f in ("%SCRIPT_DIR%*.hsp") do (
    echo Installing HSP: %%~nxf...
    hdc install "%%~f"
    if %errorlevel% neq 0 (
        echo Failed to install HSP file: %%~nxf
        set INSTALL_SUCCESS=0
        goto END
    )
    echo Successfully installed HSP file: %%~nxf
)

:: 检查是否存在 HAP 文件
set HAP_FILE=
for %%f in ("%SCRIPT_DIR%*.hap") do (
    set HAP_FILE=%%~f
)

if not defined HAP_FILE (
    echo No HAP file found in the directory. Exiting...
    set INSTALL_SUCCESS=0
    goto END
)

:: 安装 HAP 文件（如果所有 HSP 文件成功）
if %INSTALL_SUCCESS% equ 1 (
    echo Installing HAP: %HAP_FILE%...
    hdc install "%HAP_FILE%"
    if %errorlevel% neq 0 (
        echo Failed to install HAP file: %HAP_FILE%
        set INSTALL_SUCCESS=0
    ) else (
        echo Successfully installed HAP file: %HAP_FILE%
    )
)
echo(
:END
:: 输出最终结果
if %INSTALL_SUCCESS% equ 1 (
    echo.
    echo ================================
    echo All files installed successfully.
    echo ================================
    hdc shell aa start -a EntryAbility -b %PACKAGE_NAME% -m entry
) else (
    echo.
    echo ================================
    echo Installation failed. Check the details above.
    echo ================================
)

:: 等待用户退出
echo.
echo Press any key to exit...
pause >nul
