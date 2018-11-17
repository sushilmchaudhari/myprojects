#!/bin/bash
# curently works in the following regions due to the combination of ETS and
# Step Functions
#EU (Ireland)
#Asia Pacific (Tokyo)
#US East (N. Virginia)
#US West (Oregon)
# Asia Pacific (Sydney)

# Check to see if input has been provided:
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Please provide the base source bucket name and version where the lambda code will eventually reside."
    echo "For example: ./build-s3-dist.sh solutions v1.0.0"
    exit 1
fi

mkdir -p dist/$2

echo "copy cfn template to dist/$2"
cp ../cloudFormation_templates/msri-vod-cf-template.yaml dist/$2/video-on-demand-media-convert.template


# export BUCKET_PREFIX=solutions-test
# if [ $1 = "solutions-master" ]; then
#     export BUCKET_PREFIX=solutions
# fi
bucket="s/CODEBUCKET/$1/g"
sed -i -e $bucket dist/$2/video-on-demand-media-convert.template

bucket="s/CODEVERSION/$2/g"
sed -i -e $bucket dist/$2/video-on-demand-media-convert.template

echo "zip and copy source files to dist/$2/"

#find ../source -name "node_modules" -exec rm -rf "{}" \;
echo "zip and copy custom-resources to dist/$2"
cd ../source/custom-resources
#npm install --production
zip -qr ../../deployment/dist/$2/custom-resources.zip *

echo "zip and copy Dynamo to dist/$2/"
cd ../dynamo
#npm install --production
zip -qr ../../deployment/dist/$2/dynamo.zip *

echo "zip and copy error-handler to dist/$2/"
cd ../error-handler
#npm install --production
zip -qr ../../deployment/dist/$2/error-handler.zip *

echo "zip and copy ingest to dist/$2/"
cd ../ingest
#npm install --production
zip -qr ../../deployment/dist/$2/ingest.zip *

echo "zip and copy process to dist/$2/"
cd ../process
#npm install --production
zip -qr ../../deployment/dist/$2/process.zip *

echo "zip and copy publish to dist/$2/"
cd ../publish
#npm install --production
zip -qr ../../deployment/dist/$2/publish.zip *

echo "zip and copy sns to dist/$2/"
cd ../sns
#npm install --production
zip -qr ../../deployment/dist/$2/sns.zip *

echo "zip and copy mediainfo to dist/$2/"
cd ../mediainfo
#npm install --production
#cd bin
#wget http://mediaarea.net/download/binary/mediainfo/0.7.84/MediaInfo_CLI_0.7.84_GNU_FromSource.tar.xz
#tar xf MediaInfo_CLI_0.7.84_GNU_FromSource.tar.xz
#cd MediaInfo_CLI_GNU_FromSource/
#./CLI_Compile.sh --with-libcurl
#mv ./MediaInfo/Project/GNU/CLI/mediainfo ../
#cd ../..
#chmod 755 ./bin/mediainfo
#./bin/mediainfo --version
#rm -rf ./bin/MediaInfo_CLI*
zip -qr ../../deployment/dist/$2/mediainfo.zip *

echo "zip and copy upload-execute to dist/$2/"
cd ../upload-execute
#npm install --production
zip -qr ../../deployment/dist/$2/upload-execute.zip *

echo "zip and copy createguid to dist/$2/"
cd ../createguid
#npm install --production
zip -qr ../../deployment/dist/$2/createguid.zip *

echo "zip and copy copyvideo to dist/$2/"
cd ../copyvideo
#npm install --production
zip -qr ../../deployment/dist/$2/copyvideo.zip *

echo "Removing temp template file"
rm ../../deployment/dist/$2/video-on-demand-media-convert.template-e 
