import web
import subprocess
import json
import urllib2

# This file, when properly configured with uwsgi and nginx, is invoked when Travis completes
# a successful build.  It then kicks off a compilation and benchmark run to calculate performance
# of that specific commit on this machine

urls = ('/.*', 'hooks')

app = web.application(urls, globals())

class hooks:
    def POST(self):
        data = web.data()
        
        # Parse the commit and branch
        data = urllib2.unquote(data)
        data = json.loads(data[8:]) # skip "payload="
        commit = data['commit']
        branch = data['branch']

        # Note, if you change the bash script to a different recipe_build_area, you must change this one too!
        open("/tmp/julia_recipe_build_area/incoming/%s"%(commit), "w").write(branch)

        # Now, run benchmark.sh with those two arguments!
        #subprocess.Popen(["../recipes/cook_recipes.sh", branch, commit])

application = app.wsgifunc()
