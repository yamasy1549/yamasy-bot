# Thanks
https://github.com/r7kamura/ruboty

# Settings

1. Install Redis:

    ```
    sudo apt-get update
    sudo apt-get -yV upgrade
    sudo apt-get install redis-server
    ```

  And check:

    ```
    redis-server -v
    redis-cli -v
    ```

2. Generate new Slack team
3. Visit `https://<team_name>.slack.com/admin/settings#gateways`, and Enable XMPP gateway (SSL only)
4. Generate Slack account of Ruboty, and invite him(her) to the team
5. Visit `https://<team_name>.slack.com/account/gateways`, and check Ruboty's XMPP Pass
6. Write on `.env` in your Ruboty repository:
    ```
    RUBOTY_ENV="production"

    SLACK_PASSWORD="<ruboty's_XMPP_Pass>"
    SLACK_ROOM="<room_name>"
    SLACK_TEAM="<team_name>"
    SLACK_USERNAME="<ruboty's_name>"

    REDIS_URL="redis://localhost:6379"

    DOCOMO_API_KEY="<docomo_dialogue_API>"

    YAHOO_APPID="<Yahoo_parse_API>"

    PUX_API_KEY="<PUX_detectFace_API>"
    PUX_REQUEST_DOMAIN="<PUX_deteceFace_domain>"
    ```

# API

- docomo 雑談対話API
  - https://dev.smt.docomo.ne.jp/?p=docs.api.page&api_name=dialogue&p_name=api_reference
  - req. Registrate docomo Developer support account and apply for the API
- Yahoo 日本語形態素解析API
  - http://developer.yahoo.co.jp/webapi/jlp/ma/v1/parse.html
  - req. Registrate Yahoo! Japan ID and registrate your app
- PUX 顔検出API
  - https://pds.polestars.jp/
  - req. Generate your account (including your name) and apply for the evaluation API version

# Usage

```
bundle exec ruboty --load ruboty-custom.rb --dotenv
```
![reply from Ruboty](https://raw.githubusercontent.com/yamasy1549/yamasy-bot/master/images/demo.png)
