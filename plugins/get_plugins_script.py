import json
import requests
from typing import List, Dict
from os import makedirs
from os.path import join, dirname, realpath, isdir

REALPATH = dirname(realpath(__file__))

MARKETPLACE = 'https://github.com/ONLYOFFICE/onlyoffice.github.io'
BRANCH = 'tree/master'
SDKJS_PLUGIN_SOURCE = 'sdkjs-plugins/content'

URL = f"{MARKETPLACE}/{BRANCH}/{SDKJS_PLUGIN_SOURCE}"
PLUGIN_LIST_PATH = join(REALPATH, 'plugins-list-actual.json')
EXCLUDED_LIST_PATH = join(REALPATH, 'excluded-plugins-list.json')


def read_json(path: str) -> List or Dict:
    with open(path, "r") as file:
        return json.load(file)


def write_json(
        path: str,
        data: List or Dict,
        mode: str = 'w'
) -> None:
    makedirs(dirname(path)) if not isdir(dirname(path)) else None
    with open(path, mode) as file:
        json.dump(data, file, indent=4)
        file.write("\n")


def get_plugins() -> List or Dict:
    with requests.get(URL) as response:
        response.raise_for_status()
        return [item['name'] for item in
                json.loads(response.text)['payload']['tree']['items']]


if __name__ == "__main__":
    print(URL)
    filtered_data = [el for el in get_plugins() if
                     el not in read_json(EXCLUDED_LIST_PATH)]
    write_json(PLUGIN_LIST_PATH, filtered_data)
