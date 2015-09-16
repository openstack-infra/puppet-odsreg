import os
import sys

path = '/usr/local/odsreg'
if path not in sys.path:
    sys.path.append(path)

os.environ['DJANGO_SETTINGS_MODULE'] = 'odsreg.settings'

import django.core.handlers.wsgi
application = django.core.handlers.wsgi.WSGIHandler()
