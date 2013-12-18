import os

import requests

from test_runner import BaseComponentTestCase
from qubell.api.private.testing import instance, workflow, values


class HAProxyComponentTestCase(BaseComponentTestCase):
    name = "component-haproxy"
    apps = [{
        "name": name,
        "file": os.path.realpath(os.path.join(os.path.dirname(__file__), '../%s.yml' % name))
    }]


    @instance(byApplication=name)
    @values({"lb-statistics-url": "url", "stats-user": "user", "stats-pass": "password"})
    def test_admin_page(self, instance, url, user, password):
        resp = requests.get(url, auth=(user, password), verify=False)

        assert resp.status_code == 200