FROM opensuse/tumbleweed

WORKDIR /app

COPY . /app

RUN zypper -n install python3 iproute2 which

CMD ["python3", "app.py"]
