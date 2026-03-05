# How to Create a GitHub Release

## 📋 Steps to Release

### 1. Build the Release

**For signed/notarized releases** (recommended for distribution):
```bash
# Requires .env with Apple Developer credentials (see README)
./build-release.sh
```

**For unsigned builds** (e.g. quick test packages):
```bash
./build-github-release.sh
```

`build-release.sh` creates:
- `release/extract-xiso-<VERSION>-macos.zip` - ZIP archive (signed app inside)
- `release/extract-xiso-<VERSION>-macos.dmg` - DMG disk image
- `release/checksums.txt` - SHA-256 checksums

Set `VERSION` in the script to match `Info.plist` (CFBundleShortVersionString); current is **0.1.4**.

### 2. Create GitHub Release

1. **Go to GitHub repository**
   - Navigate to your extract-xiso repository
   - Click on "Releases" tab
   - Click "Create a new release"

2. **Set Release Details**
   - **Tag version**: `v0.1.4` (match the app version in Info.plist)
   - **Release title**: e.g. `Extract-XISO GUI v0.1.4`
   - **Target**: Choose your branch (e.g. `main` or `master`)

3. **Add Release Description**
   Copy the content from `GITHUB-RELEASE.md` (update the version number to match the release).

4. **Upload Release Assets**
   Drag and drop these files from the `release/` directory:
   - `extract-xiso-<VERSION>-macos.zip`
   - `extract-xiso-<VERSION>-macos.dmg` (if built)
   - `checksums.txt`

5. **Release Options**
   - ☑️ Check "Set as the latest release" 
   - ☑️ Check "Set as a pre-release" if this is beta/testing
   - ☑️ Check "Create a discussion for this release" to allow feedback

6. **Publish Release**
   - Click "Publish release"
   - 🎉 Your release is live!

### 3. Post-Release

1. **Announce the release**:
   - Update repository README with GUI information
   - Consider posting to social media or forums
   - Update project documentation

2. **Monitor for issues**:
   - Watch for bug reports
   - Respond to user questions
   - Plan future improvements

## 📝 Release Checklist

Before creating the release, ensure:

- [ ] ✅ Code builds successfully on macOS
- [ ] ✅ GUI application launches and functions properly  
- [ ] ✅ CLI binary works correctly
- [ ] ✅ All files included in release package
- [ ] ✅ Documentation is up to date
- [ ] ✅ Version numbers are consistent
- [ ] ✅ License information is included
- [ ] ✅ Checksums are generated
- [ ] ✅ Release notes are written

## 🔄 For Future Releases

1. **Update version numbers** in:
   - `build-release.sh` and `build-github-release.sh` (VERSION variable)
   - `Info.plist` (CFBundleShortVersionString and CFBundleVersion)
   - `GITHUB-RELEASE.md` and other release documentation

2. **Update changelog/release notes** with:
   - New features
   - Bug fixes
   - Breaking changes
   - System requirement changes

3. **Test on different macOS versions** if possible (minimum is macOS 11.0)

4. **Use `./sign.sh`** (with `.env` configured) when building via `build-release.sh` so the packaged app is signed and notarized

---

**Tip**: Keep this file updated as you refine the release process!