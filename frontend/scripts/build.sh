npm install
if [ -z ${URL}];
then export API_PATH="http://localhost:1234/api/openapi.json";
else export API_PATH="${URL}/api/openapi.json"; fi
rm -rf .elm-spa;
npx elm-spa gen;
rm -rf .generated-api;
echo "Api path: ${API_PATH}"
npx openapi-generator-cli generate -i ${API_PATH} -g elm -o .generated-api
mv .generated-api/src/* .elm-spa/generated;
rm -rf .generated-api;
npx webpack --mode production;