// smoke_test_game.js — Ken Bus Adventure smoke test
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  console.log('Opening Ken Bus Adventure...');
  await page.goto('https://niccolocoppo88.github.io/ken-bus-game/');
  await page.waitForLoadState('networkidle');
  
  // 1. Check title screen loads
  const avviaVisible = await page.locator('#avvia').isVisible();
  if (!avviaVisible) {
    console.error('FAIL: AVVIA button not visible');
    await browser.close();
    process.exit(1);
  }
  console.log('PASS: Title screen visible');
  
  // 2. Click AVVIA
  await page.click('#avvia');
  await page.waitForTimeout(1000);
  
  // 3. Verify game started (title screen hidden)
  const titleHidden = await page.evaluate(() => {
    const el = document.getElementById('titleScreen');
    return el && el.style.display === 'none';
  });
  if (!titleHidden) {
    console.error('FAIL: Game did not start after AVVIA click');
    await browser.close();
    process.exit(1);
  }
  console.log('PASS: Game started (state = playing)');
  
  // 4. Verify canvas renders
  const canvasVisible = await page.locator('canvas').isVisible();
  if (!canvasVisible) {
    console.error('FAIL: Canvas not visible');
    await browser.close();
    process.exit(1);
  }
  console.log('PASS: Canvas rendering');
  
  // 5. Verify kids counter visible (game is playing)
  const kidsCounter = await page.locator('#kidsTarget').isVisible();
  if (!kidsCounter) {
    console.error('FAIL: Kids counter not visible');
    await browser.close();
    process.exit(1);
  }
  console.log('PASS: Kids counter visible — game is playing');
  
  await browser.close();
  console.log('SMOKE TEST PASSED ✅');
  process.exit(0);
})();
