# Montager End-to-End Test Plan
## Step 7: End-to-end test with one real video folder

This document specifies the comprehensive test plan for validating the complete Montager AI Video Editor pipeline, fulfilling Step 7 of the development plan from the August 2nd recap.

## 🎯 Test Objective

Validate that all integrated systems work together correctly to process a real video folder from input to output using actual AI providers (Together AI with PrismML Ternary Bonsai 27B and/or Ollama Cloud), confirming that:
- All previously implemented components function in integration
- User privacy and data handling match disclosed practices
- Performance meets basic usability thresholds
- Output quality is sufficient for core use cases
- Error handling and recovery work appropriately

## 📋 Test Scope

This end-to-end test covers the complete user workflow:
```
Video Folder Input 
       ↓
[File System Access - Permissions Verified] 
       ↓
[Video Scanning & Metadata Extraction] 
       ↓
[Frame Extraction (1 per 1-3s)] 
       ↓
[Feature Extraction & Embedding Generation] 
       ↓
[Semantic Indexing & Storage (Drift Database)] 
       ↓
[AI Processing (Together AI/Ollama Cloud)] 
       ↓
[Edit Plan Generation] 
       ↓
[Video Rendering (FFmpeg)] 
       ↓
[Output Video Delivery] 
       ↓
[User Verification & Validation]
```

## 🧪 Test Environment Requirements

### Hardware
- **Minimum**: Modern smartphone or tablet (iOS/Android)
- **Recommended**: Device with at least 4GB RAM for smooth AI processing
- **Storage**: Minimum 2GB free space for test videos and processing
- **Network**: Stable internet connection (required for AI API calls)

### Software
- **Operating System**: 
  - iOS 14.0+ or Android 8.0+ (with preferred testing on Android 13+/iOS 15+)
- **App Version**: Latest build from development branch
- **Dependencies**: All required native libraries and frameworks linked

### Test Data
- **Video Folder**: One folder containing 3-5 diverse video clips (total 2-10 minutes duration)
- **Video Formats**: Mix of common formats (MP4, MOV, AVI) with varying:
  - Resolutions (720p, 1080p, 4K if supported)
  - Frame rates (24fps, 30fps, 60fps)
  - Content types (landscapes, people, action, indoor/outdoor)
  - Audio tracks (with/without speech, music, ambient sound)

## 📝 Test Cases

### TC-01: Application Launch & Initialization
**Objective**: Verify app starts correctly and initializes all systems

**Steps**:
1. Launch Montager application
2. Verify splash screen appears (if implemented)
3. Check home screen loads without errors
4. Verify no crash reports during startup
5. Confirm service initialization logs show:
   - Database connection established
   - API key manager ready
   - Video analysis service initialized
   - FFmpeg service available

**Pass Criteria**: App launches successfully with no errors in console/logs

### TC-02: Permission Handling & User Consent
**Objective**: Verify permission system works correctly and aligns with disclosures

**Steps**:
1. Attempt to add videos without granted permissions
2. Observe permission request dialogs appear
3. Verify permission explanations match those specified in:
   - iOS Info.plist (from Step 5 specification)
   - AndroidManifest.xml (from Step 5 specification)
4. Grant required permissions (media library access)
5. Verify app proceeds to video selection screen
6. Test denying permissions and verify graceful handling

**Pass Criteria**: 
- Permission dialogs show correct explanations
- App handles both grant and denial appropriately
- No crashes or infinite loops on permission denial

### TC-03: Video Folder Selection & Scanning
**Objective**: Verify video discovery and metadata extraction works

**Steps**:
1. Navigate to folder selection interface
2. Browse and select test video folder
3. Verify folder contents are scanned correctly
4. Confirm all video files are detected and listed
5. Check file metadata display (name, size, duration, format)
6. Verify unsupported files are filtered out appropriately
7. Test with nested folder structures (if recursive search implemented)

**Pass Criteria**: 
- All valid video files detected and displayed
- Accurate file information shown
- Invalid/non-video files properly ignored
- Reasonable scan time (< 10 seconds for typical folder)

