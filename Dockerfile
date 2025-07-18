FROM ubuntu:24.04
MAINTAINER Daniel Pelaez-Zapata

ENV DEBIAN_FRONTEND=noninteractive

# Install build essentials
RUN apt-get update && apt-get install -y \
    build-essential wget cmake git gfortran \
    && rm -rf /var/lib/apt/lists/*

# Set installation prefix
ENV PREFIX=/usr/local
ENV CC=/usr/bin/gcc
ENV FC=/usr/bin/gfortran

# download zlib, hdf5, netcdf-c and netcdf-fortran
WORKDIR /tmp/
ENV ZLTAG="1.3.1"
ENV H5TAG="1.13.0"
ENV NCTAG="4.9.2"
ENV NFTAG="4.6.1"

## donwload source code of depencies
RUN wget -nc -nv "https://zlib.net/fossils/zlib-$ZLTAG.tar.gz"
RUN wget -nc -nv "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${H5TAG%.*}/hdf5-$H5TAG/src/hdf5-$H5TAG.tar"
RUN wget -nc -nv "https://downloads.unidata.ucar.edu/netcdf-c/$NCTAG/netcdf-c-$NCTAG.tar.gz"
RUN wget -nc -nv "https://downloads.unidata.ucar.edu/netcdf-fortran/$NFTAG/netcdf-fortran-$NFTAG.tar.gz"


# Build zlib
RUN tar -xf zlib-$ZLTAG.tar.gz && \
    cd zlib-$ZLTAG/ && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} && \
    make -j$(nproc) && make install && \
    cd ../..

# Build HDF5 (with zlib)
RUN tar -xf hdf5-$H5TAG.tar && \
    cd hdf5-$H5TAG/ && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} \
             -DHDF5_ENABLE_Z_LIB_SUPPORT=ON \
             -DHDF5_BUILD_FORTRAN=ON && \
    make -j$(nproc) && make install && \
    cd ../..

# Build netcdf-c
RUN tar -xf netcdf-c-$NCTAG.tar.gz && \
    cd netcdf-c-$NCTAG/ && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} \
             -DENABLE_BYTERANGE=OFF \
             -DENABLE_DAP=OFF && \
    make -j$(nproc) && make install && \
    cd ../..

# Build netcdf-fortran
RUN tar -xf netcdf-fortran-$NFTAG.tar.gz && \
    cd netcdf-fortran-$NFTAG/ && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} && \
    make -j$(nproc) && make install && \
    cd ../..

# clean up
ENV LD_LIBRARY_PATH=/usr/local/lib
RUN rm -rf /tmp/*

# Clone and build GOTM
RUN mkdir /opt/gotm/ && cd /opt/gotm/ && \
    git clone --recursive https://github.com/gotm-model/code.git && \
    mkdir build && cd build && \
    cmake ../code \
        -DCMAKE_INSTALL_PREFIX=/opt/gotm/build \
        -DGOTM_USE_CVMIX=ON \
        -DGOTM_USE_FABM=OFF && \
        make -j$(nproc) && make install

# add binary to /usr/local/bin
RUN ln -s /opt/gotm/build/bin/gotm /usr/bin/gotm
WORKDIR /case
CMD ["./gotm", "-v"]
