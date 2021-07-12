npm install

if [ -z ${URL}];
then
    if [-z ${API_URL}];
    then
        export API_PATH="http://localhost:1234/api/openapi.json";
        echo "Using default dev api path: ${API_PATH}"
    else
        echo "Using set api path: ${API_PATH}"
    fi
else
export API_PATH="${URL}/api/openapi.json";
echo "Using deployment api path: ${API_PATH}"
fi
rm -rf .elm-spa;
npx elm-spa gen;
rm -rf .generated-api;
echo "Api path: ${API_URL}"
npx openapi-generator-cli generate -i ${API_URL} -g elm -o .generated-api
mv .generated-api/src/* .elm-spa/generated;
rm -rf .generated-api;
npx webpack --mode production;