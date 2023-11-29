/**
 * This function should be installed as an Azure Function with a HTTP trigger and configured as a GitHub webhook.
 * It expects the following environment variables to be set:
 * - GITHUB_APP_ID: the ID of the GitHub App used to authenticate
 * - GITHUB_APP_INSTALLATION_ID: the ID of the GitHub App installation
 * - GITHUB_APP_PRIVATE_KEY: the private key of the GitHub App
 * - GITHUB_WEBHOOK_SECRET: the secret used to sign the webhook
 * - GITHUB_WORKFLOW_ID: the ID of the workflow to trigger, this should be the id of the workflow `update-release-status.yml`
 */
const crypto = require('crypto');
const { Buffer } = require('buffer');
const https = require('https');

function encode(obj) {
    return Buffer.from(JSON.stringify(obj)).toString('base64url');
}

function createJwtToken() {

    const signingKey = crypto.createPrivateKey(Buffer.from(process.env['GITHUB_APP_PRIVATE_KEY'], 'base64'));

    const claims = {
        // Issue 60 seconds in the past to account for clock drift.
        iat: Math.floor(Date.now() / 1000) - 60,
        // The token is valid for 1 minutes
        exp: Math.floor(Date.now() / 1000) + (1 * 60),
        iss: process.env["GITHUB_APP_ID"]
    };

    const header = {
        alg: "RS256",
        typ: "JWT"
    };

    const payload = `${encode(header)}.${encode(claims)}`;
    const signer = crypto.createSign('RSA-SHA256');
    const signature = (signer.update(payload), signer.sign(signingKey, 'base64url'));

    return `${payload}.${signature}`;
}

function createAccessToken(context) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api.github.com',
            path: `/app/installations/${process.env["GITHUB_APP_INSTALLATION_ID"]}/access_tokens`,
            method: 'POST'
        };

        const req = https.request(options, (res) => {
            res.on('data', (data) => {
                const body = JSON.parse(data.toString('utf8'));
                access_token = body.token;
                //context.log(access_token);
                resolve(access_token);
            });

            res.on('error', (error) => {
                reject(error);
            })
        });

        req.setHeader('Accept', 'application/vnd.github+json');
        const token = createJwtToken();
        //context.log(`JWT Token ${token}`);
        req.setHeader('Authorization', `Bearer ${token}`);
        req.setHeader('X-GitHub-Api-Version', '2022-11-28');
        req.setHeader('User-Agent', 'CodeQL Coding Standards Automation');

        req.end();
    });
}

function triggerReleaseUpdate(context, access_token, head_sha) {
    context.log(`Triggering release update for head sha ${head_sha}`)
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api.github.com',
            path: `/repos/github/codeql-coding-standards/actions/workflows/${process.env["GITHUB_WORKFLOW_ID"]}/dispatches`,
            method: 'POST'
        };

        const req = https.request(options, (res) => {
            res.on('error', (error) => {
                reject(error);
            })
        });

        req.setHeader('Accept', 'application/vnd.github+json');
        req.setHeader('Authorization', `Bearer ${access_token}`);
        req.setHeader('X-GitHub-Api-Version', '2022-11-28');
        req.setHeader('User-Agent', 'CodeQL Coding Standards Automation');

        const params = {
            ref: 'main',
            inputs: {
                "head-sha": head_sha
            }
        };
        req.on('response', (response) => {
            context.log(`Received status code ${response.statusCode} with message ${response.statusMessage}`);
            resolve();
        });
        req.end(JSON.stringify(params));
    });
}

function listCheckRunsForRefPerPage(context, access_token, ref, page = 1) {
    context.log(`Listing check runs for ${ref}`)
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api.github.com',
            path: `/repos/github/codeql-coding-standards/commits/${ref}/check-runs?page=${page}&per_page=100`,
            method: 'GET',
            headers: {
                'Accept': 'application/vnd.github+json',
                'Authorization': `Bearer ${access_token}`,
                'X-GitHub-Api-Version': '2022-11-28',
                'User-Agent': 'CodeQL Coding Standards Automation'
            }
        };

        const req = https.request(options, (res) => {
            if (res.statusCode != 200) {
                reject(`Received status code ${res.statusCode} with message ${res.statusMessage}`);
            } else {
                var body = [];
                res.on('data', (chunk) => {
                    body.push(chunk);
                }); 
                res.on('end', () => {
                    try {
                        body = JSON.parse(Buffer.concat(body).toString('utf8'));
                        resolve(body);
                    } catch (error) {
                        reject(error);
                    }
                });
            }
        });
        req.on('error', (error) => {    
            reject(error);
        });

        req.end();
    });
}

async function listCheckRunsForRef(context, access_token, ref) {
    let page = 1;
    let check_runs = [];
    const first_page = await listCheckRunsForRefPerPage(context, access_token, ref, page);
    check_runs = check_runs.concat(first_page.check_runs);
    while (first_page.total_count > check_runs.length) {
        page++;
        const next_page = await listCheckRunsForRefPerPage(context, access_token, ref, page);
        check_runs = check_runs.concat(next_page.check_runs);
    }
    return check_runs;
}

function hasReleaseStatusCheckRun(check_runs) {
    return check_runs.some(check_run => check_run.name == 'release-status');
}

function isValidSignature(req) {
    const hmac = crypto.createHmac("sha256", process.env["GITHUB_WEBHOOK_SECRET"]);
    const signature = hmac.update(JSON.stringify(req.body)).digest('hex');
    const shaSignature = `sha256=${signature}`;
    const gitHubSignature = req.headers['x-hub-signature-256'];

    return !shaSignature.localeCompare(gitHubSignature);
}

module.exports = async function (context, req) {
    context.log('Webhook received.');

    if (isValidSignature(req)) {
        const event = req.headers['x-github-event'];

        if (event == 'check_run') {
            webhook = req.body;

            // To avoid infinite loops, we skip triggering the workflow for the following checkruns. 
            const check_runs_to_skip = [
                // check run created by manual dispatch of Update Release workflow
                'Update release',
                // check runs created by job in Update release status workflow
                'update-release',
                // when update-release calls reusable workflow Update release
                'update-release / Update release',
                'validate-check-runs',
                // check run that validates the whole release
                'release-status'];
            const update_release_actions = ['completed', 'rerequested'];

            if (update_release_actions.includes(webhook.action) && !check_runs_to_skip.includes(webhook.check_run.name)) {
                context.log(`Triggering update release status because ${webhook.check_run.name} received action ${webhook.action}`);

                try {
                    const access_token = await createAccessToken(context);
                    const check_runs = await listCheckRunsForRef(context, access_token, webhook.check_run.head_sha);
                    if (hasReleaseStatusCheckRun(check_runs)) {
                        context.log(`Release status check run found for ${webhook.check_run.head_sha}`);
                        await triggerReleaseUpdate(context, access_token, webhook.check_run.head_sha);
                    } else {
                        context.log(`Skippping, no release status check run found for ${webhook.check_run.head_sha}`);
                    }
                } catch (error) {
                    context.log(`Failed with error: ${error}`);
                }
            } else {
                context.log(`Skipping action ${webhook.action} for ${webhook.check_run.name}`)
            }
        } else {
            context.log(`Skipping event: ${event}`)
        }

        context.res = {
            status: 200
        };
    } else {
        context.log('Received invalid GitHub signature')
        context.res = {
            status: 401,
            body: 'Invalid x-hub-signature-256 value'
        };
    }
}