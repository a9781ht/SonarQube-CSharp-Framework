# SonarQube Windows C# .NET Framework 專案導入示範

此為示範專案，教導如何將 Windows 平台的 .NET Framework 專案導入到 SonarQube。

---

## 使用版本

| 工具 | 版本 |
|------|------|
| SonarQube | Developer Edition v10.6 |
| SonarScanner | 9.0.0.100868 (for .NET Framework) |

---

## 前置作業

1. 透過個人 GitLab 帳號的 **Personal Access Token** 將該 .NET Framework 專案加入到 SonarQube

2. 選擇 **Previous Version** 當作 New Code 的 baseline

3. 將 SonarQube 的 URL 儲存在 GitLab 的**全域變數**裡，取名為 `SONAR_HOST_URL`

4. 將該 .NET Framework 專案在 SonarQube 產生出來的 **Project Key** 儲存到 GitLab 的 **Settings → CI/CD → Variables** 裡，取名為 `SONARQUBE_PROJECT_KEY`

5. 將該 .NET Framework 專案在 SonarQube 產生出來的 **Token** 儲存到 GitLab 的 **Settings → CI/CD → Variables** 裡，取名為 `SONAR_TOKEN`

---

## 專案修改

1. 修改 `.gitlab-ci.yml` 裡的 `image`，選一個可以編譯你軟體的環境，並且該環境也需要擁有 `git` 與 `7z` 等工具

2. 修改 `.gitlab-ci.yml` 裡的 `tag`，選一個 GitLab 有提供的 Windows 環境去啟動 image

3. 修改 `SQAnalysis.bat` 裡的 `version` 軟體版本

4. 修改 `SQAnalysis.bat` 裡的 `release` 分支前綴

---

## 開始分析

| 分支類型 | New Code 區分方式 |
|----------|-------------------|
| `master` | 使用 `SQAnalysis.bat` 裡的 `Version` 變數 |
| `release` | 使用 `SQAnalysis.bat` 裡的 `Version` 變數 |
| `feature` / `bug` | 使用 `.gitlab-ci.yml` 裡的 `NewCodeRefBranch` 變數 |

---

## 測試結果報表

