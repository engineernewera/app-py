#FROM python:3.7-alpine
# FROM python:3.7-alpine as builder
# LABEL Manitainer="Charles" Application-name="E-comm Website"
# WORKDIR /code
# RUN apk add --no-cache gcc musl-dev linux-headers
# COPY requirements.txt requirements.txt
# RUN pip install -r requirements.txt

# FROM gcr.io/distroless/python3
# WORKDIR /code
# COPY --from=builder /code /code/
# ENV FLASK_APP=app.py
# ENV FLASK_RUN_HOST=0.0.0.0
# EXPOSE 5000
# COPY . .
# CMD ["flask", "run"]


# curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
#   /usr/share/keyrings/jenkins-keyring.asc > /dev/null
# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
#   https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
#   /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update
# sudo apt-get install jenkins

# /home/charles/Desktop/docker-compose/composetest/Dockerfile

#FROM gcr.io/distroless/python3
FROM python:3.7-alpine as builder
LABEL Manitainer="Charles" Application-name="E-comm Website"
WORKDIR /code
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

FROM gcr.io/distroless/python3
#FROM python:3.9-slim-buster
#WORKDIR /code
COPY --from=builder /code /code/
EXPOSE 5000
#COPY . .
CMD ["flask", "run"]
#activated pollSCM general options 1
