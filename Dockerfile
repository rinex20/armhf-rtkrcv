FROM armhf/debian:latest as builder

ENV version=b31_mod_201906
ENV RTK_VER=demo5

RUN apt-get update 
RUN apt-get install -y build-essential gcc git wget 

# Get RTKLIB and compile only required components
ARG RTKLIB_URL=https://github.com/rtklibexplorer/RTKLIB.git
RUN git clone --depth 1 --branch ${RTK_VER} ${RTKLIB_URL} \
    && (cd RTKLIB/lib/iers/gcc/; make) \
    && (cd RTKLIB/app/convbin/gcc/; make; make install) \
    && (cd RTKLIB/app/rnx2rtkp/gcc/; make; make install) \
    && (cd RTKLIB/app/pos2kml/gcc/; make; make install) \
    && (cd RTKLIB/app/str2str/gcc/; make; make install) \
    && (cd RTKLIB/app/rtkrcv/gcc/; make; make install) 


FROM armhf/debian:latest

WORKDIR /data/rtk/conf
# get conf file
ARG CONF_URL=https://raw.githubusercontent.com/rinex20/gnss_tools/master/conf/rtkrcv.conf
RUN wget --no-check-certificate ${CONF_URL} -O rtkrcv.conf

RUN apt-get update && apt-get install -y csh

COPY --from=builder /usr/local/bin/* /usr/local/bin/

# run rtkrcv
EXPOSE 8077 8078 8001-8008
# CMD ["rtkrcv", "-p 8077 -m 8078 -o /data/rtk/conf/rtkrcv.conf"] 
ENTRYPOINT ["rtkrcv", "-p 8077 -m 8078 -o /data/rtk/conf/rtkrcv.conf"] 
