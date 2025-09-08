# How to Create a GitHub Release

## 📋 Steps to Release

### 1. Build the Release
```bash
# Run the automated release build script
./build-release.sh
```

This creates:
- `release/extract-xiso-2.7.1-gui-macos.zip` - ZIP archive
- `release/extract-xiso-2.7.1-gui-macos.dmg` - DMG disk image  
- `release/checksums.txt` - SHA-256 checksums

### 2. Create GitHub Release

1. **Go to GitHub repository**
   - Navigate to your extract-xiso repository
   - Click on "Releases" tab
   - Click "Create a new release"

2. **Set Release Details**
   - **Tag version**: `v2.7.1-gui` 
   - **Release title**: `🎉 Extract-XISO GUI v2.7.1 - First GUI Release!`
   - **Target**: Choose your branch (usually `main` or `master`)

3. **Add Release Description**
   Copy the content from `GITHUB-RELEASE.md` or use this:

   ```markdown
   # 🎉 Extract-XISO GUI v2.7.1 - First GUI Release!

   We're excited to announce the **first GUI release** of Extract-XISO! This release adds a beautiful, native macOS application while maintaining all the power of the original command-line tool.

   ## ✨ What's New

   ### 🖥️ **Native macOS GUI Application**
   - **Double-clickable app** - Just double-click to launch!
   - **Native Cocoa interface** - Feels right at home on macOS
   - **All CLI modes supported**: Extract, Create, List, Rewrite
   - **File browser integration** - Easy point-and-click file selection
   - **Progress feedback** - Visual progress bars and status updates
   - **Real-time output** - See command results as they happen

   ## 🚀 **Quick Start**
   1. Download the ZIP or DMG below
   2. Double-click `Extract-XISO.app` to launch
   3. Or run `./extract-xiso -h` for CLI help

   ## 💻 **System Requirements**
   - macOS 10.10 (Yosemite) or later
   - Intel or Apple Silicon Mac

   ## 📦 **Downloads**
   - **ZIP Archive**: Smaller download, extract and use
   - **DMG Image**: Native macOS installer format
   - **Checksums**: For download verification

   Enjoy the new GUI! 🎊
   ```

4. **Upload Release Assets**
   Drag and drop these files from the `release/` directory:
   - `extract-xiso-2.7.1-gui-macos.zip`
   - `extract-xiso-2.7.1-gui-macos.dmg`  
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
   - `build-release.sh` (VERSION variable)
   - `Info.plist` (CFBundleShortVersionString)
   - Release documentation

2. **Update changelog/release notes** with:
   - New features
   - Bug fixes
   - Breaking changes
   - System requirement changes

3. **Test on different macOS versions** if possible

4. **Consider code signing** for future releases to avoid security warnings

---

**Tip**: Keep this file updated as you refine the release process!