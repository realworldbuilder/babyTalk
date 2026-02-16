# Baby Talk

A voice-first baby tracking app for parents with newborns. Replace paper logs with simple voice commands - just say "fed the baby at 2am, nursed left side 15 minutes" and AI structures it into a clean daily log.

## Features

### Voice Recording
- Large, easy-to-use recording button optimized for 3am use
- OpenAI Whisper API for accurate transcription
- GPT-4o structures voice into proper log entries

### Smart Tracking
- **Feedings**: Nurse left/right, bottle feeding, amounts, duration
- **Sleep**: Sleep periods, total sleep tracking
- **Diapers**: Wet/dirty tracking
- **Notes**: General notes and observations

### Beautiful Interface
- Clean timeline view of daily activities
- Summary cards showing feeding count, sleep total, diaper count
- Calendar view for historical data
- Weekly summaries and patterns

### AI Chat Assistant
- Ask questions about baby care patterns
- Get insights about feeding/sleep schedules
- Helpful tips and guidance
- Always reminds to consult pediatrician for medical concerns

### Privacy & Data
- All data stored locally on device
- No cloud sync required
- Export functionality available
- Custom OpenAI API key support

## Technical Details

- **Platform**: iOS 17+
- **Framework**: SwiftUI with @Observable pattern
- **APIs**: OpenAI Whisper & GPT-4o
- **Storage**: Local JSON files
- **Audio**: AVFoundation recording

## Architecture

Based on the Momentary fitness tracking pattern but redesigned for baby care:

- Voice recording → Whisper transcription → GPT structure → Local storage
- Clean separation of models, services, and views
- Offline-first design with API calls only for AI processing

## Development

```bash
# Clone and build
git clone https://github.com/realworldbuilder/baby-talk.git
cd baby-talk/BabyTalk
xcodebuild -project BabyTalk.xcodeproj -scheme Momentary -destination 'generic/platform=iOS'
```

## License

All rights reserved. This is a commercial product.