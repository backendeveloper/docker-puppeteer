const puppeteer = require('puppeteer');

(async () => {

    const browser = await puppeteer.launch({
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox'
        ]
    });

    const page = await browser.newPage();

    await page.goto('https://www.sahibinden.com/ilan/emlak-konut-satilik-b.duzu-metrobuse-5dk-125m2-tertemiz-daire-iskanli-yeni-yapi-654470042/detay', { waitUntil: 'networkidle' });

    await page.evaluate(() => {
        Promise((resolve, reject) => {
            setInterval(() => {
                const featureArticle = document
                    .evaluate(
                        '//*[@id="classifiedDetail"]/div[1]/div[1]/h1',
                        document,
                        null,
                        XPathResult.FIRST_ORDERED_NODE_TYPE,
                        null
                    )
                    .singleNodeValue;

                if (featureArticle == null) {
                    console.log('Blocked!');
                    
                    resolve('Blocked!');
                    // return 'Blocked!';
                } else {
                    console.log(featureArticle.textContent);
                    resolve(featureArticle.textContent);
                    // return featureArticle.textContent;
                }
            }, 1000);
        });
    });

    // await page.screenshot({ path: 'google.png' });

    browser.close();

})();
