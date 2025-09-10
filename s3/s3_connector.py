# -*- coding: utf-8 -*-
import argparse
from pathlib import Path
from tempfile import gettempdir

try:
    from .s3_config import S3Config
    from .docker import Container
except ImportError:
    import sys
    sys.path.append(str(Path(__file__).parent))
    from s3_config import S3Config
    from docker import Container


class S3Connector:
    """
    S3 connector for DocumentServer configuration management.
    """
    CONFIG_REMOTE_PATH = Path(
        "/etc/onlyoffice/documentserver/local-production-linux.json"
    )
    RESTART_COMMAND = "supervisorctl restart all"

    def __init__(self, container_name: str, config_path: str = None):
        """
        Initialize S3 connector.

        :param container_name: Name of the Docker container
        :param config_path: Path to custom config file
        """
        self.container_name = container_name
        self.config = S3Config(config_path)
        self.container = Container(container_name)
        self.tmp_dir = Path(gettempdir())

    def copy_config_to_container(self) -> int:
        """
        Copy S3 configuration file to DocumentServer container.

        :return: Command exit code
        """
        src = self.config.write_config()
        result = self.container.copy_to(src, self.CONFIG_REMOTE_PATH)
        self.delete(src)
        if result != 0:
            raise Exception("Failed to copy config to container")
        return result

    def restart_services(self) -> int:
        """
        Restart DocumentServer services in container.

        :return: Command exit code
        """
        result = self.container.exec(self.RESTART_COMMAND)
        if result != 0:
            raise Exception("Failed to restart services")
        return result

    def delete(self, path: str) -> int:
        """
        Delete file or directory at the given path.

        :param path: Path to file or directory to delete
        :return: Status code (0 for success)
        """
        path_obj = Path(path)
        if not path_obj.exists():
            return 0
        try:
            if path_obj.is_file():
                path_obj.unlink()
            elif path_obj.is_dir():
                path_obj.rmdir()
            return 0
        except (OSError, PermissionError) as e:
            raise Exception(f"Failed to delete {path}: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="S3 connector for DocumentServer"
    )
    parser.add_argument(
        "--name", default="DocumentServer",
        help="Container name (default: DocumentServer)"
    )
    parser.add_argument(
        "--no-restart", action="store_true",
        help="Skip restarting services"
    )
    args = parser.parse_args()

    print(
        f"Connecting s3 bucket to container: {args.name} "
        f"restart services: {args.no_restart}"
    )

    connector = S3Connector(container_name=args.name)
    connector.copy_config_to_container()
    if not args.no_restart:
        print("Restarting services")
        connector.restart_services()
