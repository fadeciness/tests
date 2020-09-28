#!/bin/bash

cat << EOG > poll_job.py
#!/usr/bin/python

import requests
import re
import sys
import json
import time

# secs for polling Jenkins API
#
QUEUE_POLL_INTERVAL = 2
JOB_POLL_INTERVAL = 20
OVERALL_TIMEOUT = int("$TIME_OUT") * 60
print(OVERALL_TIMEOUT)

# job specifics: should be passed in
auth_token = "jadmin:jadmin"
# 11dd475135fe68174981722587629950a6
jenkins_uri = "localhost:8080"
job_name = "jenkins-test"
build_token = "jadmin"
vers = "$1"

# start the build
#
start_build_url = 'http://{}@{}/job/{}/buildWithParameters?token={}&VERSION={}'.format(
        auth_token, jenkins_uri, job_name, build_token, vers)
print(start_build_url)
r = requests.post(start_build_url)

# from return headers get job queue location
#
m = re.match(r"http.+(queue.+)\/", r.headers['Location'])
if not m:
    # To Do: handle error
    print("Job starte request did not have queue location")
    sys.exit(1)

# poll the queue looking for job to start
#
queue_id = m.group(1)
job_info_url = 'http://{}@{}/{}/api/json'.format(auth_token, jenkins_uri, queue_id)
elasped_time = 0
print( '{} Job {} added to queue: {}'.format(time.ctime(), job_name, job_info_url))
while True:
    l = requests.get(job_info_url)
    jqe = l.json()
    task = jqe['task']['name']
    try:
        job_id = jqe['executable']['number']
        break
    except:
        #print( "no job ID yet for build: {}".format(task))
        time.sleep(QUEUE_POLL_INTERVAL)
        elasped_time += QUEUE_POLL_INTERVAL

    if (elasped_time % (QUEUE_POLL_INTERVAL * 10)) == 0:
        print( "{}: Job {} not started yet from {}".format(time.ctime(), job_name, queue_id))

# poll job status waiting for a result
#
job_url = 'http://{}@{}/job/{}/{}/api/json'.format(auth_token, jenkins_uri, job_name, job_id)
start_epoch = int(time.time())
while True:
    print( "{}: Job started URL: {}".format(time.ctime(), job_url))
    j = requests.get(job_url)
    jje = j.json()
    result = jje['result']
    if result == 'SUCCESS':
        # Do success steps
        print( "{}: Job: {} Status={}".format(time.ctime(), job_name, result))
        break
    elif result == 'FAILURE':
        # Do failure steps
        print( "{}: Job: {} Status={}".format(time.ctime(), job_name, result))
        break
    elif result == 'ABORTED':
        # Do aborted steps
        print( "{}: Job: {} Status={}".format(time.ctime(), job_name, result))
        break
    else:
        print( "{}: Job: {} Status={}. Polling again in {} secs".format(
                time.ctime(), job_name, result, JOB_POLL_INTERVAL))

    cur_epoch = int(time.time())
    if (cur_epoch - start_epoch) > OVERALL_TIMEOUT:
        print( "{}: No status before timeout of {} secs".format(OVERALL_TIMEOUT))
        sys.exit(1)

    time.sleep(JOB_POLL_INTERVAL)
EOG

python2 poll_job.py

isOne=""
isTwo=""
if [ -z "${isOne}" ] && [ -z "${isTwo}" ]
then
  job_status=$(python2 poll_job.py | grep "Status=" | tail -n 1 | cut -d '=' -f 2)
  [[ $job_status == "SUCCESS" ]] && echo "Has been compiled and uploaded to the NEXUS" || exit 100
  #echo $job_status
else
  echo "Had already been in the NEXUS"
fi
