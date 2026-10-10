# A2M Motos App

Aplicativo mobile desenvolvido em **Flutter** para gerenciamento de oficinas de motocicletas.

O sistema foi criado para centralizar as principais operações da oficina em um único aplicativo, permitindo o gerenciamento de clientes, motos, ordens de serviço e estoque diretamente pelo dispositivo móvel, integrado à API desenvolvida em Ruby on Rails.

## Funcionalidades

- 📋 Dashboard com indicadores da oficina
- 👥 Gerenciamento de clientes
- 🏍️ Gerenciamento de motocicletas
- 🔧 Gerenciamento de Ordens de Serviço
- 📦 Controle de estoque
- 📅 Agenda de atendimentos
- 🔍 Pesquisa rápida de clientes e motos
- 🔄 Integração com API REST
- 📱 Interface otimizada para dispositivos móveis

## Tecnologias

- Flutter
- Dart
- Riverpod
- Material Design 3
- HTTP
- Ruby on Rails (API)
- PostgreSQL

## Arquitetura

O aplicativo consome uma API REST responsável por toda a regra de negócio e persistência dos dados.

```text
Flutter
    │
    ▼
Ruby on Rails API
    │
    ▼
PostgreSQL
```

## Estrutura do Projeto

```text
lib/
├── config/
├── core/
├── models/
├── providers/
├── screens/
├── services/
├── theme/
├── utils/
└── widgets/
```

## Executando o Projeto

### Pré-requisitos

- Flutter SDK 3.29 ou superior
- Android Studio ou VS Code
- Backend da Oficina API em execução

### Instalação

```bash
git clone https://github.com/Rodriguesoseas/oficina_app.git

cd oficina_app

flutter pub get

flutter run
```

## API

Este aplicativo utiliza a **Oficina API**, desenvolvida em Ruby on Rails.

Repositório:

https://github.com/Rodriguesoseas/oficina_api

## Objetivo

O projeto foi desenvolvido com foco na informatização de oficinas de motocicletas, oferecendo uma solução mobile simples, intuitiva e integrada para auxiliar no controle das operações diárias.

## Status

🟢 Projeto concluído e em produção.

## Autor

**Oseas de Sousa Rodrigues**

- GitHub: https://github.com/Rodriguesoseas
- LinkedIn: www.linkedin.com/in/oseasrodrigues-dev
