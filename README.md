# Siscont Restaurantes

Este repositório contém um aplicativo mobile criado em Flutter para gerenciar restaurantes.
O aplicativo utiliza um banco de dados SQLite local para funcionar mesmo sem conexão com a internet.

## Estrutura
- `lib/main.dart`: ponto de entrada do aplicativo.
- `pubspec.yaml`: definição das dependências do projeto.

## Como executar
1. Certifique-se de ter o Flutter instalado em sua máquina.
2. No diretório do projeto, execute `flutter pub get` para baixar as dependências.
3. Em seguida, rode `flutter run` para iniciar o aplicativo em um emulador ou dispositivo conectado.

### Offline
O uso do pacote `sqflite` permite armazenar dados localmente, garantindo que o aplicativo funcione mesmo sem acesso à internet.
