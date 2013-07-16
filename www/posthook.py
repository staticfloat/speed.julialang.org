import web
import subprocess
import json
import urllib2
from hashlib import sha256

# This is the travis token
from secret_key import *

# This file, when properly configured with uwsgi and nginx, is invoked when Travis completes
# a successful build.  It then kicks off a compilation and benchmark run to calculate performance
# of that specific commit on this machine

urls = ('/.*', 'hooks')
# These are the only branches we'll accept from Travis
whitelisted_branches = ['master', 'release-0.1'];

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
            open("/tmp/julia_recipe_build_area/incoming/%s"%(commit), "w").write(branch)

        open('/tmp/travis-request.txt', 'w').write(urllib2.unquote(web.data()))
        open('/tmp/travis-headers.txt', 'w').write(str(web.ctx.env))

application = app.wsgifunc()
