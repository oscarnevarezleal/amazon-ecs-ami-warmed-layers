#!/usr/bin/env bash
set -ex

BINARY_PATH="/var/lib/ecs/deps/cog/bin"
sudo mkdir -p "${BINARY_PATH}"

DREAMBOOTH_PATH='/var/dreambooth'
sudo mkdir -p "${DREAMBOOTH_PATH}"
sudo chmod 777 ${DREAMBOOTH_PATH}

# Install cog
sudo curl -o /usr/local/bin/cog -L "https://github.com/replicate/cog/releases/latest/download/cog_$(uname -s)_$(uname -m)"
sudo chmod +x /usr/local/bin/cog

tmpfile=$(mktemp)
cat >$tmpfile <<EOF
#!/usr/bin/env bash
set -ex
DREAMBOOTH_PATH=${DREAMBOOTH_PATH}
echo "DREAMBOOTH_PATH=${DREAMBOOTH_PATH}"
echo "Docker warming: Downloading required docker images"
docker pull onevarez/cog-dreambooth-base
docker pull r8.im/replicate/dreambooth
docker pull nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04
echo "Stable diffusion warming: Downloading models"
git clone https://github.com/replicate/dreambooth.git $DREAMBOOTH_PATH && cd ${DREAMBOOTH_PATH}
cog run script/download-weights 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
EOF

sudo mv $tmpfile "${BINARY_PATH}"/env-warm
sudo chmod +x "${BINARY_PATH}"/env-warm

#curl -o download-frozen-image-v2.sh \
#  https://raw.githubusercontent.com/moby/moby/master/contrib/download-frozen-image-v2.sh &&
#  chmod +x download-frozen-image-v2.sh
#
#./download-frozen-image-v2.sh nvidia_cuda_devel $DOCKER_IMAGE && \
#  tar -C 'nvidia_cuda_devel' -cf 'nvidia_cuda_devel.tar' . && \
#  rm -rf nvidia_cuda_devel/*

# Other images
# r8.im/replicate/dreambooth

# For later load into docker using
# docker load --input nvidia_cuda_devel.tar

#rm ./download-frozen-image-v2.sh
