$output = "$PSScriptRoot\project_for_ai.txt"

# الملفات النصية المسموح بها
$textExtensions = @(
    "*.py","*.js","*.ts","*.jsx","*.tsx",
    "*.html","*.css","*.scss",
    "*.dart","*.java","*.kt","*.swift",
    "*.tf","*.tfvars","*.hcl",
    "*.yaml","*.yml","*.json",
    "*.xml","*.gradle","*.properties",
    "*.md","*.txt","*.sh","*.ps1",
    "*.sql","*.env","*.conf","*.cfg",
    "Dockerfile",
    "Jenkinsfile",
    "Dockerfile.*"
    
)

# فولدرات يتم تجاهلها
$excludePatterns = @(
    "*\.git\*",
    "*\node_modules\*",
    "*\.dart_tool\*",
    "*\build\*",
    "*\.terraform\*",
    "*\.md\*",
    "*\.idea\*",
    "*\.vscode\*",
    "*\dist\*",
    "*\bin\*",
    "*\obj\*"
)

# امتدادات binary ممنوعة
$binaryExtensions = @(
    "*.png","*.jpg","*.jpeg","*.gif","*.webp",
    "*.mp4","*.mp3","*.wav",
    "*.zip","*.rar","*.7z",
    "*.exe","*.dll","*.so",
    "*.jar","*.apk","*.ipa",
    "*.pdf","*.docx","*.xlsx",
    "*.tflite","*.pt","*.onnx"
)

# حذف الملف القديم لو موجود
if (Test-Path $output) {
    Remove-Item $output
}

Get-ChildItem -Recurse -File | ForEach-Object {

    $file = $_
    $path = $file.FullName
    $name = $file.Name

    $isExcluded = $false

    # استبعاد الفولدرات
    foreach ($pattern in $excludePatterns) {
        if ($path -like $pattern) {
            $isExcluded = $true
            break
        }
    }

    # استبعاد الملفات الثنائية
    if (-not $isExcluded) {
        foreach ($pattern in $binaryExtensions) {
            if ($name -like $pattern) {
                $isExcluded = $true
                break
            }
        }
    }

    # استبعاد جميع ملفات Markdown
    if ($name -like "*.md") {
        $isExcluded = $true
    }

    # التأكد أنه ملف نصي
    $isTextFile = $false
    foreach ($ext in $textExtensions) {
        if ($name -like $ext) {
            $isTextFile = $true
            break
        }
    }

    if ($isTextFile -and -not $isExcluded) {

        Add-Content $output "`n=================================================="
        Add-Content $output "FILE: $path"
        Add-Content $output "=================================================="

        try {
            Get-Content $path -Raw -ErrorAction Stop | Add-Content $output
        }
        catch {
            Add-Content $output "[ERROR READING FILE]"
        }
    }
}

Write-Host "`nDone! Output saved to:"
Write-Host $output