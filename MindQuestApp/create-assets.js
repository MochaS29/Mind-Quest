const fs = require('fs');
const path = require('path');

// Create a simple SVG placeholder icon
const iconSVG = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#7C3AED"/>
  <text x="512" y="512" text-anchor="middle" dominant-baseline="middle" 
        font-family="Arial, sans-serif" font-size="400" fill="white">
    🧙‍♂️
  </text>
  <text x="512" y="750" text-anchor="middle" 
        font-family="Arial, sans-serif" font-size="80" fill="white">
    Mind Labs Quest
  </text>
</svg>`;

// Create a simple splash screen SVG
const splashSVG = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="1284" height="2778" viewBox="0 0 1284 2778" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#7C3AED;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#4C1D95;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="1284" height="2778" fill="url(#grad)"/>
  <text x="642" y="1200" text-anchor="middle" dominant-baseline="middle" 
        font-family="Arial, sans-serif" font-size="300" fill="white">
    🧙‍♂️
  </text>
  <text x="642" y="1600" text-anchor="middle" 
        font-family="Arial, sans-serif" font-size="80" font-weight="bold" fill="white">
    Mind Labs Quest
  </text>
  <text x="642" y="1700" text-anchor="middle" 
        font-family="Arial, sans-serif" font-size="50" fill="rgba(255,255,255,0.8)">
    Your ADHD Adventure Awaits
  </text>
</svg>`;

// Create a simple favicon SVG
const faviconSVG = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="48" height="48" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
  <rect width="48" height="48" fill="#7C3AED" rx="8"/>
  <text x="24" y="28" text-anchor="middle" dominant-baseline="middle" 
        font-family="Arial, sans-serif" font-size="24" fill="white">
    🧙
  </text>
</svg>`;

// Ensure assets directory exists
const assetsDir = path.join(__dirname, 'assets');
if (!fs.existsSync(assetsDir)) {
  fs.mkdirSync(assetsDir);
}

// Write the SVG files
fs.writeFileSync(path.join(assetsDir, 'icon.svg'), iconSVG);
fs.writeFileSync(path.join(assetsDir, 'splash.svg'), splashSVG);
fs.writeFileSync(path.join(assetsDir, 'favicon.svg'), faviconSVG);

console.log('SVG placeholder assets created! You\'ll need to convert these to PNG files.');
console.log('\nTo convert to PNG, you can:');
console.log('1. Open each SVG in a browser and save as PNG');
console.log('2. Use an online converter like cloudconvert.com');
console.log('3. Use Preview on Mac: Open SVG → File → Export → Format: PNG');
console.log('\nRequired files:');
console.log('- icon.svg → icon.png (1024x1024)');
console.log('- splash.svg → splash.png (1284x2778)');
console.log('- icon.svg → adaptive-icon.png (1024x1024)');
console.log('- favicon.svg → favicon.png (48x48)');