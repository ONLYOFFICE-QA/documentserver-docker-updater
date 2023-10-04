import json
import requests
from os import makedirs
from os.path import join, dirname, realpath, isdir

MARKETPLACE = 'https://github.com/ONLYOFFICE/onlyoffice.github.io'
BRANCH = 'tree/master'
SDKJS_PLUGIN_SOURCE = 'sdkjs-plugins/content'

URL = f"{MARKETPLACE}/{BRANCH}/{SDKJS_PLUGIN_SOURCE}"
PLUGIN_LIST_PATH = join(dirname(realpath(__file__)),
                        'plugins-list-actual.json')


def write_json(path: str, data: 'dict | list', mode: str = 'w') -> None:
    makedirs(dirname(path)) if not isdir(dirname(path)) else ...
    with open(path, mode) as file:
        json.dump(data, file, indent=4)
        file.write("\n")


def get_plugins() -> list:
    with requests.request('GET', URL, headers={}, data={}) as response:
        response.raise_for_status()
        return [item['name'] for item in
                json.loads(response.text)['payload']['tree']['items']]


if __name__ == "__main__":
    print(URL)
    write_json(PLUGIN_LIST_PATH, get_plugins())
