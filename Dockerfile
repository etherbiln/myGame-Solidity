FROM python:3.9-slim

# Gerekli paketlerin kurulumu
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    && apt-get clean

# Mythril yükleniyor
RUN pip install --no-cache-dir mythril

# Çalışma dizinini ayarlayın
WORKDIR /mythril

# Varsayılan komut
ENTRYPOINT ["myth"]
