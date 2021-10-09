FROM ubuntu:21.04 AS exodus-build
ENV DEBIAN_FRONTEND="noninteractive"
RUN  apt-get update
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  python3 \
  git \
  wget \
  zlib1g-dev \
  m4 \
  automake \
  libtool \
  gfortran && rm -rf /var/lib/apt/lists/*
COPY ./seacas ./seacas
WORKDIR ./seacas
RUN ACCESS=`pwd` JOBS=`nproc` ./install-tpl.sh
RUN mkdir -p build && \
    cd build && \
    ../cmake-exodus && \
    make -j`nproc` && \
    make install && \
    rm -rf ../build

FROM ubuntu:21.04 AS watershed-workflow
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y \
  python3 \
  python3-pandas \
  python3-scipy \
  python3-rasterio \
  python3-fiona \
  python3-shapely \
  python3-cartopy \
  python3-pyproj \
  python3-requests \
  python3-matplotlib \
  jupyter-notebook \
  sudo \
  python-is-python3 && rm -rf /var/lib/apt/lists/*
RUN pip3 install meshpy sortedcontainers --no-cache-dir
COPY ./watershed-workflow ./watershed-workflow
WORKDIR ./watershed-workflow
COPY --from=exodus-build /seacas/bin /seacas/bin
COPY --from=exodus-build /seacas/lib /seacas/lib
COPY --from=exodus-build /seacas/include /seacas/include
ENV PATH="/seacas/bin:${PATH}"
ENV SEACAS_DIR=/seacas
ENV WATERSHED_WORKFLOW_DIR=/watershed-workflow
ENV PYTHONPATH=${WATERSHED_WORKFLOW_DIR}:${WATERSHED_WORKFLOW_DIR}/workflow_tpls:${SEACAS_DIR}/lib:${PYTHONPATH}
# Check install
RUN python -c 'import numpy, matplotlib, scipy, rasterio, fiona, shapely, cartopy, meshpy.triangle; import exodus3; print("SUCCESS")'
WORKDIR /
COPY ./docker-entrypoint.sh ./docker-entrypoint.sh
RUN echo "c.NotebookApp.ip = '0.0.0.0'" > /etc/jupyter/jupyter_notebook_config.py
ENTRYPOINT [ "./docker-entrypoint.sh" ]
