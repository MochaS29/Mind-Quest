const fs = require('fs');
const path = require('path');

// Simple function to create a basic PNG header and solid color image
function createSolidColorPNG(width, height, r, g, b) {
  const PNG_SIGNATURE = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  
  // IHDR chunk
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 2; // color type (RGB)
  ihdr[10] = 0; // compression
  ihdr[11] = 0; // filter
  ihdr[12] = 0; // interlace
  
  // Create a simple RGB image data
  const imageData = Buffer.alloc(height * (width * 3 + 1));
  let pos = 0;
  for (let y = 0; y < height; y++) {
    imageData[pos++] = 0; // filter type
    for (let x = 0; x < width; x++) {
      imageData[pos++] = r;
      imageData[pos++] = g;
      imageData[pos++] = b;
    }
  }
  
  // Compress using zlib
  const zlib = require('zlib');
  const compressed = zlib.deflateSync(imageData);
  
  // CRC calculation (simplified - may not be perfect but should work for placeholders)
  function crc32(data) {
    let crc = 0xffffffff;
    for (let i = 0; i < data.length; i++) {
      crc = crc ^ data[i];
      for (let j = 0; j < 8; j++) {
        crc = (crc >>> 1) ^ (0xEDB88320 & (-(crc & 1)));
      }
    }
    return ~crc >>> 0;
  }
  
  // Build chunks
  function buildChunk(type, data) {
    const chunk = Buffer.alloc(data.length + 12);
    chunk.writeUInt32BE(data.length, 0);
    chunk.write(type, 4, 4, 'ascii');
    data.copy(chunk, 8);
    chunk.writeUInt32BE(crc32(Buffer.concat([Buffer.from(type, 'ascii'), data])), data.length + 8);
    return chunk;
  }
  
  const ihdrChunk = buildChunk('IHDR', ihdr);
  const idatChunk = buildChunk('IDAT', compressed);
  const iendChunk = buildChunk('IEND', Buffer.alloc(0));
  
  return Buffer.concat([PNG_SIGNATURE, ihdrChunk, idatChunk, iendChunk]);
}

// Purple color from the app theme
const purple = { r: 124, g: 58, b: 237 }; // #7C3AED

// Create placeholder PNGs
const icon = createSolidColorPNG(1024, 1024, purple.r, purple.g, purple.b);
const splash = createSolidColorPNG(1284, 2778, purple.r, purple.g, purple.b);
const favicon = createSolidColorPNG(48, 48, purple.r, purple.g, purple.b);

// Write files
const assetsDir = path.join(__dirname, 'assets');
fs.writeFileSync(path.join(assetsDir, 'icon.png'), icon);
fs.writeFileSync(path.join(assetsDir, 'splash.png'), splash);
fs.writeFileSync(path.join(assetsDir, 'adaptive-icon.png'), icon);
fs.writeFileSync(path.join(assetsDir, 'favicon.png'), favicon);

console.log('✅ PNG placeholder assets created successfully!');
console.log('These are solid purple placeholders. You can replace them with proper designs later.');