import json
import requests

MARKETPLACE = 'https://github.com/ONLYOFFICE/onlyoffice.github.io'
BRANCH = 'tree/master'
SDKJS_PLUGIN_SOURCE = 'sdkjs-plugins/content'

URL = f"{MARKETPLACE}/{BRANCH}/{SDKJS_PLUGIN_SOURCE}"

print(URL)

response = requests.request("GET", URL, headers={}, data={})

if response.status_code == 200:
    json_pl = json.loads(response.text)
    json_pl = json_pl['payload']['tree']['items']

    plugin_list = []
    for dict in json_pl:
        plugin_list.append(dict['name'])

    print(json.dumps(plugin_list))

    # Write JSON to a file
    with open('plugins-list-actual.json', 'w') as file:
        file.write(json.dumps(plugin_list))

else:
    print(f"Failed to fetch page. Status code: {response.status_code}")
