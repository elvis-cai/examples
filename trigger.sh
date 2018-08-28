#!/bin/sh

region=$(curl -s --connect-timeout 15 --max-time 30 100.100.100.200/latest/meta-data/region-id 2> /dev/null || true)
[ "$(echo ${region})" != "ap-southeast-2" ] && exit 0

RES=$(curl -X GET http://phil:0e104037dc5039fb33aab381ca0480c5@service-master-1.awx.im:8081/crumbIssuer/api/json)
echo $RES
HKEY=$(echo $RES | sed 's/[{}]/''/g' | tr -s "," "\n" | grep \"crumbRequestField\" | cut -d\" -f4)
echo $HKEY
HVAL=$(echo $RES | sed 's/[{}]/''/g' | tr -s "," "\n" | grep \"crumb\" | cut -d\" -f4)
echo $HVAL
DRONE_REPO_BRANCH=$(echo $DRONE_REPO_BRANCH | sed s_/_-_g)
echo $DRONE_REPO_BRANCH
echo $DRONE_BUILD_NUMBER
echo $DRONE_BUILD_EVENT

if [ -z "${DRONE_REPO_BRANCH##*develop*}" ]; then
  JENKINS_JOB_NAME='develop'
elif [ -z "${DRONE_REPO_BRANCH##*feature*}" ]; then
      JENKINS_JOB_NAME='core_services'
elif [ -z "${DRONE_REPO_BRANCH##*jenkins_integ*}" ]; then
  JENKINS_JOB_NAME='develop'
else
  JENKINS_JOB_NAME='qa'
fi

TRIGGER="curl --request POST \
  --url http://phil:0e104037dc5039fb33aab381ca0480c5@service-master-1.awx.im:8081/job/Backend-PR-pipeline/build \
  --header "Content-Type:application/x-www-form-urlencoded" \
  --header "${HKEY}:${HVAL}" \
  --data json=%7B%22parameter%22%3A%20%5B%7B%22name%22%3A%22TAG%22%2C%20%22value%22%3A%22%24%7BDRONE_REPO_BRANCH%7D-%24%7BDRONE_BUILD_NUMBER%7D%22%7D%2C%7B%22name%22%3A%22DRONE_COMMIT%22%2C%20%22value%22%3A%20%22%24%7BDRONE_COMMIT%7D%22%7D%2C%7B%22name%22%3A%22DRONE_REPO%22%2C%20%22value%22%3A%20%22%24%7BDRONE_REPO%7D%22%7D%5D%7D"


echo "Run the trigger"
RES=`$TRIGGER`
echo "Triggered ......"
