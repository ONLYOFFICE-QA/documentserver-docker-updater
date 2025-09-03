# -*- coding: utf-8 -*-
import json
from pathlib import Path
from tempfile import gettempdir


class S3Config:
    """
    S3 configuration manager for handling base config and credentials.
    """
    BASE_CONFIG_JSON = Path(__file__).parent / "base_config.json"
    CONFIG_DIR = Path().home() / ".s3_config"
    ENDPOINT = CONFIG_DIR / "endpoint"
    ACCESS_KEY_ID = CONFIG_DIR / "accessKeyId"
    SECRET_ACCESS_KEY = CONFIG_DIR / "secretAccessKey"

    def __init__(self, config_path: str = None):
        """
        Initialize S3 configuration.

        :param config_path: Path to custom config file, defaults to base config
        """
        self.config_path = (
            Path(config_path) if config_path else self.BASE_CONFIG_JSON
        )
        self.tmp_dir = Path(gettempdir())
        self.__base_config = None
        self.__endpoint = None
        self.__access_key_id = None
        self.__secret_access_key = None

    def generate_config(self) -> dict:
        """
        Get complete S3 configuration with base config and credentials.

        :param: None
        :return: Complete S3 configuration dictionary
        """
        config = self.base_config.copy()
        config["storage"]["endpoint"] = self._endpoint
        config["storage"]["accessKeyId"] = self._access_key_id
        config["storage"]["secretAccessKey"] = self._secret_access_key
        return config

    def write_config(self, path: str = None) -> str:
        """
        Write S3 configuration to JSON file.

        :param path: Output file path, defaults to temp directory
        :return: Path to the written config file
        """
        path = path or self.tmp_dir / "s3_config.json"
        with open(path, "w") as file:
            json.dump(self.generate_config(), file, indent=4)
        return path

    @property
    def base_config(self) -> dict:
        """
        Get base configuration from JSON file.

        :return: Base configuration dictionary
        """
        if self.__base_config is None:
            self.__base_config = json.loads(
                self._read_file(self.config_path, "Base config file")
            )
        return self.__base_config

    @property
    def _endpoint(self) -> str:
        """
        Get S3 endpoint from file.

        :return: S3 endpoint URL
        """
        if self.__endpoint is None:
            self.__endpoint = self._read_file(self.ENDPOINT, "Endpoint file")
        return self.__endpoint

    @property
    def _access_key_id(self) -> str:
        """
        Get S3 access key ID from file.

        :return: S3 access key ID
        """
        if self.__access_key_id is None:
            self.__access_key_id = self._read_file(
                self.ACCESS_KEY_ID, "Access Key ID file"
            )
        return self.__access_key_id

    @property
    def _secret_access_key(self) -> str:
        """
        Get S3 secret access key from file.

        :return: S3 secret access key
        """
        if self.__secret_access_key is None:
            self.__secret_access_key = self._read_file(
                self.SECRET_ACCESS_KEY, "Secret Access Key file"
            )
        return self.__secret_access_key

    def _read_file(self, file_path: Path,
                   file_description: str = "File") -> str:
        """
        Read file content with validation that file exists and is not empty.

        :param file_path: Path to the file to read
        :param file_description: Description of the file for error messages
        :return: File content as string
        """
        if not file_path.exists():
            raise FileNotFoundError(
                f"{file_description} not found: {file_path}"
            )

        if not file_path.is_file():
            raise ValueError(f"{file_description} is not a file: {file_path}")

        content = file_path.read_text().strip()
        if not content or file_path.stat().st_size == 0:
            raise ValueError(f"{file_description} is empty: {file_path}")
        return content