### TC-04: Video Analysis Pipeline (Core AI Functionality)
**Objective**: Verify the complete video analysis and processing workflow

**Steps**:
1. Select test video folder for processing
2. Enter descriptive prompt (e.g., "Create a 60-second highlight showing the best action moments")
3. Choose AI Provider (Together AI recommended for first test)
4. Confirm API key is configured and valid (from Step 4 implementation)
5. Start processing job
6. Monitor progress through all stages:
   - Video scanning & validation
   - Frame extraction (verify 1 per 1-3s rate achieved)
   - Feature extraction & embedding generation
   - Database storage of embeddings (verify Drift integration)
   - AI processing request sent (verify network activity)
   - AI response received and parsed
   - Edit plan generation
   - Video rendering via FFmpeg
   - Output file creation and validation

**Pass Criteria**:
- Process completes without crashing
- Each stage logs appropriate progress
- Final output video created in specified location
- Processing time reasonable for input size (aim for < 5x real-time)
- Output video plays correctly and contains edited content

### TC-05: AI Provider Functionality Verification
**Objective**: Verify both supported AI providers work correctly

**Sub-test A: Together AI with PrismML Ternary Bonsai 27B**
1. Configure Together AI as active provider
2. Verify API key is securely stored and retrieved
3. Process a short test video (30-60 seconds)
4. Confirm requests sent to `https://api.together.xyz/v1`
5. Validate responses contain expected JSON structure
6. Check that processing uses specified model
7. Verify output reflects AI-generated edit decisions

**Sub-test B: Ollama Cloud (Optional/Alternate)**
1. Configure Ollama Cloud as active provider  
2. Verify API key handling
3. Process same/similar test video
4. Confirm requests sent to Ollama Cloud endpoint
5. Validate response format and timing
6. Compare results with Together AI for consistency

**Pass Criteria**:
- Both providers can be selected and used
- API calls succeed with valid responses
- Processing completes without authentication errors
- Output videos generated (quality may differ between providers)
- App handles provider switching correctly

### TC-06: Output Quality & Relevance Validation
**Objective**: Verify that the AI-produced edits are relevant to user prompts

**Steps**:
1. Process test video with specific, measurable prompt
   - Example: "Extract all scenes containing spoken words and create a 30-second montage"
   - Example: "Find all beach/ocean scenes and make a calming seascape video"
   - Example: "Create a fast-paced montage of action sequences with quick cuts"
2. Review output video for relevance to prompt
3. Check that:
   - Requested duration is approximately honored (±20% tolerance acceptable)
   - Content matches semantic intent of prompt
   - Transitions are smooth and appropriate
   - Audio-visual sync is maintained
   - No major glitches or corruption present

**Pass Criteria**:
- Output video addresses the core request in the prompt
- Technical quality sufficient for basic viewing
- Editing decisions demonstrate AI understanding of content
- No unwarranted distortions or artifacts

### TC-07: Error Handling & Recovery
**Objective**: Verify app handles errors gracefully and provides useful feedback

**Steps**:
1. Test with invalid/missing API key
   - Verify appropriate error message displayed
   - Confirm app doesn't crash
   - Check that user can re-enter correct key
2. Test with poor network connectivity
   - Verify timeout handling and retry options
   - Check offline behavior and messaging
3. Test with corrupted video file
   - Verify graceful skipping or error reporting
   - Ensure other files in folder still process
4. Test with insufficient storage space
   - Verify appropriate warning before failure
   - Check cleanup of partial files

**Pass Criteria**:
- App never crashes or becomes unresponsive
- Error messages are clear and actionable
- Recovery paths exist for common failure modes
- Partial results preserved when possible
- User guided toward resolution rather than left confused

### TC-08: Performance & Resource Usage
**Objective**: Verify app performs acceptably on target devices

