npm install

if [ -z "${API_URL}" ];
then
    export API_URL="http://localhost:1234/api/openapi.json";
    echo "Using default dev api path: ${API_URL}"
else
    export API_URL="$API_URL/openapi.json"
    echo "Using set api path: ${API_URL}"
fi

rm -rf .elm-spa;
npx elm-spa gen;
rm -rf .generated-api;
echo "Api path: ${API_URL}";
npx openapi-generator-cli generate -i ${API_URL} -g elm -o .generated-api
mv .generated-api/src/* .elm-spa/generated;
rm -rf .generated-api;
sed -E -i 's|basePath = "[A-Za-z\/:0-9]*"|basePath = "api"|g' .elm-spa/generated/Api.elm
npx webpack --mode production;