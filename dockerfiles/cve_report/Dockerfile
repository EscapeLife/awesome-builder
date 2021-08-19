FROM python:3-alpine

ENV TZ=Asia/Shanghai

WORKDIR /opt/cve_report

COPY . ./

RUN /usr/local/bin/python -m pip install --upgrade pip && \
	pip install --no-cache-dir -r requirements.txt

CMD [ "python", "./tencent_security_report_docker.py" ]
