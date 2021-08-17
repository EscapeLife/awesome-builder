FROM python:3-alpine

ENV TZ=Asia/Shanghai

WORKDIR /opt/cve_report

COPY . ./

RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "./tencent_security_report_docker.py" ]
