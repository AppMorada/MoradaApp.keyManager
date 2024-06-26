INFO_FLAG="[INFO]" 
TIME=$(date +%y%m%d%H%M%S%N)
FUNCTION_NAME=$1
FUNCTION_ID=$2

echo "${INFO_FLAG} Zipping dist folder"
mkdir ./"build-${TIME}"
cp -r ./dist/functions ./"build-${TIME}"
mv ./"build-${TIME}"/**/* ./"build-${TIME}"
rmdir ./"build-${TIME}"/functions

cd ./"build-${TIME}"

cp ../package.json .
cp ../pnpm-lock.yaml .

sed -i 's/dist\/functions\/index.js/index.js/' ./package.json
sed '8d' ./package.json >> ./package.tmp.json
rm ./package.json
mv ./package.tmp.json ./package.json

zip -r ./"${FUNCTION_NAME}".zip ./*

mkdir ./"${FUNCTION_NAME}-${FUNCTION_ID}"
mv ./"${FUNCTION_NAME}".zip ./"${FUNCTION_NAME}-${FUNCTION_ID}"

echo "${INFO_FLAG} Uploading zip file to ${BUCKET_PATH}"
gsutil -m cp -r ./"${FUNCTION_NAME}-${FUNCTION_ID}" ${BUCKET_PATH}

echo "${INFO_FLAG} Cleaning build dir"
cd ../
rm -rf ./"build-${TIME}"

