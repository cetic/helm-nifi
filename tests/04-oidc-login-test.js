const puppeteer = require ('puppeteer-core')
const expect = require('chai').expect

describe('NiFi Login via OIDC', () => {
    let browser
    let page

    before(async () => {
        browser = await puppeteer.connect({
          browserWSEndpoint: 'ws://browserless.default.svc.cluster.local:3000',
          ignoreHTTPSErrors: true
        })
        page = await browser.newPage()
    })

    it('NiFi redirects to KeyCloak login page', async () => {
        await page.goto('https://nifi.default.svc.cluster.local:8443/nifi/');
        await page.waitForNavigation()
        const pageTitle = await page.waitForSelector('h1[id="kc-page-title"]')
        const titleContent = await pageTitle.evaluate(el => el.textContent)
        expect(titleContent).to.include('Sign in to your account')
    }).timeout(10000)

    it('nifi@example.com shown as logged in user', async () => {
        await page.type('input[id="username"]','nifi')
        await page.type('input[id="password"]','reallychangeme')
        await page.click('input[id="kc-login"]')
        await page.waitForNavigation()
        const currentUserElement = await page.waitForSelector('div[id="current-user"')
        const userName = await currentUserElement.evaluate(el => el.textContent)
        expect(userName).to.equal('nifi@example.com')
    }).timeout(10000)

    after(async () => {
        await browser.close()
    })
})
