# -*- coding: utf-8 -*-
from subprocess import call


class Container:
    """
    Docker container wrapper for executing commands and copying files.
    """
    def __init__(self, name: str):
        """
        Initialize container with given name.

        :param name: Container name
        """
        self.name = name

    def copy_to(self, src: str, dst: str) -> int:
        """
        Copy file from host to container.

        :param src: Source path on host
        :param dst: Destination path in container
        :return: Command exit code
        """
        return self._run(f"docker cp {src} {self.name}:{dst}")

    def copy_from(self, dst: str, src: str) -> int:
        """
        Copy file from container to host.

        :param dst: Source path in container
        :param src: Destination path on host
        :return: Command exit code
        """
        return self._run(f"docker cp {self.name}:{dst} {src}")

    def exec(self, command: str) -> int:
        """
        Execute command inside container.

        :param command: Command to execute
        :return: Command exit code
        """
        return self._run(f"docker exec -it {self.name} {command}")

    def _run(self, command: str) -> int:
        """
        Execute shell command.

        :param command: Shell command to execute
        :return: Command exit code
        """
        return call(command, shell=True)
