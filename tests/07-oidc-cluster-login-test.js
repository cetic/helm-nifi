const { it } = require('mocha')
const puppeteer = require ('puppeteer-core')
const expect = require('chai').expect

describe('NiFi Login via OIDC', () => {
    let browser
    let page

    before(async () => {
        browser = await puppeteer.connect({
          browserWSEndpoint: 'ws://'+process.env.K8SNODEIP+':'+process.env.K8SPORT,
          ignoreHTTPSErrors: true
        })
        page = await browser.newPage()
    })

    it('NiFi redirects to KeyCloak login page', async () => {
        let gotoSucceeded = false
        for ( let i = 0; ( i < 60 ) && ( ! gotoSucceeded ); i++ ) {
            try {
                await Promise.all([
                    page.goto(process.env.NIFIURL),
                    page.waitForNavigation(),
                    page.waitForNetworkIdle()
                ])
                gotoSucceeded = true
            }
            catch(err) {
                console.log("        Connection to "+process.env.NIFIURL+"failed: "+err.message+" ( try "+i.toString()+")")
                await page.waitForTimeout(5000)
                i++
            }
        }
        const pageTitle = await page.waitForSelector('h1[id="kc-page-title"]')
        const titleContent = await pageTitle.evaluate(el => el.textContent)
        expect(titleContent).to.include('Sign in to your account')
    }).timeout(30000)

    it('Get screenshot of Keycloak login page', async () => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/01-keycloak-redirect.png",
            fullPage: true
        })
    })

    it('nifi@example.com shown as logged in user', async () => {
        await page.type('input[id="username"]','nifi')
        await page.type('input[id="password"]','reallychangeme')
        await Promise.all([
            page.click('input[id="kc-login"]'),
            page.waitForNavigation(),
            page.waitForNetworkIdle()
        ])
        let messageContentSelector = await page.waitForSelector('div[id="message-content"]')
        let messageContent = await messageContentSelector.evaluate(el => el.textContent)
        // loop 30 times unless messageContent is empty
        for (let i = 0; ( i < 30 ) && ( messageContent != "" ); i++ ) {
            await Promise.all([
                page.reload(),
                page.waitForNavigation(),
                page.waitForNetworkIdle(),
                page.waitForTimeout(2000)
            ])
            messageContentSelector = await page.waitForSelector('div[id="message-content"]')
            messageContent = await messageContentSelector.evaluate(el => el.textContent)
            if ( messageContent != "") {
                console.log("        Message Content: "+messageContent+" ( try "+i.toString()+")")
            }
        }
        const currentUserElement = await page.waitForSelector('div[id="current-user"]')
        const userName = await currentUserElement.evaluate(el => el.textContent)
        expect(userName).to.equal('nifi@example.com')
    }).timeout(300000)

    it('Get screenshot of logged in user', async () => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/02-logged-in-user.png",
            fullPage: true
        })
    })

    it('All nodes connected', async () => {
        connectedNodesUserElement = await page.waitForSelector('span[id="connected-nodes-count"]')
        connectedNodesCount = await connectedNodesUserElement.evaluate(el => el.textContent )
        // loop 30 times unless connectedNodesCount isn't "3 / 3"
        for (let i = 0; ( i < 30 ) && ( connectedNodesCount != "3 / 3" ); i++ ) {
            console.log("        Connected Nodes Count: "+connectedNodesCount+" ( try "+i.toString()+")")
            await Promise.all([
                page.reload(),
                page.waitForNavigation(),
                page.waitForNetworkIdle(),
                page.waitForTimeout(2000)
            ])
            try {
                connectedNodesUserElement = await page.waitForSelector('span[id="connected-nodes-count"]', { timeout: 1000 })
                connectedNodesCount = await connectedNodesUserElement.evaluate(el => el.textContent )
            }
            catch(err) {
                connectedNodesCount = err.message
            }
        }
        expect(connectedNodesCount).to.equal('3 / 3')
    }).timeout(300000)

    it('Get screenshot of all nodes connected', async () => {
        await page.screenshot({
            path: process.env.HOME+"/screenshots/03-all-nodes-connected.png",
            fullPage: true
        })
    })
    after(async () => {
        await browser.close()
    })
})
