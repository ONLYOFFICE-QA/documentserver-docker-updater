import json
import requests
from typing import List, Dict
from os import makedirs
from os.path import join, dirname, realpath, isdir

MARKETPLACE = 'https://github.com/ONLYOFFICE/onlyoffice.github.io'
BRANCH = 'tree/master'
SDKJS_PLUGIN_SOURCE = 'sdkjs-plugins/content'

URL = f"{MARKETPLACE}/{BRANCH}/{SDKJS_PLUGIN_SOURCE}"
PLUGIN_LIST_PATH = join(dirname(realpath(__file__)),
                        'plugins-list-actual.json')
EXCLUDED_LIST_PATH = join(dirname(realpath(__file__)),
                          'excluded-plugins-list.json')


def read_json(path: str) -> List | Dict:
    with open(path, "r") as file:
        return json.load(file)


def write_json(path: str,
               data: 'dict | list',
               exclude: 'dict | list',
               mode: str = 'w') -> None:
    makedirs(dirname(path)) if not isdir(dirname(path)) else ...
    filtered_data = [el for el in data if el not in exclude]
    with open(path, mode) as file:
        json.dump(filtered_data, file, indent=4)
        file.write("\n")


def get_plugins() -> list:
    with requests.get(URL) as response:
        response.raise_for_status()
        return [item['name'] for item in
                json.loads(response.text)['payload']['tree']['items']]


if __name__ == "__main__":
    print(URL)
    write_json(PLUGIN_LIST_PATH,
               get_plugins(),
               read_json(EXCLUDED_LIST_PATH))
