# Baby Talk Website Deployment Instructions

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `baby-talk`
3. Set as **Private** initially
4. Create repository

## Step 2: Push Website Files

```bash
cd /Users/williamhussey/.openclaw/workspace/repos/baby-talk
git remote add origin https://github.com/realworldbuilder/baby-talk.git
git push -u origin main
```

## Step 3: Make Repository Public & Enable GitHub Pages

```bash
# Make repository public
gh api repos/realworldbuilder/baby-talk -X PATCH -f visibility=public

# Enable GitHub Pages
gh api repos/realworldbuilder/baby-talk/pages -X POST -f build_type=legacy -f source='{"branch":"main","path":"/"}'
```

## Step 4: Verify Deployment

Your website will be available at:
**https://realworldbuilder.github.io/baby-talk/**

## What's Included

✅ **Landing Page (index.html)**
- Hero section with parent-focused messaging
- Pain point → Solution narrative
- Features showcase
- How it works (3 simple steps)
- Testimonial section
- Call-to-action for beta signup

✅ **Support Page (support.html)**
- Comprehensive FAQ covering voice recording, AI processing, privacy
- Transparent explanation of OpenAI usage
- Contact information
- Beta-specific guidance

✅ **Privacy Policy (privacy.html)**
- Required for App Store submission
- Transparent about OpenAI Whisper & GPT-4o usage
- Local data storage explanation
- No analytics/tracking policy
- Children's privacy compliance

✅ **Terms of Use (terms.html)**
- Medical disclaimers (crucial for baby app)
- "Not medical advice" warnings
- User responsibilities
- Beta terms and conditions
- Liability limitations

✅ **Styling (style.css)**
- Soft, calming theme for tired parents
- Soft blue (#5B9BD5) and warm white palette
- Inter font for readability
- Mobile-first responsive design
- Large text for sleep-deprived eyes
- Gentle shadows and rounded corners

## App Store Readiness

All pages are optimized for App Store submission:
- Privacy Policy clearly explains data collection
- Terms include medical disclaimers
- Contact information provided
- Professional, trustworthy design
- Bundle ID referenced: com.whussey.babytalk

## Custom Domain (Optional)

If you want a custom domain:
1. Add a CNAME file with your domain
2. Configure DNS settings
3. Enable custom domain in GitHub Pages settings