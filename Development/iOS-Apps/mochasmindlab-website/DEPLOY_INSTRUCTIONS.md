# Deployment Instructions for Mocha's MindLab Website

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `mochasmindlab-website`
3. Description: "Official website and privacy policy for Mocha's MindLab Inc. apps"
4. Set as Public
5. Don't initialize with README (we already have one)
6. Click "Create repository"

## Step 2: Push Local Repository

Once the repository is created, run these commands in Terminal:

```bash
cd /Users/mocha/Development/iOS-Apps/mochasmindlab-website
git push -u origin main
```

## Step 3: Deploy to Vercel (Recommended)

### Option A: Deploy with Custom Domain (mochasmindlab.com)

1. Go to https://vercel.com
2. Sign in with GitHub
3. Click "Import Project"
4. Select the `mochasmindlab-website` repository
5. Click "Deploy"
6. Once deployed, go to Settings → Domains
7. Add custom domain: `mochasmindlab.com`
8. Follow DNS configuration instructions

### Option B: Use Vercel's Free Domain

Your site will be available at: `https://mochasmindlab-website.vercel.app`

## Step 4: Alternative - GitHub Pages (Free)

1. Go to your GitHub repository
2. Settings → Pages
3. Source: Deploy from branch
4. Branch: main / root
5. Click Save

Your site will be available at: `https://[your-username].github.io/mochasmindlab-website/`

## URLs for App Store Submission

Once deployed, use these URLs in your App Store listing:

- **Privacy Policy URL**: `https://mochasmindlab.com/privacy.html`
- **Support URL**: `https://mochasmindlab.com` (or create a support page)
- **Marketing URL**: `https://mochasmindlab.com`

## Testing Your Privacy Policy URL

After deployment, verify the privacy policy is accessible:
```bash
curl -I https://mochasmindlab.com/privacy.html
```

Should return HTTP 200 OK

## Domain Configuration (if using custom domain)

### Vercel DNS Settings:
```
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

### Or Cloudflare/Other DNS:
Follow Vercel's custom domain setup guide at deployment time.

## Automatic Deployments

Once connected, any push to the main branch will automatically deploy:
```bash
git add .
git commit -m "Update privacy policy"
git push
```

## Contact Information in Privacy Policy

Current contact details in the privacy policy:
- **Company**: Mocha's MindLab Inc.
- **Privacy Email**: privacy@mochasmindlab.com
- **Safety Email**: safety@mochasmindlab.com
- **Support Email**: support@mochasmindlab.com
- **Address**: 244-1231 Pacific Blvd, Vancouver, BC V6Z 2E2
- **Phone**: 236-885-9577

---

Ready to deploy! The website includes both a landing page and the required privacy policy for App Store submission.