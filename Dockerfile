FROM emilybache/vsftpd-server:latest
MAINTAINER Mauro Della Chiesa <mauro-dellachiesa>

#apt-get install automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config
RUN apt-get update && apt-get install -y \
	automake \
	autotools-dev \
	g++ \
	git \
	libcurl4-gnutls-dev \
	libfuse-dev \
	libssl-dev \
	libxml2-dev \
	make \
	pkg-config


#FTP user
ENV USER myuser
#FTP password
ENV PASS verysecretpwd

#S3 Bucket name
ENV S3_BUCKET bucketname
#AWS Identity
ENV AWS_IDENTITY theidentity
#AWS Credential
ENV AWS_CREDENTIAL thecredential

###### s3fs-fuse ######

RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git
WORKDIR s3fs-fuse
RUN ./autogen.sh  && \
	./configure && \
	make && \
	make install

# Save AWS credentials to a file
RUN echo $AWS_IDENTITY:$AWS_CREDENTIAL > /home/passwd
RUN chmod 600 /home/passwd

#Add entry on fstab to mount the bucket
RUN echo $S3_BUCKET /ftp/$USER fuse.s3fs _netdev,allow_other 0 0 > /etc/fstab

ENTRYPOINT ["/usr/local/bin/start.sh"]

CMD ["/usr/bin/supervisord"]