1. vstest.console.exe 只支援輸出 [Trx, Console, Html 這三種格式的測試結果報表](https://github.com/microsoft/vstest-docs/blob/main/docs/report.md)

2. 要在 GitLab 上顯示，需要 [JUnit 格式](https://docs.gitlab.com/ci/testing/unit_test_reports/#file-format-and-size-limits)，需搭配第三方工具 JunitXml.TestLogger。然後在 job:artifacts:reports:junit 欄位指定該測試結果報表

3. 要在 SonarQube 上顯示，C# 可以是 [Trx 格式](https://docs.sonarsource.com/sonarqube-server/10.6/analyzing-source-code/test-coverage/test-execution-parameters#sonarcsvstestreportspaths)。然後在 sonar.cs.vstest.reportsPaths 欄位指定該測試結果報表

---

## 測試覆蓋率報表

1. vstest.console.exe 只支援捕獲 [*.coverage, *.cobertura.xml, *.coveragexml 這三種格式的覆蓋率報表](https://learn.microsoft.com/zh-tw/visualstudio/test/customizing-code-coverage-analysis?view=visualstudio#code-coverage-formats)

2. 要在 GitLab 上顯示，需要 [Visual Studio Cobertura 格式 *.cobertura.xml](https://docs.gitlab.com/ci/testing/code_coverage/?tab=C%2FC%2B%2B+and+Rust#coverage-visualization)，可以直接透過 vstest.console.exe 捕獲。然後在 job:artifacts:reports:coverage_report:path 欄位指定該測試覆蓋率報表

3. 要在 SonarQube 上顯示，C++ 可以是 [SonarQube Generic Code Coverage Format 格式](https://docs.sonarsource.com/sonarqube-server/10.6/analyzing-source-code/test-coverage/test-coverage-parameters#cfamily)，可以透過第三方工具 ReportGenerator 將 *.cobertura.xml 直接轉成 SonarQube 格式。然後在 sonar.coverageReportPaths 欄位指定該測試覆蓋率報表

---

## 備註

<details>
  <summary>專案格式</summary>
  .NET Framework 4.8 其實可以使用 SDK style，但本示範專案使用 **non-SDK style**，因為這是 .NET Framework 專案較常見的格式。
</details>

<details>
  <summary>套件管理方式</summary>
  non-SDK style（舊格式）支援兩種套件管理方式：**PackageReference** 和 **packages.config**，而本專案選用 PackageReference，因為它支援建置時自動還原套件。
</details>

<details>
  <summary>套件還原方式</summary>
  使用 PackageReference 時，可以在命令列透過 MSBuild 的 `/restore` 選項自動還原套件。
</details>

<details>
  <summary>其他</summary>

  > vstest.console.exe
  1. 雖然 Nunit 會產生自己的動態函式庫，但本專案選用 vstest.console.exe，以利統一各語言的測試平台。但不要使用 Visual Studio 內建路徑下的 vstest.console.exe (C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe) 因為他在蒐集覆蓋率時還需手動調用 datacollector.exe 的協助，建議可以直接使用 Microsoft.Testing.Platform (NuGet package) 裡的 vstest.console.exe，其整合的較為完整
  2. 由於 vstest.console.exe 執行一次只能捕獲一種測試覆蓋率的格式，為了兼容 SonarQube 和 GitLab 的情境，可以先產生一種格式，再用工具轉換成另一種格式。不過官方的 CodeCoverage.exe 和 Microsoft.CodeCoverage.Console 工具都已經不再維護了，目前官方只建議使用 dotnet-coverage 這套工具，但它需要 .NET SDK。以 C# .NET Framework 的情境來說，可以改使用第三方工具 ReportGenerator
  3. 因此架構會變成：vstest.console.exe 產生 GitLab 需要的 Cobertura 格式，ReportGenerator 再將其轉換成 Visual Studio XML 格式或是直接轉成 SonarQube 格式，甚至也可以多轉出一份易閱讀的 HTML 格式
  4. 而 UseVerifiableInstrumentation 這個參數預設為 True，會使得 vstest.console.exe 在捕獲 code coverage 需要 Microsoft.VisualStudio.CodeCoverage.Shim.dll (需額外從 MicrosoftTestPlatform 套件裡複製到測試輸出的目錄)，改成 False 就不需要，兩者產生的報告內容基本上沒有差別，只是前者產生的 IL 程式碼會符合 CLS/CAS 規範 (較安全)，而後者不保證而已 (但對於一般的單元測試來說不影響)
  
  > SonarQube
  1. 以 SonarQube v10.6 版本為例，對於 C# 來說，test report 報表支援 Trx、Nunit、XUnit 與 SonarQube 格式；code coverage 報表支援 OpenCover、dotCover、Coverle、dotnet-coverage、Visual Studio XML 與 SonarQube 格式 Nunit
  2. 如果 test report 報表用 Nunit 格式的話，也可以，不過就需要搭配第三方工具 NunitXml.TestLogger
  3. 如果 code coverage 報表，OpenCover 已停止維護、dotCover 需要付費、dotnet-coverage 僅支援 .NET 專案、Coverlet 雖然支援 .NET 和 .NET Framework (>= 4.6.2) 專案，但必須是 SDK style
  4. 若透過 ReportGenerator 轉出 Visual Studio XML 格式會有很多份，每個測試案例就是獨立一份，所以 sonar.cs.vscoveragexml.reportsPaths 欄位支援 wildcard；而轉出 SonarQube 格式只會有一份，預設叫做 SonarQube.xml，所以 sonar.coverageReportPaths 欄位不支援 wildcard
  
  > GitLab
  1. GitLab 顯示 code coverage 的地方會在 Merge Request 裡面，如果想在 Jobs 頁面上顯示 code coverage 的百分比，需要使用 coverage 關鍵字 (透過 ReportGenerator 產生 TeamCitySummary 格式，並從 console output 中提取覆蓋率百分比)，其中 CodeCoverageS 代表 Statement Coverage 語句覆蓋率
</details>