**Measurements**:
- **Startup Time**: < 3 seconds from launch to usable interface
- **Memory Usage**: < 200MB steady state during processing
- **Battery Impact**: Reasonable drain for processing task (test 10min video)
- **Thermal Impact**: No excessive heating during normal use
- **Processing Speed**: Aim for real-time or better for simple edits
- **Storage Usage**: Temporary cleanup verified; permanent storage minimal

**Pass Criteria**:
- Resource usage within acceptable bounds for mobile application
- No sustained memory leaks observed
- Performance does not render core features unusable
- Thermal behavior within normal device operating ranges

### TC-09: Privacy Compliance Verification
**Objective**: Confirm actual data handling matches privacy disclosures

**Verification Points**:
1. **Video Data**: Confirm original videos never leave device without consent
   - Use network monitoring to verify only metadata/embeddings sent to AI
   - Check that full video frames are not transmitted or stored externally
2. **API Key Security**: Verify keys stored in secure enclave (Keystore/Keychain)
3. **Temporary Files**: Confirm processing artifacts cleaned up after use
4. **Database Content**: Verify only metadata and embeddings stored, not raw video
5. **Analytics**: Confirm no data sent without explicit opt-in (if implemented)
6. **Permissions**: Validate that only declared permissions are requested and used

**Pass Criteria**:
- No unauthorized data exfiltration detected
- Storage practices match privacy policy claims
- Temporary data properly managed
- User consent properly implemented and respected

### TC-10: User Experience & Accessibility
**Objective**: Verify basic usability and accessibility standards

**Checks**:
- Touch targets minimum 48x48dp
- Text readable at standard sizes
- Color contrast meets WCAG AA guidelines
- Navigation logical and predictable
- Loading states provided for long operations
- Error states clearly communicated
- App responds appropriately to device orientation changes
- Back navigation works predictably
- Accessibility labels present for key elements (if implemented)

**Pass Criteria**:
- Basic usability standards met
- No obvious accessibility blockers
- Interface intuitive for target user base
- Feedback provided for user actions

## 📊 Success Criteria

### Minimum Viable Product (MVP) Threshold
The end-to-end test passes if:
1. **Core Functionality Works**: Users can successfully process a video folder using at least one AI provider
2. **No Critical Bugs: No crashes, data loss, or security vulnerabilities discovered  
3. **Privacy Compliant**: Actual behavior matches privacy disclosures
4. **Basic Quality**: Output videos are watchable and demonstrate AI-assisted editing
5. **Recovery Possible**: Users can recover from common error states

### Enhanced Quality Benchmarks (Goals)
- **Processing Efficiency**: < 3x real-time for typical edits
- **User Satisfaction**: Average tester rating ≥ 4/5 for core experience
- **Feature Completeness**: All primary user journeys functional
- **Error Gracefulness**: < 5% of test cases result in unrecoverable failure
- **Performance Consistency**: < 2x variance in processing time for similar inputs

## 📋 Test Execution Guidelines

