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

    plugin_names = []
    for dict in json_pl:
        plugin_names.append(dict['name'])

    pretty_json = json.dumps(plugin_names, indent=4)

    print(pretty_json)

    # Write JSON to a file
    with open('plugins-list-actual.json', 'w') as file:
        file.write(pretty_json)

else:
    print(f"Failed to fetch page. Status code: {response.status_code}")
