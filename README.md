# Enabling SSH Access Control Using Github Repo Permissions (No Key File!)
The described technique is using some undocumented capabilities, everything is provided without any warranty, use with caution and at your own risk.

### Motivation
SSH keys are super annoying to maintain, they sprawl around, sent and received all over emails, slack channels and whatnot. It would be great if SSH access could be managed in a better way.

### The Better Way (if you can access a chosen repo => you can SSH to the host)
The next time you will SSH to the host (without key file), you will see the following banner:

![Github SSH Access Control Example](https://i.imgur.com/SKik3YO.png)

Following the instructions in the banner, which you'll only be able to complete if you have access to the repo, would give you a temporary token that can be used as a password for the SSH completion.

### How To Enable
1. Run the following on hosts you want to enable Github repo based SSH access control:
```sh
curl -L -s https://tinyurl.com/githubsshinit | sed 's/\r//' | sudo sh -s - <user> <repo>

(example: curl -L -s https://tinyurl.com/githubsshinit | sed 's/\r//' | sudo sh -s - root shaylevi2/ssh)
```

2. On the repo used for access control you'll need a file called "access.json" with the following content: `{"root":"root"}`

* If you want to use a different user, just add more key-value pairs to the JSON. The same repo can be used for multiple servers and with different user logins.

### How Does It Work?? (the interesting part)

We are leveraging [CyberDem0n/pam-oauth2](https://github.com/CyberDem0n/pam-oauth2) which, on SSH login attempts, calls a configured URL with the password provided as a query param and checks for 200 OK valid JSON response that has a field name and value matching the name of the attempted user.

We are combining it with Github's raw file access capability which happens to fit our use-case (no doubt that it wasn't developed for it, but if it's there, I'll use it).

Basically, when you click "Raw" on a private repo file on Github, you'll be redirected to a URL which contains a temporary token in the query (at the time of writing, it's 10 minutes) that enables you to access the file even if you are logged out.

Why Github? Github repo access is granular and can be easily gated with any SSO provider and Github are rather trusted in securely handling sensitive access tokens.

So the complete flow is pam-oauth2 SSH module performing curl "https&#8203;://raw.githubusercontent.com/[REPO]/main/access.json?token=[PASSWORD]" expecting to get a JSON response that has a key-value of the username used. This will only work if the password provided is a valid access token.

You can see the code here: [tinyurl.com/githubsshinit](https://tinyurl.com/githubsshinit), or on this repo: [shaylevi2/githubssh](https://github.com/shaylevi2/githubssh).

I think this is pretty cool!