### Preparation
1. **Backup**: Backup any important device data before testing
2. **Clear State**: Ensure app starts with clean state (fresh install orce
3. **Test Data Preparation
   - Gather 3-5 diverse video clips totaling 2-10 minutes
   - Include varied content: landscapes, people speaking, action scenes, indoor/outdoor
   - Ensure you have rights to use/test with this content
   - Verify files are not corrupted and play correctly
3. **Environment Setup**:
   - Ensure device has minimum 50% battery
   - Connect to reliable Wi-Fi network
   - Close background apps to free resources
   - Verify date/time settings correct (for SSL certificates)
4. **Account & Keys**:
   - Obtain valid Together AI API key (free tier sufficient)
   - Verify key has sufficient quota for test processing
   - Configure in app via secure settings
   - Optional: Set up Ollama Cloud account for alternative testing

### Execution Procedure
1. **Install**: Fresh install of latest development build
2. **Launch**: Open app and complete any onboarding
3. **Configure**: Set up AI provider and enter API key
4. **Test**: Execute test cases TC-01 through TC-10 in order
5. **Document**: Record results, timing, observations, and any issues
6. **Cleanup**: Remove test videos and app data after completion
7. **Report**: Summarize findings and recommend readiness for release

### Reporting Format
For each test case, record:
- **Test ID**: TC-XX
- **Status**: PASS/FAIL/BLOCKED
- **Evidence**: Screenshots, logs, measurements
- **Issues**: Detailed description of any problems
- **Root Cause**: Preliminary analysis if failure occurred
- **Recommendation**: Suggested fix or mitigation
- **Time Stamp**: When test was executed

## 🚪 Exit Criteria

### Ready for Release Candidate
The feature set is ready for release candidate when:
1. **All Critical Paths Functional**: Core video processing works reliably
2. **No Show-Stopper Bugs**: No crashes, data loss, or security flaws
3. **Privacy Verified**: Actual practices match stated policy
4. **Basic Quality Acceptable**: Output demonstrates core value proposition
5. **Recovery Adequate**: Users can recover from common issues
6. **Compliance Met**: Meets platform store submission requirements

### Continuous Improvement Items
Items identified during testing that should be tracked for future versions:
- Performance optimization opportunities
- Additional error handling cases
- User experience refinements
- Feature enhancement suggestions
- Localization and internationalization considerations
- Advanced AI model integration possibilities

## 📎 Appendices

### Appendix A: Sample Test Video Characteristics
Recommended properties for effective testing:
- **Duration**: 30-300 seconds per clip (total 2-15 minutes)
- **Resolution**: 720p minimum, 1080p ideal
- **Frame Rate**: 24fps, 30fps, or 60fps
- **Content Variety**:
  - Speaking person (for audio/narrative testing)
  - Moving objects/action (for motion detection testing)
  - Static scenes (for scene change detection testing)
  - Indoor/outdoor lighting variations
  - With and without background music
- **Codecs**: H.264, H.265, MPEG-4 (common mobile formats)

### Appendix B: Expected Processing Times (Reference)
Approximate times for 2-minute 1080p30 video:
- **Frame Extraction**: 10-30 seconds
- **Feature Extraction**: 15-45 seconds (model dependent)
- **AI API Call**: 5-30 seconds (network + processing dependent)
- **Edit Generation**: 2-10 seconds
- **Video Rendering**: 20-60 seconds (depends on edit complexity)
- **TOTAL**: 52-180 seconds (roughly 0.4x to 1.5x real-time)

### Appendix C: Troubleshooting Common Issues
| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| App crashes on launch | Missing native library | Verify all framework linkages |
| "No videos found" | Permission not granted | Check and request media access |
| Processing fails at AI step | Invalid/expired API key | Renew or re-enter API key |
| Very slow processing | Poor network or device limitations | Test on better connection/device |
| Output video corrupted | FFmpeg incompatibility | Verify codec support and settings |
| App overheats | Intensive processing on weak device | Limit video size/resolution |
| Storage full errors | Temp files not cleared | Check cleanup routines and permissions |

### Appendix D: Acceptable Quality Thresholds
For determining if output video is "sufficiently good":
- **Visual**: Clearly watchable, no major blocking/artifacts
- **Audio**: Synchronized, understandable if speech present
- **Relevance**: Clearly addresses the semantic intent of the prompt
- **Duration**: Within reasonable range of requested length
- **Engagement**: Demonstrates editing decisions beyond random cuts
- **Stability**: Plays start-to-finish without freezing/crashing

## ✅ CONCLUSION

This test plan provides everything needed to execute **Step 7** of the Montager development plan:
> "7. End-to-end test with one real video folder"

The plan ensures comprehensive validation of:
- Technical functionality and integration
- User experience and interface quality  
- Performance and resource efficiency
- Security and privacy compliance
- Error handling and recovery mechanisms
- Readiness for production use and app store submission

With this test plan in place, the development team can systematically verify that all previously implemented components (AI providers, frame extraction, semantic search, API key security, permissions, and privacy disclosures) work together correctly to deliver the promised AI video editing experience.

Upon successful completion of this end-to-end test, the Montager application will be ready for consideration as a release candidate, having demonstrated that the integrated system meets the core requirements specified in the original project vision and development plan.