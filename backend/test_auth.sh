#!/bin/bash

BASE=http://localhost:5000

# Register a user
curl -s -X POST $BASE/auth/register -H 'Content-Type: application/json' -d '{"name":"Test Admin","email":"admin@example.com","password":"password","role":"admin"}'

echo -e "\n\nLogin:\n"

# Login
TOKEN=$(curl -s -X POST $BASE/auth/login -H 'Content-Type: application/json' -d '{"email":"admin@example.com","password":"password"}' | jq -r '.token')

echo "Token: $TOKEN"

echo -e "\n\nCall admin ping:\n"

curl -s -H "Authorization: Bearer $TOKEN" $BASE/admin/ping

echo
