import os

from test_runner import BaseComponentTestCase
from qubell.api.private.testing import instance, workflow, values


class ComponentTestCase(BaseComponentTestCase):
    name = "component-haproxy"
    apps = [{
        "name": name,
        "file": os.path.join(os.path.dirname(__file__), '../%s.yml'.format(name))
    }]


    @instance(byApplication=name)
    @values({"lb-host": "host"})
    def test_port(self, instance, host):
        import socket

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex((host, 80))

        assert result == 0