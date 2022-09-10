#podman push diffusion docker.io/vans163/sd
FROM docker.io/nvidia/cuda:11.3.1-base-ubuntu20.04

#SHELL ["/bin/bash", "-c"]

RUN apt update \
 && apt install --no-install-recommends -y curl wget git zip jq \
 && apt-get clean

COPY . /root/stable-diffusion

RUN mkdir -p /root/.cache /data /output /root/stable-diffusion/outputs \
  && ln -s /data /root/stable-diffusion/models/ldm/stable-diffusion-v1 \
  && ln -s /output /root/stable-diffusion/outputs/txt2img-samples \
  && ln -s /root/stable-diffusion/sd-v1-4.ckpt /data/model.ckpt

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh -O ~/miniconda.sh \
 && bash ~/miniconda.sh -b -p $HOME/miniconda \
 && $HOME/miniconda/bin/conda init

RUN eval "$($HOME/miniconda/bin/conda shell.bash hook)" \
 && cd /root/stable-diffusion \
 && conda env create -f environment.yaml \
 && conda activate ldm \
 && pip install gradio==3.1.7

RUN rm -rf /root/.cache && ln -s /root/stable-diffusion/gpux_cache /root/.cache

ENV PYTHONUNBUFFERED=1
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860
EXPOSE 7860

WORKDIR /root/stable-diffusion

ENTRYPOINT ["/root/stable-diffusion/docker-bootstrap.sh"]
CMD python optimizedSD/txt2img_gradio.py
#CMD /bin/bash
