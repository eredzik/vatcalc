/wait
if [ -z "${API_URL}" ];
then
    export API_URL="http://localhost:1234/api/openapi.json";
    echo "Using default dev api path: ${API_URL}"
else
    export API_URL="${API_URL}/openapi.json"
    echo "Using set api path: ${API_URL}"
fi

rm -rf src/generated;
echo "Api path: ${API_URL}";
npx openapi-generator-cli generate -i ${API_URL} -g typescript-axios -o src/generated
npm run start;