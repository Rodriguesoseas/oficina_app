# Oficina App

App mobile Flutter para a API Rails de gestão de oficina de motos.

## Pré-requisitos

- API Rails rodando em `http://localhost:3000` (ver [oficina_api](../oficina_api/README.md))
- Flutter SDK 3.29+

## Configuração da API

A URL base está em `lib/config/api_config.dart`:

| Ambiente | URL |
|----------|-----|
| Emulador Android | `http://10.0.2.2:3000/api/v1` |
| iOS / desktop / WSL | `http://localhost:3000/api/v1` |

## Rodar no Windows (recomendado para emulador Android)

1. Suba a API no WSL:
   ```bash
   cd /home/oseas/oficina_api
   API_TOKEN=dev-token bundle exec rails server -b 0.0.0.0 -p 3000
   ```

2. No Windows, abra o projeto:
   ```powershell
   cd \\wsl$\Ubuntu\home\oseas\oficina_app
   flutter pub get
   flutter run
   ```

## Rodar no WSL

```bash
export PATH="/home/oseas/flutter/bin:$PATH"
cd /home/oseas/oficina_app
flutter pub get
flutter analyze
```

Para dispositivo Android físico ou emulador, prefira executar o Flutter no Windows.

## Telas do MVP

- Home com ordens de serviço recentes
- Busca de cliente e moto por placa
- Atendimento rápido (avulso, cliente/moto novos ou existentes)
- Detalhe da ordem de serviço
