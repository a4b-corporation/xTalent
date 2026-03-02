const pptxgen = require('pptxgenjs');
const html2pptx = require('/Users/nguyenhuyvu/.gemini/antigravity/skills/pptx/scripts/html2pptx');
const path = require('path');

async function main() {
    const pptx = new pptxgen();
    pptx.layout = 'LAYOUT_16x9';
    pptx.author = 'xTalent Team';
    pptx.title = 'xTalent — Agentic Divide (Light)';

    const htmlFile = path.join(__dirname, 'slides', 'slide-agentic-divide.html');

    try {
        console.log('Converting slide-agentic-divide.html...');
        await html2pptx(htmlFile, pptx);
        console.log('✓ Success');
    } catch (e) {
        console.error('✗ Error:', e.message);
    }

    const outputPath = path.resolve(__dirname, '..', 'xTalent-Agentic-Divide.pptx');
    await pptx.writeFile({ fileName: outputPath });
    console.log(`Saved to: ${outputPath}`);
}

main().catch(console.error);
