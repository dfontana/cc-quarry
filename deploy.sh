#!/bin/zsh

set -e

API_TOKEN=$(<.gh-secret)
GH_GIST='d72ae5868a87adeb6345dbe6f041138d'

script="
import sys,json
data = sys.stdin.read()
print(json.dumps(data))
"

CCQ=`echo $(<cc-quarry.lua) | python -c "$script"`
CCQArg=`echo $(<api/cc-quarry-arguments.lua) | python -c "$script"`
CCQPrim=`echo $(<api/cc-quarry-primitives.lua) | python -c "$script"`
CCQUtil=`echo $(<api/cc-quarry-utils.lua) | python -c "$script"`

curl \
  -X PATCH \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: token $API_TOKEN" \
  "https://api.github.com/gists/$GH_GIST" \
  -d '{"files":{"ccq.lua":{"content":'$CCQ'},"ccqArg.lua":{"content":'$CCQArg'},"ccqPrim.lua":{"content":'$CCQPrim'},"ccqUtil.lua":{"content":'$CCQUtil'}}}'