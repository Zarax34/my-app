# GitHub Actions CI/CD Guide

## 🤖 Automated Build Workflows

This project includes GitHub Actions workflows that automatically build your APK on every push.

## Workflows Included

### 1. `build-apk.yml` - Basic APK Build
- **Triggers**: Push to main/master, pull requests, tags
- **Outputs**: Release APK
- **Features**: 
  - Auto-creates GitHub Release on version tags (e.g., `v1.0.0`)
  - Uploads APK as artifact (available for 30 days)

### 2. `build-release.yml` - Complete Build (Recommended)
- **Triggers**: Push, PRs, tags, manual dispatch
- **Outputs**: Debug APK, Release APK, App Bundle (AAB)
- **Features**:
  - Code analysis
  - Test execution
  - Build summary in Actions tab
  - Auto-release on tags

## 📋 Setup Instructions

### 1. Push to GitHub

```bash
cd /storage/self/primary/my-app

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Ollama Mobile Studio"

# Create GitHub repository (go to github.com/new)
# Then add remote and push
git remote add origin https://github.com/YOUR_USERNAME/ollama-mobile-studio.git
git branch -M main
git push -u origin main
```

### 2. Workflows Run Automatically

Once pushed, GitHub Actions will:
1. Detect the `.github/workflows/` folder
2. Run the build on every push to main/master
3. Generate APK files as artifacts

### 3. Download Built APK

**Option A: From Actions Tab**
1. Go to your repo → **Actions** tab
2. Click on the latest workflow run
3. Scroll to **Artifacts** section
4. Click `app-release-apk` to download

**Option B: From Releases (on tags)**
1. Create a tag: `git tag v1.0.0`
2. Push tag: `git push origin v1.0.0`
3. Go to repo → **Releases**
4. Download APK from the release

## 🚀 Creating a Release

```bash
# Create version tag
git tag v1.0.0

# Push tag to GitHub
git push origin v1.0.0

# The workflow will automatically:
# - Build APK and AAB
# - Create a GitHub Release
# - Attach the build files
```

## ⚙️ Customization

### Change Flutter Version
Edit `.github/workflows/build-release.yml`:
```yaml
env:
  FLUTTER_VERSION: '3.16.0'  # Change this
```

### Add Signing (for Play Store)

1. **Create keystore properties file**:
```bash
# In your project root
echo "storePassword=YOUR_PASSWORD" > android/key.properties
echo "keyPassword=YOUR_PASSWORD" >> android/key.properties
echo "keyAlias=upload" >> android/key.properties
echo "storeFile=upload-keystore.jks" >> android/key.properties
```

2. **Add secrets to GitHub**:
   - Go to repo → Settings → Secrets and variables → Actions
   - Add:
     - `KEYSTORE` (base64 encoded keystore file)
     - `KEYSTORE_PASSWORD`
     - `KEY_PASSWORD`
     - `KEY_ALIAS`

3. **Update build.gradle** to use signing config

## 📊 Build Summary

After each workflow run, you'll see a summary like:

| Build Type | Status | Size |
|------------|--------|------|
| Debug APK | ✅ Success | 45 MB |
| Release APK | ✅ Success | 22 MB |
| App Bundle | ✅ Success | 20 MB |

## 🔧 Manual Build Trigger

The `build-release.yml` workflow supports manual triggers:

1. Go to **Actions** → **Build & Release**
2. Click **Run workflow**
3. Select debug or release
4. Click **Run workflow**

## 📝 Common Issues

| Issue | Solution |
|-------|----------|
| Workflow doesn't run | Check `.github/workflows/` exists |
| Build fails | Check `flutter analyze` output in logs |
| Artifact expired | Artifacts kept for 30 days, use releases for permanent |
| Java version error | Ensure Java 17 in workflow |

## 🎯 Next Steps

1. ✅ Push code to GitHub
2. ✅ Watch Actions tab for build
3. ✅ Download and test APK
4. ✅ Create first release tag
5. ✅ Share with users!

---

**Need help?** Check [GitHub Actions Docs](https://docs.github.com/en/actions)
