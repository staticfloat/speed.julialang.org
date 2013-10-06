import web
import subprocess
import json
import urllib2
import logging
import os, os.path, errno
from hashlib import sha256

logger = logging.getLogger(__name__)

# This is the travis token
try:
    from secret_key import *
except:
    logger.warning( 'No secret key imported!  Ensure you have a secret_key.py file that sets TRAVIS_KEY in it for authentication purposes!' )

# This file, when properly configured with uwsgi and nginx, is invoked when Travis completes
# a successful build.  It then kicks off a compilation and benchmark run to calculate performance
# of that specific commit on this machine

# NOTE, if you change the recipe_build_area in common.sh, you will need to change it here as well!
INCOMING_DIR='~/tmp/julia_recipe_build_area/incoming/'

try:
    os.makedirs(INCOMING_DIR)
except OSError as exc:
    if exc.errno == errno.EEXIST and os.path.isdir(INCOMING_DIR):
        pass
    else:
        raise

urls = ('/.*', 'hooks')
# These are the only branches we'll accept from Travis
whitelisted_branches = ['master', 'release-0.2'];

app = web.application(urls, globals())

class hooks:
    def POST(self):
        data = web.data()
        
        # Parse the commit and branch
        data = urllib2.unquote(data)
        data = json.loads(data[8:]) # skip "payload="
        commit = data['commit']
        branch = data['branch']

        if branch in whitelisted_branches:
            # Note, if you change the bash script to a different recipe_build_area, you must change this one too!
            open(os.path.join(INCOMING_DIR,commit), "w").write(branch)

        open('/tmp/travis-request.txt', 'w').write(urllib2.unquote(web.data()))
        open('/tmp/travis-headers.txt', 'w').write(str(web.ctx.env))

application = app.wsgifunc()
