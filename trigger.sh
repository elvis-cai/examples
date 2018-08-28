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

echo "Run the trigger"
curl --request POST \
  --url http://phil:0e104037dc5039fb33aab381ca0480c5@service-master-1.awx.im:8081/job/Backend-PR-pipeline/build \
  --header "${HKEY}:${HVAL}" \
  --data-urlencode json="{\"parameter\": [{\"name\":\"TAG\", \"value\":\"${DRONE_REPO_BRANCH}-${DRONE_BUILD_NUMBER}\"},{\"name\":\"DRONE_COMMIT\", \"value\": \"${DRONE_COMMIT}\"},{\"name\":\"DRONE_REPO\", \"value\": \"${DRONE_REPO}\"}]}"

echo "Triggered ......"
