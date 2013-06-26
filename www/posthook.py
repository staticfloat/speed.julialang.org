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
        
        # Save it out 'cause that's useful for debugging right now
        fd = open('output.txt', 'w')
        fd.write(data +"\n")

        # Parse the commit and branch
        data = urllib2.unquote(data)
        data = json.loads(data[8:]) # skip "payload="
        commit = data['commit']
        branch = data['branch']

        fd.write( "commit: %s, branch: %s\n"%(commit, branch) )
        fd.close()


        # Now, run benchmark.sh with those two arguments!
        subprocess.Popen(["../recipes/cook_recipes.sh", branch, commit])

application = app.wsgifunc()

